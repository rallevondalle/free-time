import 'package:flutter_test/flutter_test.dart';
import 'package:free_time/core/session.dart';

Session _hour(SessionMode mode, {bool wifi = true, bool bt = true, bool data = true, bool verified = true}) => Session(
      clientId: 'x',
      startedAt: DateTime(2026, 10, 16, 12),
      endedAt: DateTime(2026, 10, 16, 13),
      mode: mode,
      source: SessionSource.auto,
      verified: verified,
      wifiOn: wifi,
      bluetoothOn: bt,
      dataOn: data,
    );

void main() {
  // Mirrors compute_points() in supabase/migrations/0003_radios_everywhere.sql.
  test('radios on: the plain table', () {
    expect(_hour(SessionMode.normal).estimatedPoints, 60);
    expect(_hour(SessionMode.silent).estimatedPoints, 120);
    expect(_hour(SessionMode.dnd).estimatedPoints, 150);
  });

  test('each radio off adds ×1.1 outside airplane mode', () {
    expect(_hour(SessionMode.silent, wifi: false).estimatedPoints, 132);
    expect(_hour(SessionMode.silent, wifi: false, bt: false).estimatedPoints, 145);
    expect(_hour(SessionMode.silent, wifi: false, bt: false, data: false).estimatedPoints, 159); // 2 × 1.331 = 2.662
    expect(_hour(SessionMode.dnd, wifi: false, bt: false, data: false).estimatedPoints, 199); // 3.3275×
  });

  test('airplane keeps its own table and tops a powered-on phone', () {
    expect(_hour(SessionMode.airplane, wifi: true, bt: true, data: false).estimatedPoints, 180);
    expect(_hour(SessionMode.airplane, wifi: false, bt: true, data: false).estimatedPoints, 240);
    expect(_hour(SessionMode.airplane, wifi: false, bt: false, data: false).estimatedPoints, 300);
    expect(_hour(SessionMode.dnd, wifi: false, bt: false, data: false).estimatedPoints,
        lessThan(_hour(SessionMode.airplane, wifi: false, bt: false).estimatedPoints));
    expect(_hour(SessionMode.dnd, wifi: false, bt: false, data: false).estimatedPoints,
        greaterThan(_hour(SessionMode.airplane, wifi: true).estimatedPoints));
  });

  test('powered off and unverified are untouched by radios', () {
    expect(_hour(SessionMode.poweredOff, wifi: false, bt: false, data: false).estimatedPoints, 600);
    expect(_hour(SessionMode.silent, wifi: false, bt: false, data: false, verified: false).estimatedPoints, 79);
  });

  test('unknown data state counts as on', () {
    final s = Session.fromRow({
      'client_id': 'r', 'started_at': '2026-10-16T12:00:00Z', 'ended_at': '2026-10-16T13:00:00Z',
      'mode': 'silent', 'source': 'auto', 'verified': true, 'wifi_on': false, 'bluetooth_on': false,
    });
    expect(s.dataOn, isTrue);
    expect(s.estimatedPoints, 145);
  });
}
