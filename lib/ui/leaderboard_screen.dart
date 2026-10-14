import 'package:flutter/material.dart';

import '../data/session_repo.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key, required this.repo});
  final SessionRepo repo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Denne uge')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: repo.leaderboard(),
        builder: (context, snap) {
          if (snap.hasError) return Center(child: Text('Fejl: ${snap.error}'));
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final rows = snap.data!;
          return ListView.builder(
            itemCount: rows.length,
            itemBuilder: (context, i) {
              final r = rows[i];
              final hours = (r['minutes'] as int) ~/ 60;
              final mins = (r['minutes'] as int) % 60;
              return ListTile(
                leading: CircleAvatar(child: Text('${i + 1}')),
                title: Text(r['display_name'] as String? ?? r['username'] as String),
                subtitle: Text('${hours}t ${mins}m uden telefon'),
                trailing: Text('${r['points']}', style: Theme.of(context).textTheme.titleLarge),
              );
            },
          );
        },
      ),
    );
  }
}
