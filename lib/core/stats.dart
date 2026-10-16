import 'session.dart';

/// Points for one calendar day. A session counts on the day it ends, like
/// the "today" list (a night that started yesterday belongs to today).
class DayTotal {
  const DayTotal(this.day, this.points);
  final DateTime day; // local midnight
  final int points;
}

/// Everything the home screen and the statistics screen show about the
/// past. Only whole days count: today is still running and would drag every
/// average down, so it is compared against the averages instead.
class Stats {
  const Stats({
    required this.days,
    required this.window,
  });

  /// Every whole day from the first session up to yesterday, zero days
  /// included: a day the app did not run is a day with no points.
  final List<DayTotal> days;

  /// How many days the rolling average looks back.
  final int window;

  static const defaultWindow = 30;

  bool get isEmpty => days.isEmpty;
  DateTime? get firstDay => days.isEmpty ? null : days.first.day;
  int get totalPoints => days.fold(0, (a, d) => a + d.points);
  int? get averageLifetime => _avg(days);

  List<DayTotal> get recent => days.length <= window ? days : days.sublist(days.length - window);
  int? get averageRecent => _avg(recent);

  /// Outliers. Only meaningful once there is something to stand out from.
  List<DayTotal> get best => days.length < 4 ? const [] : (_sorted(desc: true).take(3).toList());
  List<DayTotal> get worst => days.length < 4 ? const [] : (_sorted(desc: false).take(3).toList());

  List<DayTotal> _sorted({required bool desc}) {
    final l = [...days]..sort((a, b) {
        final c = desc ? b.points.compareTo(a.points) : a.points.compareTo(b.points);
        return c != 0 ? c : b.day.compareTo(a.day);
      });
    return l;
  }

  static int? _avg(List<DayTotal> l) =>
      l.isEmpty ? null : (l.fold(0, (a, d) => a + d.points) / l.length).round();

  static Stats of(Iterable<Session> sessions, {DateTime? now, int window = defaultWindow}) {
    final n = now ?? DateTime.now();
    final today = DateTime(n.year, n.month, n.day);
    final totals = <DateTime, int>{};
    for (final s in sessions) {
      final e = s.endedAt;
      final day = DateTime(e.year, e.month, e.day);
      if (!day.isBefore(today)) continue;
      totals[day] = (totals[day] ?? 0) + (s.points ?? s.estimatedPoints);
    }
    if (totals.isEmpty) return Stats(days: const [], window: window);
    final first = totals.keys.reduce((a, b) => a.isBefore(b) ? a : b);
    final days = <DayTotal>[];
    for (var d = first; d.isBefore(today); d = DateTime(d.year, d.month, d.day + 1)) {
      days.add(DayTotal(d, totals[d] ?? 0));
    }
    return Stats(days: days, window: window);
  }
}
