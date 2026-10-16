/// A contiguous period the phone was "down" in a single mode.
enum SessionMode { normal, vibrate, silent, dnd, airplane, poweredOff }

enum SessionSource { manual, auto, shutdown, reboot }

extension SessionModeX on SessionMode {
  String get wire => switch (this) {
        SessionMode.normal => 'normal',
        SessionMode.vibrate => 'vibrate',
        SessionMode.silent => 'silent',
        SessionMode.dnd => 'dnd',
        SessionMode.airplane => 'airplane',
        SessionMode.poweredOff => 'powered_off',
      };

  double get multiplier => switch (this) {
        SessionMode.normal => 1.0,
        SessionMode.vibrate => 1.5,
        SessionMode.silent => 2.0,
        SessionMode.dnd => 2.5,
        SessionMode.airplane => 4.0,
        SessionMode.poweredOff => 10.0,
      };

  /// Radios. Airplane mode has its own table and stays the top of a powered-on
  /// phone (5×). Everywhere else each radio that is off earns a little on top:
  /// ×1.1 per radio, ×1.33 with all three, so DND with everything off (3.33×)
  /// lands just above airplane mode with Wi-Fi still on (3×).
  /// Mirrors `compute_points()` / `scoring_rules` in the DB.
  double multiplierWith({required bool wifiOn, required bool bluetoothOn, bool dataOn = true}) {
    switch (this) {
      case SessionMode.airplane:
        if (wifiOn) return 3.0;
        if (bluetoothOn) return 4.0;
        return 5.0;
      case SessionMode.poweredOff:
        return multiplier;
      case SessionMode.normal:
      case SessionMode.vibrate:
      case SessionMode.silent:
      case SessionMode.dnd:
        var m = multiplier;
        if (!wifiOn) m *= radioOffFactor;
        if (!bluetoothOn) m *= radioOffFactor;
        if (!dataOn) m *= radioOffFactor;
        return m;
    }
  }

  /// `wifi_off` / `bluetooth_off` / `data_off` in `scoring_rules`.
  static const radioOffFactor = 1.1;

  static SessionMode fromWire(String s) =>
      SessionMode.values.firstWhere((m) => m.wire == s, orElse: () => SessionMode.normal);
}

extension SessionSourceX on SessionSource {
  String get wire => name;
  static SessionSource fromWire(String s) =>
      SessionSource.values.firstWhere((m) => m.name == s, orElse: () => SessionSource.manual);
}

class Session {
  const Session({
    required this.clientId,
    required this.startedAt,
    required this.endedAt,
    required this.mode,
    required this.source,
    this.verified = false,
    this.selfReported = false,
    this.pickups = 0,
    this.screenOn = false,
    this.wifiOn = false,
    this.bluetoothOn = false,
    this.dataOn = true,
    this.points,
    this.synced = false,
  });

  final String clientId;
  final DateTime startedAt;
  final DateTime endedAt;
  final SessionMode mode;
  final SessionSource source;
  final bool verified;
  final bool selfReported;
  final int pickups;
  final bool screenOn; // lying still but screen on (locked): fewer points
  final bool wifiOn; // radios: each one that is off earns ×1.1 (airplane: own table)
  final bool bluetoothOn;
  final bool dataOn; // mobile data; unknown counts as on (no bonus)
  final int? points; // server-computed; null until uploaded
  final bool synced; // the cloud has a copy (local bookkeeping only)

  Session copyWith({bool? synced, int? points}) => Session(
        clientId: clientId,
        startedAt: startedAt,
        endedAt: endedAt,
        mode: mode,
        source: source,
        verified: verified,
        selfReported: selfReported,
        pickups: pickups,
        screenOn: screenOn,
        wifiOn: wifiOn,
        bluetoothOn: bluetoothOn,
        dataOn: dataOn,
        points: points ?? this.points,
        synced: synced ?? this.synced,
      );

  Duration get duration => endedAt.difference(startedAt);

  /// Local preview of points, mirrors `compute_points()` in the DB.
  int get estimatedPoints {
    if (source == SessionSource.reboot) return 50;
    var mult = mode.multiplierWith(wifiOn: wifiOn, bluetoothOn: bluetoothOn, dataOn: dataOn);
    if (!verified) mult *= 0.5;
    if (screenOn) mult *= 0.5;
    return (duration.inSeconds / 60.0 * mult).floor();
  }

  Map<String, dynamic> toRow(String userId) => {
        'user_id': userId,
        'client_id': clientId,
        'started_at': startedAt.toUtc().toIso8601String(),
        'ended_at': endedAt.toUtc().toIso8601String(),
        'mode': mode.wire,
        'source': source.wire,
        'verified': verified,
        'self_reported': selfReported,
        'pickups': pickups,
        'screen_on': screenOn,
        'wifi_on': wifiOn,
        'bluetooth_on': bluetoothOn,
        'data_on': dataOn,
      };

  factory Session.fromRow(Map<String, dynamic> r) => Session(
        clientId: r['client_id'] as String,
        startedAt: DateTime.parse(r['started_at'] as String).toLocal(),
        endedAt: DateTime.parse(r['ended_at'] as String).toLocal(),
        mode: SessionModeX.fromWire(r['mode'] as String),
        source: SessionSourceX.fromWire(r['source'] as String),
        verified: r['verified'] as bool? ?? false,
        selfReported: r['self_reported'] as bool? ?? false,
        pickups: r['pickups'] as int? ?? 0,
        screenOn: r['screen_on'] as bool? ?? false,
        wifiOn: r['wifi_on'] as bool? ?? false,
        bluetoothOn: r['bluetooth_on'] as bool? ?? false,
        dataOn: r['data_on'] as bool? ?? true,
        points: r['points'] as int?,
      );

  /// Sessions coming over the platform channel use epoch millis.
  factory Session.fromNative(Map<dynamic, dynamic> m) => Session(
        clientId: m['clientId'] as String,
        startedAt: DateTime.fromMillisecondsSinceEpoch(m['startedAt'] as int),
        endedAt: DateTime.fromMillisecondsSinceEpoch(m['endedAt'] as int),
        mode: SessionModeX.fromWire(m['mode'] as String),
        source: SessionSourceX.fromWire(m['source'] as String),
        verified: m['verified'] as bool? ?? false,
        selfReported: m['selfReported'] as bool? ?? false,
        pickups: m['pickups'] as int? ?? 0,
        screenOn: m['screenOn'] as bool? ?? false,
        wifiOn: m['wifiOn'] as bool? ?? false,
        bluetoothOn: m['bluetoothOn'] as bool? ?? false,
        dataOn: m['dataOn'] as bool? ?? true,
        points: m['points'] as int?,
        synced: m['synced'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'clientId': clientId,
        'startedAt': startedAt.millisecondsSinceEpoch,
        'endedAt': endedAt.millisecondsSinceEpoch,
        'mode': mode.wire,
        'source': source.wire,
        'verified': verified,
        'selfReported': selfReported,
        'pickups': pickups,
        'screenOn': screenOn,
        'wifiOn': wifiOn,
        'bluetoothOn': bluetoothOn,
        'dataOn': dataOn,
        'points': points,
        'synced': synced,
      };

  factory Session.fromJson(Map<String, dynamic> j) => Session.fromNative(j);
}
