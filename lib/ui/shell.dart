import 'dart:io';

import 'package:flutter/material.dart';

import '../core/settings.dart';
import '../data/friends_repo.dart';
import '../data/session_repo.dart';
import 'friends_screen.dart';
import 'home_screen.dart';
import 'leaderboard_screen.dart';
import 'more_screen.dart';

/// Bottom navigation + first-run profile creation.
class Shell extends StatefulWidget {
  const Shell({super.key, required this.sessions, required this.friends, required this.settings});
  final SessionRepo sessions;
  final Settings settings;
  final FriendsRepo? friends; // null in offline mode

  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int _tab = 0;
  bool? _hasProfile;

  @override
  void initState() {
    super.initState();
    final f = widget.friends;
    if (f == null) {
      _hasProfile = true;
    } else {
      f.myProfile().then((p) => setState(() => _hasProfile = p != null));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasProfile == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_hasProfile == false) {
      return _CreateProfile(
        friends: widget.friends!,
        onDone: () => setState(() => _hasProfile = true),
      );
    }
    final pages = [
      HomeScreen(repo: widget.sessions, settings: widget.settings),
      LeaderboardScreen(repo: widget.sessions),
      FriendsScreen(repo: widget.friends),
      MoreScreen(settings: widget.settings, signedIn: widget.friends != null),
    ];
    return Scaffold(
      body: pages[_tab],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.spa_outlined), selectedIcon: Icon(Icons.spa_rounded), label: 'I dag'),
          NavigationDestination(icon: Icon(Icons.emoji_events_outlined), selectedIcon: Icon(Icons.emoji_events_rounded), label: 'Ugen'),
          NavigationDestination(icon: Icon(Icons.people_outline_rounded), selectedIcon: Icon(Icons.people_rounded), label: 'Venner'),
          NavigationDestination(icon: Icon(Icons.more_horiz_rounded), selectedIcon: Icon(Icons.more_horiz_rounded), label: 'Mere'),
        ],
      ),
    );
  }
}

class _CreateProfile extends StatefulWidget {
  const _CreateProfile({required this.friends, required this.onDone});
  final FriendsRepo friends;
  final VoidCallback onDone;
  @override
  State<_CreateProfile> createState() => _CreateProfileState();
}

class _CreateProfileState extends State<_CreateProfile> {
  final _name = TextEditingController();
  String? _error;

  Future<void> _save() async {
    try {
      await widget.friends.createProfile(
        _name.text.trim().toLowerCase(),
        platform: Platform.isIOS ? 'ios' : 'android',
      );
      widget.onDone();
    } catch (e) {
      setState(() => _error = 'Brugernavn er optaget eller ugyldigt (a-z, 0-9, _, 3-20 tegn).');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Vælg brugernavn', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 6),
            Text('Det er sådan, dine venner finder dig.',
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 24),
            TextField(
              controller: _name,
              autocorrect: false,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _save(),
              decoration: const InputDecoration(hintText: 'brugernavn', prefixText: '@'),
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: _save, child: const Text('Gem')),
            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ],
          ],
        ),
        ),
      ),
    );
  }
}
