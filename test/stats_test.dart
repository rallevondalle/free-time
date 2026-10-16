import 'package:flutter_test/flutter_test.dart';
import 'package:free_time/core/session.dart';
import 'package:free_time/core/stats.dart';

Session _s(DateTime end, int minutes, {SessionMode mode = SessionMode.silent, int? points}) => Session(
      clientId: '${end.millisecondsSinceEpoch}',
      startedAt: end.subtract(Duration(minutes: minutes)),
      endedAt: end,
      mode: mode,
      source: SessionSource.auto,
      verified: true,
      selfReported: false,
      pickups: 0,
      screenOn: false,
      wifiOn: true, // radios on: the plain table
      bluetoothOn: true,
      points: points,
    );

void main() {
  final now = DateTime(2026, 10, 16, 10, 0); // today = 16/10

  test('empty without a whole day', () {
    final st = Stats.of([_s(DateTime(2026, 10, 16, 8), 60)], now: now);
    expect(st.isEmpty, isTrue);
    expect(st.averageRecent, isNull);
  });

  test('a session counts on the day it ends; zero days fill gaps; today excluded', () {
    final st = Stats.of([
      _s(DateTime(2026, 10, 12, 23, 0), 60, points: 100),
      _s(DateTime(2026, 10, 13, 0, 30), 60, points: 500), // night, counts on 13/10
      _s(DateTime(2026, 10, 15, 12, 0), 60, points: 300),
      _s(DateTime(2026, 10, 16, 9, 0), 60, points: 9999), // today, ignored
    ], now: now);
    expect(st.days.map((d) => d.day.day).toList(), [12, 13, 14, 15]);
    expect(st.days.map((d) => d.points).toList(), [100, 500, 0, 300]);
    expect(st.totalPoints, 900);
    expect(st.averageLifetime, 225);
    expect(st.averageRecent, 225);
    expect(st.best.map((d) => d.points).toList(), [500, 300, 100]);
    expect(st.worst.map((d) => d.points).toList(), [0, 100, 300]);
  });

  test('rolling window only looks back n days', () {
    final sessions = [
      for (var i = 1; i <= 40; i++) _s(DateTime(2026, 10, 16 - i, 12), 60, points: i <= 30 ? 100 : 1000),
    ];
    final st = Stats.of(sessions, now: now);
    expect(st.days.length, 40);
    expect(st.recent.length, 30);
    expect(st.averageRecent, 100);
    expect(st.averageLifetime, (30 * 100 + 10 * 1000) ~/ 40);
    expect(st.best.first.points, 1000);
  });

  test('falls back to estimated points before the server scored a session', () {
    final st = Stats.of([_s(DateTime(2026, 10, 15, 12), 10)], now: now); // silent 10 min = 20
    expect(st.totalPoints, 20);
  });
}
