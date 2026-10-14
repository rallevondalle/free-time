import DeviceActivity
import Foundation

/// Screen Time extension. Runs in its own process; the only thing it does is
/// flag the running session as interrupted when any app reaches the usage
/// threshold. Shares state with the app through the App Group.
///
/// Target setup is described in docs/ios-setup.md.
class DeviceActivityMonitorExtension: DeviceActivityMonitor {
  private let defaults = UserDefaults(suiteName: "group.co.componental.freetime")

  override func eventDidReachThreshold(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
    super.eventDidReachThreshold(event, activity: activity)
    guard activity.rawValue == "freetime.session" else { return }
    defaults?.set(true, forKey: "active_interrupted")
    let pickups = defaults?.integer(forKey: "active_pickups") ?? 0
    defaults?.set(pickups + 1, forKey: "active_pickups")
  }
}
