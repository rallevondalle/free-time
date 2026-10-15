import 'dart:io';

import 'package:flutter/material.dart';

import '../core/settings.dart';
import '../main.dart' show offlineMode;
import '../data/friends_repo.dart';
import '../data/session_repo.dart';
import 'friends_screen.dart';
import 'home_screen.dart';
import 'l10n_ext.dart';
import 'leaderboard_screen.dart';
import 'more_screen.dart';

/// Bottom navigation + first-run profile creation.
class Shell extends StatefulWidget {
  const Shell({super.key, required this.sessions, required this.friends, required this.settings});
  final SessionRepo sessions;
  final FriendsRepo? friends; // null in offline mode
  final Settings settings;

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
    if (f == null || widget.settings.hasProfileCached) {
      _hasProfile = true;
    } else {
      // No network (airplane mode) must never leave the user on a spinner.
      f.myProfile().timeout(const Duration(seconds: 5)).then((p) {
        if (p != null) widget.settings.setHasProfileCached(true);
        if (mounted) setState(() => _hasProfile = p != null);
      }).catchError((_) {
        if (mounted) setState(() => _hasProfile = true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    if (_hasProfile == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_hasProfile == false) {
      return _CreateProfile(
        friends: widget.friends!,
        onDone: () {
          widget.settings.setHasProfileCached(true);
          setState(() => _hasProfile = true);
        },
      );
    }
    final pages = [
      HomeScreen(repo: widget.sessions, settings: widget.settings),
      LeaderboardScreen(repo: widget.sessions),
      FriendsScreen(repo: widget.friends),
      MoreScreen(settings: widget.settings, signedIn: widget.friends != null, canSignIn: widget.friends == null && !offlineMode),
    ];
    return Scaffold(
      body: pages[_tab],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: [
          NavigationDestination(icon: const Icon(Icons.spa_outlined), selectedIcon: const Icon(Icons.spa_rounded), label: t.navToday),
          NavigationDestination(icon: const Icon(Icons.emoji_events_outlined), selectedIcon: const Icon(Icons.emoji_events_rounded), label: t.navWeek),
          NavigationDestination(icon: const Icon(Icons.people_outline_rounded), selectedIcon: const Icon(Icons.people_rounded), label: t.navFriends),
          NavigationDestination(icon: const Icon(Icons.more_horiz_rounded), selectedIcon: const Icon(Icons.more_horiz_rounded), label: t.navMore),
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
  bool _error = false;

  Future<void> _save() async {
    try {
      await widget.friends.createProfile(
        _name.text.trim().toLowerCase(),
        platform: Platform.isIOS ? 'ios' : 'android',
      );
      widget.onDone();
    } catch (e) {
      setState(() => _error = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.l10n;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(t.chooseUsername, style: theme.textTheme.headlineMedium),
              const SizedBox(height: 6),
              Text(t.chooseUsernameHint,
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              const SizedBox(height: 24),
              TextField(
                controller: _name,
                autocorrect: false,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _save(),
                decoration: InputDecoration(hintText: t.usernameHint, prefixText: '@'),
              ),
              const SizedBox(height: 16),
              FilledButton(onPressed: _save, child: Text(t.save)),
              if (_error) ...[
                const SizedBox(height: 16),
                Text(t.usernameTaken, style: TextStyle(color: theme.colorScheme.error)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
