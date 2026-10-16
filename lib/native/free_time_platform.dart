import 'dart:io';

import 'package:flutter/services.dart';

import '../core/session.dart';

/// Snapshot of the device state that affects scoring.
class DeviceState {
  const DeviceState({
    required this.mode,
    required this.canMeasureRinger,
    required this.canMeasureAirplane,
    required this.canMeasureDnd,
    required this.serviceRunning,
    this.sessionStartedAt,
    this.screenTime = false,
    this.wifiOn = false,
    this.bluetoothOn = false,
    this.dataOn = true,
  });

  final SessionMode mode;
  final bool canMeasureRinger;
  final bool canMeasureAirplane;
  final bool canMeasureDnd;
  final bool serviceRunning;

  /// iOS: start of the running manual session, if any.
  final DateTime? sessionStartedAt;

  /// iOS: Screen Time permission granted, so sessions can be verified.
  final bool screenTime;

  /// Android: measured radio state. iOS: not readable, self-reported instead.
  final bool wifiOn;
  final bool bluetoothOn;
  final bool dataOn;

  static DeviceState fromMap(Map<dynamic, dynamic> m) => DeviceState(
        mode: SessionModeX.fromWire(m['mode'] as String? ?? 'normal'),
        canMeasureRinger: m['canMeasureRinger'] as bool? ?? false,
        canMeasureAirplane: m['canMeasureAirplane'] as bool? ?? false,
        canMeasureDnd: m['canMeasureDnd'] as bool? ?? false,
        serviceRunning: m['serviceRunning'] as bool? ?? false,
        sessionStartedAt: m['activeStartedAt'] is int
            ? DateTime.fromMillisecondsSinceEpoch(m['activeStartedAt'] as int)
            : null,
        screenTime: m['screenTime'] as bool? ?? false,
        wifiOn: m['wifiOn'] as bool? ?? false,
        bluetoothOn: m['bluetoothOn'] as bool? ?? false,
        dataOn: m['dataOn'] as bool? ?? true,
      );
}

/// Bridge to the native measurement layer.
///
/// Android: `SessionService` (foreground service) + `BootReceiver`.
/// iOS: `FreeTimeBridge.swift` (CoreMotion history, DeviceActivity events,
/// Focus status, boot time).
class FreeTimePlatform {
  FreeTimePlatform._();
  static final instance = FreeTimePlatform._();

  static const _methods = MethodChannel('free_time/methods');
  static const _events = EventChannel('free_time/sessions');

  bool get isAndroid => Platform.isAndroid;
  bool get isIOS => Platform.isIOS;

  /// Sessions the native layer finishes while the app is alive.
  Stream<Session> get sessions => _events
      .receiveBroadcastStream()
      .map((e) => Session.fromNative(e as Map<dynamic, dynamic>));

  Future<DeviceState> currentState() async {
    final m = await _methods.invokeMethod<Map<dynamic, dynamic>>('currentState');
    return DeviceState.fromMap(m ?? const {});
  }

  /// Start a session. On iOS [selfReportedMode] is the mode the user claims
  /// (silent / airplane) and the radio flags what they say is still on; on
  /// Android the arguments are ignored and everything is measured.
  Future<void> startSession(
          {SessionMode? selfReportedMode, bool wifiOn = false, bool bluetoothOn = false, bool dataOn = true}) =>
      _methods.invokeMethod('startSession', {
        'selfReportedMode': selfReportedMode?.wire,
        'wifiOn': wifiOn,
        'bluetoothOn': bluetoothOn,
        'dataOn': dataOn,
      });

  /// Stop the running session. Returns the finished session(s); the native
  /// side may have split it at state changes.
  Future<List<Session>> stopSession() async {
    final list = await _methods.invokeMethod<List<dynamic>>('stopSession');
    return (list ?? const [])
        .map((e) => Session.fromNative(e as Map<dynamic, dynamic>))
        .toList();
  }

  Future<bool> isSessionRunning() async =>
      await _methods.invokeMethod<bool>('isSessionRunning') ?? false;

  /// Sessions produced while Flutter was not running (shutdown, reboot,
  /// auto-detected on Android). Native clears its queue once drained.
  Future<List<Session>> drainPendingSessions() async {
    final list = await _methods.invokeMethod<List<dynamic>>('drainPendingSessions');
    return (list ?? const [])
        .map((e) => Session.fromNative(e as Map<dynamic, dynamic>))
        .toList();
  }

  /// Android only: notifications + battery-optimisation exemption, asked for
  /// at launch because the always-on counter cannot run without them.
  Future<void> requestPermissions() => _methods.invokeMethod('requestPermissions');

  /// Android: the counter's own event log (boot, shutdown, segments).
  Future<String> diagnosticLog() async =>
      await _methods.invokeMethod<String>('diagnosticLog') ?? '';

  /// iOS only. Both permissions are optional and asked for one at a time from
  /// the "how we measure" screen, after the app's own explanation.
  Future<IosPermissions> permissionStatus() async {
    final m = await _methods.invokeMethod<Map<dynamic, dynamic>>('permissionStatus');
    return IosPermissions.fromMap(m ?? const {});
  }

  /// [name] is `focus` or `screenTime`. Returns the status afterwards.
  Future<IosPermissions> requestPermission(String name) async {
    final m = await _methods.invokeMethod<Map<dynamic, dynamic>>('requestPermission', {'name': name});
    return IosPermissions.fromMap(m ?? const {});
  }
}

class IosPermissions {
  const IosPermissions({required this.focus, required this.screenTime});
  final bool focus;
  final bool screenTime;

  static IosPermissions fromMap(Map<dynamic, dynamic> m) => IosPermissions(
        focus: m['focus'] as bool? ?? false,
        screenTime: m['screenTime'] as bool? ?? false,
      );
}
