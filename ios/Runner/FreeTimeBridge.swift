import Flutter
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
/// - DeviceActivity (Screen Time): did any app get used during the session?
///   The extension writes an "interrupted" flag to the shared App Group.
///   Optional: without it a session is simply unverified.
/// - Focus status: counts as DND. Optional.
/// - Boot time (sysctl): reboot / powered-off detection via last heartbeat.
///
/// Motion & Fitness was dropped on purpose (14/10-2026): one more scary prompt
/// for a weak signal. Every permission is asked for from the "how we measure"
/// screen, never at launch.
final class FreeTimeBridge: NSObject, FlutterStreamHandler {

  static let appGroup = "group.co.componental.freetime"
  static let activityName = "freetime.session"

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
        // So Flutter can show the live session after a relaunch.
        "activeStartedAt": (defaults.object(forKey: "active_started") as? TimeInterval).map { Int($0 * 1000) } as Any,
        "screenTime": screenTimeAuthorized(),
      ])

    case "startSession":
      let args = call.arguments as? [String: Any]
      let claimed = args?["selfReportedMode"] as? String ?? "normal"
      startSession(claimedMode: claimed,
                   wifiOn: args?["wifiOn"] as? Bool ?? false,
                   bluetoothOn: args?["bluetoothOn"] as? Bool ?? false)
      result(nil)

    case "stopSession":
      stopSession { result($0) }

    case "isSessionRunning":
      result(defaults.object(forKey: "active_started") != nil)

    case "drainPendingSessions":
      result(drainPending())

    case "permissionStatus":
      result(permissionStatus())

    case "requestPermission":
      let name = (call.arguments as? [String: Any])?["name"] as? String ?? ""
      requestPermission(name) { result(self.permissionStatus()) }

    default:
      result(FlutterMethodNotImplemented)
    }
  }

  // MARK: session lifecycle

  private func startSession(claimedMode: String, wifiOn: Bool, bluetoothOn: Bool) {
    let now = Date()
    defaults.set(now.timeIntervalSince1970, forKey: "active_started")
    defaults.set(claimedMode, forKey: "active_claimed")
    // Radios are self-reported too (iOS cannot read Wi-Fi; Bluetooth needs a prompt).
    defaults.set(wifiOn, forKey: "active_wifi_on")
    defaults.set(bluetoothOn, forKey: "active_bt_on")
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

    // Measured Focus (2.5×) beats a self-reported sound/vibrate/silent;
    // self-reported airplane (4×) still wins.
    var mode = claimed
    if focusIsOn(), ["normal", "vibrate", "silent"].contains(mode) { mode = "dnd" }
    let selfReported = claimed != "normal"

    // Verified only means "Screen Time was watching and saw no use".
    let verified = screenTimeAuthorized() && !interrupted
    completion([[
      "clientId": UUID().uuidString,
      "startedAt": Int(start.timeIntervalSince1970 * 1000),
      "endedAt": Int(end.timeIntervalSince1970 * 1000),
      "mode": mode,
      "source": "manual",
      "verified": verified,
      "selfReported": selfReported,
      "pickups": pickups + (interrupted ? 1 : 0),
      "wifiOn": defaults.bool(forKey: "active_wifi_on"),
      "bluetoothOn": defaults.bool(forKey: "active_bt_on"),
    ]])
  }

  // MARK: verification sources

  private func focusIsOn() -> Bool {
    guard INFocusStatusCenter.default.authorizationStatus == .authorized else { return false }
    return INFocusStatusCenter.default.focusStatus.isFocused ?? false
  }

  private func startDeviceActivityMonitoring() {
    #if canImport(DeviceActivity)
    if #available(iOS 16.0, *) {
      guard screenTimeAuthorized() else { return }
      let center = DeviceActivityCenter()
      let now = Calendar.current.dateComponents([.hour, .minute, .second], from: Date())
      let schedule = DeviceActivitySchedule(
        intervalStart: now,
        intervalEnd: DateComponents(hour: 23, minute: 59, second: 59),
        repeats: false
      )
      // Fire as soon as ANY app accumulates 1 minute of use during the session.
      // No tokens = all activity (`includesAllActivity` is a read-only property,
      // not an init argument). Unverified on device.
      let threshold = DateComponents(minute: 1)
      let event: DeviceActivityEvent
      if #available(iOS 17.4, *) {
        // Don't count usage from earlier in the day toward the threshold.
        event = DeviceActivityEvent(threshold: threshold, includesPastActivity: false)
      } else {
        event = DeviceActivityEvent(threshold: threshold)
      }
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

  private func screenTimeAuthorized() -> Bool {
    #if canImport(FamilyControls)
    if #available(iOS 16.0, *) {
      return AuthorizationCenter.shared.authorizationStatus == .approved
    }
    #endif
    return false
  }

  private func permissionStatus() -> [String: Any] {
    [
      "focus": INFocusStatusCenter.default.authorizationStatus == .authorized,
      "screenTime": screenTimeAuthorized(),
    ]
  }

  /// `name` is "focus" or "screenTime". Each is asked for on its own, from the
  /// intro screen, with the app's own explanation shown first.
  private func requestPermission(_ name: String, _ done: @escaping () -> Void) {
    switch name {
    case "focus":
      INFocusStatusCenter.default.requestAuthorization { _ in DispatchQueue.main.async(execute: done) }
    case "screenTime":
      #if canImport(FamilyControls)
      if #available(iOS 16.0, *) {
        Task {
          try? await AuthorizationCenter.shared.requestAuthorization(for: .individual)
          await MainActor.run(body: done)
        }
        return
      }
      #endif
      done()
    default:
      done()
    }
  }
}
