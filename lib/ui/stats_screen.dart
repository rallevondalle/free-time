import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core/stats.dart';
import '../data/session_repo.dart';
import 'l10n_ext.dart';

/// All-time numbers and the outliers. Whole days only; today is shown
/// separately so it can be read against the averages.
class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key, required this.repo, required this.todayPoints});
  final SessionRepo repo;
  final int todayPoints;

  static Future<void> show(BuildContext context, {required SessionRepo repo, required int todayPoints}) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => StatsScreen(repo: repo, todayPoints: todayPoints)));

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  late final Future<Stats> _stats = widget.repo.history().then(Stats.of);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final t = context.l10n;
    final locale = Localizations.localeOf(context).toString();
    final num = NumberFormat.decimalPattern(locale);
    final date = DateFormat.MMMEd(locale);
    final long = DateFormat.yMMMd(locale);

    return Scaffold(
      appBar: AppBar(title: Text(t.statsTitle)),
      body: FutureBuilder<Stats>(
        future: _stats,
        builder: (context, snap) {
          final st = snap.data;
          if (st == null) return const Center(child: CircularProgressIndicator());
          if (st.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(28),
              child: Center(
                child: Text(t.statsEmpty, textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(color: scheme.onSurfaceVariant)),
              ),
            );
          }
          Widget stat(String label, String value, {bool big = false}) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Expanded(child: Text(label, style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant))),
                    Text(value,
                        style: (big ? theme.textTheme.headlineSmall : theme.textTheme.titleMedium)
                            ?.copyWith(color: scheme.primary, fontWeight: FontWeight.w800)),
                  ],
                ),
              );
          Widget dayList(String title, List<DayTotal> days, IconData icon, Color color) => Card(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Icon(icon, size: 18, color: color),
                        const SizedBox(width: 8),
                        Text(title, style: theme.textTheme.titleMedium),
                      ]),
                      const SizedBox(height: 6),
                      for (final d in days)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Row(
                            children: [
                              Expanded(child: Text(date.format(d.day), style: theme.textTheme.bodyMedium)),
                              Text(num.format(d.points),
                                  style: theme.textTheme.titleSmall?.copyWith(color: color, fontWeight: FontWeight.w800)),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              );

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              Text(t.statsSince(long.format(st.firstDay!)),
                  style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
              Text(t.statsDaysTracked(st.days.length),
                  style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                  child: Column(
                    children: [
                      stat(t.statsAvg30(st.recent.length), num.format(st.averageRecent ?? 0), big: true),
                      const Divider(),
                      stat(t.statsToday, num.format(widget.todayPoints)),
                      stat(t.statsAvgLifetime, num.format(st.averageLifetime ?? 0)),
                      stat(t.statsTotalPoints, num.format(st.totalPoints + widget.todayPoints)),
                    ],
                  ),
                ),
              ),
              if (st.best.isNotEmpty) ...[
                const SizedBox(height: 12),
                dayList(t.statsBestDays, st.best, Icons.emoji_events_rounded, scheme.primary),
                const SizedBox(height: 12),
                dayList(t.statsWorstDays, st.worst, Icons.trending_down_rounded, scheme.error),
              ],
            ],
          );
        },
      ),
    );
  }
}
