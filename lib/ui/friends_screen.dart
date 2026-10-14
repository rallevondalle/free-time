import 'package:flutter/material.dart';

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
  Map<String, dynamic>? _me;
  String? _msg;
  bool _ok = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = widget.repo;
    if (repo == null) return;
    final inc = await repo.incoming();
    final me = await repo.myProfile();
    if (mounted) setState(() { _incoming = inc; _me = me; });
  }

  Future<void> _add() async {
    final name = _username.text.trim().toLowerCase();
    if (name.isEmpty) return;
    try {
      await widget.repo!.sendRequest(name);
      setState(() { _msg = 'Anmodning sendt til $name.'; _ok = true; });
      _username.clear();
    } catch (e) {
      setState(() { _msg = 'Fandt ingen bruger med navnet "$name".'; _ok = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final repo = widget.repo;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            Text('Venner', style: theme.textTheme.headlineMedium),
            Text(
              repo == null ? 'Offline-tilstand' : 'Inviter venner og se, hvem der lægger telefonen mest.',
              style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            if (repo == null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'Appen er bygget uden backend. Venner og leaderboard kommer, når Supabase er koblet på.',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              )
            else ...[
              // ---- me ----
              if (_me != null)
                Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    leading: CircleAvatar(
                      backgroundColor: scheme.primaryContainer,
                      child: Text((_me!['username'] as String).substring(0, 1).toUpperCase(),
                          style: TextStyle(color: scheme.onPrimaryContainer, fontWeight: FontWeight.w800)),
                    ),
                    title: Text('@${_me!['username']}', style: theme.textTheme.titleMedium),
                    subtitle: Text('Dit brugernavn. Del det med venner.',
                        style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
                  ),
                ),
              const SizedBox(height: 20),

              // ---- add ----
              Text('Tilføj ven', style: theme.textTheme.titleMedium),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _username,
                      autocorrect: false,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _add(),
                      decoration: const InputDecoration(hintText: 'brugernavn', prefixText: '@'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    height: 54,
                    child: FilledButton(
                      onPressed: _add,
                      style: FilledButton.styleFrom(minimumSize: const Size(54, 54), padding: EdgeInsets.zero),
                      child: const Icon(Icons.person_add_alt_1_rounded),
                    ),
                  ),
                ],
              ),
              if (_msg != null)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(_msg!, style: theme.textTheme.bodySmall?.copyWith(color: _ok ? scheme.primary : scheme.error)),
                ),
              const SizedBox(height: 28),

              // ---- incoming ----
              if (_incoming.isNotEmpty) ...[
                Text('Anmodninger', style: theme.textTheme.titleMedium),
                const SizedBox(height: 10),
                Card(
                  child: Column(
                    children: [
                      for (var i = 0; i < _incoming.length; i++) ...[
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          title: Text('@${(_incoming[i]['profiles'] as Map)['username']}',
                              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                          trailing: FilledButton.tonal(
                            style: FilledButton.styleFrom(minimumSize: const Size(0, 40)),
                            onPressed: () async {
                              await repo.accept(_incoming[i]['requester_id'] as String);
                              _load();
                            },
                            child: const Text('Accepter'),
                          ),
                        ),
                        if (i < _incoming.length - 1) const Divider(indent: 16),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 28),
              ],

            ],
          ],
        ),
      ),
    );
  }
}
