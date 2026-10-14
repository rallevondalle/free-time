import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config.dart';
import 'core/settings.dart';
import 'data/friends_repo.dart';
import 'data/session_repo.dart';
import 'ui/auth_screen.dart';
import 'ui/shell.dart';
import 'ui/theme.dart';

/// Built without a Supabase key → offline mode, no login, local storage only.
final bool offlineMode = supabaseKey.isEmpty;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!offlineMode) {
    await Supabase.initialize(url: supabaseUrl, publishableKey: supabaseKey);
  }
  final prefs = await SharedPreferences.getInstance();
  runApp(FreeTimeApp(prefs: prefs));
}

class FreeTimeApp extends StatelessWidget {
  const FreeTimeApp({super.key, required this.prefs});
  final SharedPreferences prefs;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Free Time',
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      home: offlineMode ? _offline() : _online(),
    );
  }

  Widget _offline() => Shell(sessions: LocalSessionRepo(prefs), friends: null, settings: Settings(prefs));

  Widget _online() {
    final client = Supabase.instance.client;
    return StreamBuilder<AuthState>(
      stream: client.auth.onAuthStateChange,
      builder: (context, _) {
        if (client.auth.currentSession == null) return const AuthScreen();
        return Shell(
          sessions: SupabaseSessionRepo(client, prefs),
          friends: FriendsRepo(client),
          settings: Settings(prefs),
        );
      },
    );
  }
}
