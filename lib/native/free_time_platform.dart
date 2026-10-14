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
  });

  final SessionMode mode;
  final bool canMeasureRinger;
  final bool canMeasureAirplane;
  final bool canMeasureDnd;
  final bool serviceRunning;

  static DeviceState fromMap(Map<dynamic, dynamic> m) => DeviceState(
        mode: SessionModeX.fromWire(m['mode'] as String? ?? 'normal'),
        canMeasureRinger: m['canMeasureRinger'] as bool? ?? false,
        canMeasureAirplane: m['canMeasureAirplane'] as bool? ?? false,
        canMeasureDnd: m['canMeasureDnd'] as bool? ?? false,
        serviceRunning: m['serviceRunning'] as bool? ?? false,
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
  /// (silent / airplane); on Android the argument is ignored and measured.
  Future<void> startSession({SessionMode? selfReportedMode}) =>
      _methods.invokeMethod('startSession', {
        'selfReportedMode': selfReportedMode?.wire,
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

  /// Ask for the OS permissions the measurement layer needs.
  /// Android: notifications + battery-optimisation exemption.
  /// iOS: Motion & Fitness, Focus status, Screen Time (FamilyControls).
  Future<void> requestPermissions() => _methods.invokeMethod('requestPermissions');
}
