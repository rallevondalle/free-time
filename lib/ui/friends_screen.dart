import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/friends_repo.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key, required this.repo});
  final FriendsRepo? repo; // null in offline mode
  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  final _username = TextEditingController();
  List<Map<String, dynamic>> _incoming = const [];
  String? _msg;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = widget.repo;
    if (repo == null) return;
    final inc = await repo.incoming();
    if (mounted) setState(() => _incoming = inc);
  }

  Future<void> _add() async {
    try {
      await widget.repo!.sendRequest(_username.text.trim().toLowerCase());
      setState(() => _msg = 'Anmodning sendt.');
      _username.clear();
    } catch (e) {
      setState(() => _msg = '$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.repo == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Venner')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Offline-tilstand: appen er bygget uden Supabase. '
              'Venner og leaderboard kommer, når backend er koblet på.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Venner'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Supabase.instance.client.auth.signOut(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _username,
                  autocorrect: false,
                  decoration: const InputDecoration(labelText: 'Tilføj ven (brugernavn)'),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(onPressed: _add, child: const Text('Send')),
            ],
          ),
          if (_msg != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(_msg!)),
          const SizedBox(height: 24),
          if (_incoming.isNotEmpty) Text('Anmodninger', style: Theme.of(context).textTheme.titleMedium),
          for (final r in _incoming)
            ListTile(
              title: Text((r['profiles'] as Map)['username'] as String),
              trailing: FilledButton.tonal(
                onPressed: () async {
                  await widget.repo!.accept(r['requester_id'] as String);
                  _load();
                },
                child: const Text('Accepter'),
              ),
            ),
        ],
      ),
    );
  }
}
