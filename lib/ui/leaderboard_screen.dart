import 'package:flutter/material.dart';

import '../data/session_repo.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key, required this.repo});
  final SessionRepo repo;
  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  late Future<List<Map<String, dynamic>>> _future = widget.repo.leaderboard();

  Future<void> _reload() async {
    setState(() => _future = widget.repo.leaderboard());
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _reload,
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _future,
            builder: (context, snap) {
              final rows = snap.data ?? const [];
              return ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                children: [
                  Text('Denne uge', style: theme.textTheme.headlineMedium),
                  Text('Ugens stilling blandt dine venner',
                      style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
                  const SizedBox(height: 24),
                  if (snap.hasError)
                    Text('Kunne ikke hente stillingen.', style: TextStyle(color: scheme.error))
                  else if (!snap.hasData)
                    const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator()))
                  else ...[
                    if (rows.isNotEmpty) _Podium(rows: rows.take(3).toList()),
                    const SizedBox(height: 20),
                    Card(
                      child: Column(
                        children: [
                          for (var i = 0; i < rows.length; i++) ...[
                            _Row(rank: i + 1, row: rows[i]),
                            if (i < rows.length - 1) const Divider(indent: 68),
                          ],
                        ],
                      ),
                    ),
                    if (rows.length <= 1)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Text(
                          'Tilføj venner under "Venner" for at konkurrere.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                      ),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

String _name(Map<String, dynamic> r) => (r['display_name'] as String?) ?? (r['username'] as String);

class _Podium extends StatelessWidget {
  const _Podium({required this.rows});
  final List<Map<String, dynamic>> rows;

  @override
  Widget build(BuildContext context) {
    // Order: 2nd, 1st, 3rd
    final order = [if (rows.length > 1) 1, 0, if (rows.length > 2) 2];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (final i in order) ...[
          _PodiumSpot(rank: i + 1, row: rows[i], size: i == 0 ? 84 : 64),
          const SizedBox(width: 18),
        ],
      ],
    );
  }
}

class _PodiumSpot extends StatelessWidget {
  const _PodiumSpot({required this.rank, required this.row, required this.size});
  final int rank;
  final Map<String, dynamic> row;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final gold = rank == 1;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: gold ? scheme.secondaryContainer : scheme.primaryContainer,
            border: Border.all(color: gold ? scheme.secondary : scheme.primary, width: 2.5),
          ),
          alignment: Alignment.center,
          child: Text(
            _name(row).substring(0, 1).toUpperCase(),
            style: theme.textTheme.headlineMedium?.copyWith(
              color: gold ? scheme.onSecondaryContainer : scheme.onPrimaryContainer,
              fontSize: size * 0.42,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(_name(row), style: theme.textTheme.labelLarge, overflow: TextOverflow.ellipsis),
        Text('${row['points']} pt',
            style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.rank, required this.row});
  final int rank;
  final Map<String, dynamic> row;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final mins = row['minutes'] as int;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text('$rank', style: theme.textTheme.titleMedium?.copyWith(color: scheme.onSurfaceVariant)),
          ),
          CircleAvatar(
            radius: 18,
            backgroundColor: scheme.primaryContainer,
            child: Text(_name(row).substring(0, 1).toUpperCase(),
                style: TextStyle(color: scheme.onPrimaryContainer, fontWeight: FontWeight.w800)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_name(row), style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                Text('${mins ~/ 60}t ${mins % 60}m uden telefon',
                    style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
              ],
            ),
          ),
          Text('${row['points']}',
              style: theme.textTheme.titleMedium?.copyWith(color: scheme.primary, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}
