import Flutter
import CoreMotion
import Intents
import UIKit

#if canImport(FamilyControls)
import FamilyControls
import DeviceActivity
#endif

/// iOS measurement layer.
///
/// iOS cannot read the ring/silent switch or airplane mode, so those are
/// self-reported. What we *can* verify after the fact:
/// - CoreMotion activity history: was the phone stationary the whole time?
/// - DeviceActivity (Screen Time): did any app get used during the session?
///   The extension writes an "interrupted" flag to the shared App Group.
/// - Focus status: counts as DND.
/// - Boot time (sysctl): reboot / powered-off detection via last heartbeat.
final class FreeTimeBridge: NSObject, FlutterStreamHandler {

  static let appGroup = "group.co.componental.freetime"
  static let activityName = "freetime.session"

  private let motion = CMMotionActivityManager()
  private let defaults = UserDefaults(suiteName: FreeTimeBridge.appGroup) ?? .standard
  private var sink: FlutterEventSink?

  // MARK: registration

  static func register(with messenger: FlutterBinaryMessenger) -> FreeTimeBridge {
    let bridge = FreeTimeBridge()
    let methods = FlutterMethodChannel(name: "free_time/methods", binaryMessenger: messenger)
    methods.setMethodCallHandler(bridge.handle)
    let events = FlutterEventChannel(name: "free_time/sessions", binaryMessenger: messenger)
    events.setStreamHandler(bridge)
    bridge.checkBoot()
    bridge.heartbeat()
    return bridge
  }

  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    sink = events; return nil
  }
  func onCancel(withArguments arguments: Any?) -> FlutterError? { sink = nil; return nil }

  // MARK: method channel

  private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "currentState":
      result([
        "mode": focusIsOn() ? "dnd" : "normal",
        "canMeasureRinger": false,
        "canMeasureAirplane": false,
        "canMeasureDnd": INFocusStatusCenter.default.authorizationStatus == .authorized,
        "serviceRunning": defaults.object(forKey: "active_started") != nil,
      ])

    case "startSession":
      let args = call.arguments as? [String: Any]
      let claimed = args?["selfReportedMode"] as? String ?? "normal"
      startSession(claimedMode: claimed)
      result(nil)

    case "stopSession":
      stopSession { result($0) }

    case "isSessionRunning":
      result(defaults.object(forKey: "active_started") != nil)

    case "drainPendingSessions":
      result(drainPending())

    case "requestPermissions":
      requestPermissions()
      result(nil)

    default:
      result(FlutterMethodNotImplemented)
    }
  }

  // MARK: session lifecycle

  private func startSession(claimedMode: String) {
    let now = Date()
    defaults.set(now.timeIntervalSince1970, forKey: "active_started")
    defaults.set(claimedMode, forKey: "active_claimed")
    defaults.set(false, forKey: "active_interrupted")
    defaults.set(0, forKey: "active_pickups")
    startDeviceActivityMonitoring()
  }

  private func stopSession(_ completion: @escaping ([[String: Any]]) -> Void) {
    guard let startTs = defaults.object(forKey: "active_started") as? TimeInterval else {
      completion([]); return
    }
    let start = Date(timeIntervalSince1970: startTs)
    let end = Date()
    let claimed = defaults.string(forKey: "active_claimed") ?? "normal"
    let interrupted = defaults.bool(forKey: "active_interrupted")
    let pickups = defaults.integer(forKey: "active_pickups")
    stopDeviceActivityMonitoring()
    defaults.removeObject(forKey: "active_started")

    // Focus overrides a self-reported "normal"; self-reported airplane/silent win.
    var mode = claimed
    if mode == "normal", focusIsOn() { mode = "dnd" }
    let selfReported = claimed != "normal"

    wasStationary(from: start, to: end) { stationary in
      let verified = stationary && !interrupted
      completion([[
        "clientId": UUID().uuidString,
        "startedAt": Int(start.timeIntervalSince1970 * 1000),
        "endedAt": Int(end.timeIntervalSince1970 * 1000),
        "mode": mode,
        "source": "manual",
        "verified": verified,
        "selfReported": selfReported,
        "pickups": pickups + (interrupted ? 1 : 0),
      ]])
    }
  }

  // MARK: verification sources

  private func wasStationary(from: Date, to: Date, _ cb: @escaping (Bool) -> Void) {
    guard CMMotionActivityManager.isActivityAvailable() else { cb(false); return }
    motion.queryActivityStarting(from: from, to: to, to: .main) { activities, error in
      guard let activities = activities, error == nil else { cb(false); return }
      let moved = activities.contains { a in
        a.confidence != .low && (a.walking || a.running || a.cycling || a.automotive)
      }
      cb(!moved)
    }
  }

  private func focusIsOn() -> Bool {
    guard INFocusStatusCenter.default.authorizationStatus == .authorized else { return false }
    return INFocusStatusCenter.default.focusStatus.isFocused ?? false
  }

  private func startDeviceActivityMonitoring() {
    #if canImport(DeviceActivity)
    if #available(iOS 16.0, *) {
      guard AuthorizationCenter.shared.authorizationStatus == .approved else { return }
      let center = DeviceActivityCenter()
      let now = Calendar.current.dateComponents([.hour, .minute, .second], from: Date())
      let schedule = DeviceActivitySchedule(
        intervalStart: now,
        intervalEnd: DateComponents(hour: 23, minute: 59, second: 59),
        repeats: false
      )
      // Fire as soon as ANY app accumulates 1 minute of use during the session.
      let event = DeviceActivityEvent(
        applications: [], categories: [], webDomains: [],
        threshold: DateComponents(minute: 1),
        includesAllActivity: true
      )
      try? center.startMonitoring(
        DeviceActivityName(FreeTimeBridge.activityName),
        during: schedule,
        events: [DeviceActivityEvent.Name("any_usage"): event]
      )
    }
    #endif
  }

  private func stopDeviceActivityMonitoring() {
    #if canImport(DeviceActivity)
    if #available(iOS 16.0, *) {
      DeviceActivityCenter().stopMonitoring([DeviceActivityName(FreeTimeBridge.activityName)])
    }
    #endif
  }

  // MARK: reboot / powered-off

  private func bootTime() -> Date? {
    var tv = timeval(); var size = MemoryLayout<timeval>.size
    var mib: [Int32] = [CTL_KERN, KERN_BOOTTIME]
    guard sysctl(&mib, 2, &tv, &size, nil, 0) == 0 else { return nil }
    return Date(timeIntervalSince1970: TimeInterval(tv.tv_sec))
  }

  private func heartbeat() {
    defaults.set(Date().timeIntervalSince1970, forKey: "last_alive")
    NotificationCenter.default.addObserver(
      forName: UIApplication.didBecomeActiveNotification, object: nil, queue: .main
    ) { [weak self] _ in
      self?.defaults.set(Date().timeIntervalSince1970, forKey: "last_alive")
      self?.checkBoot()
    }
  }

  /// If the device booted since we last ran, emit a reboot or powered_off session.
  /// Off-time is estimated from the last heartbeat, so it is never "verified".
  private func checkBoot() {
    guard let boot = bootTime() else { return }
    let lastBoot = defaults.double(forKey: "last_boot")
    guard boot.timeIntervalSince1970 > lastBoot + 1 else { return }
    defaults.set(boot.timeIntervalSince1970, forKey: "last_boot")

    let lastAlive = defaults.double(forKey: "last_alive")
    guard lastAlive > 0, boot.timeIntervalSince1970 > lastAlive else { return }
    let gap = boot.timeIntervalSince1970 - lastAlive
    let source = gap < 3 * 60 ? "reboot" : "shutdown"
    appendPending([
      "clientId": UUID().uuidString,
      "startedAt": Int(lastAlive * 1000),
      "endedAt": Int(boot.timeIntervalSince1970 * 1000),
      "mode": "powered_off",
      "source": source,
      "verified": false,
      "selfReported": false,
      "pickups": 0,
    ])
  }

  // MARK: pending queue

  private func appendPending(_ s: [String: Any]) {
    var q = defaults.array(forKey: "pending") as? [[String: Any]] ?? []
    q.append(s)
    defaults.set(q, forKey: "pending")
  }

  private func drainPending() -> [[String: Any]] {
    let q = defaults.array(forKey: "pending") as? [[String: Any]] ?? []
    defaults.removeObject(forKey: "pending")
    return q
  }

  // MARK: permissions

  private func requestPermissions() {
    INFocusStatusCenter.default.requestAuthorization { _ in }
    // Motion permission is prompted on first query; warm it up with a no-op query.
    if CMMotionActivityManager.isActivityAvailable() {
      motion.queryActivityStarting(from: Date(), to: Date(), to: .main) { _, _ in }
    }
    #if canImport(FamilyControls)
    if #available(iOS 16.0, *) {
      Task {
        try? await AuthorizationCenter.shared.requestAuthorization(for: .individual)
      }
    }
    #endif
  }
}
