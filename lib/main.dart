import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config.dart';
import 'core/settings.dart';
import 'data/friends_repo.dart';
import 'data/session_repo.dart';
import 'ui/auth_screen.dart';
import 'ui/shell.dart';
import 'ui/theme.dart';
import 'l10n/app_localizations.dart';

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
    final settings = Settings(prefs);
    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) => MaterialApp(
        title: 'Free Time',
        theme: buildTheme(Brightness.light),
        darkTheme: buildTheme(Brightness.dark),
        locale: settings.locale,
        supportedLocales: Settings.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: offlineMode ? _offline(settings) : _online(settings),
      ),
    );
  }

  Widget _offline(Settings settings) =>
      Shell(sessions: LocalSessionRepo(prefs), friends: null, settings: settings);

  Widget _online(Settings settings) {
    final client = Supabase.instance.client;
    return StreamBuilder<AuthState>(
      stream: client.auth.onAuthStateChange,
      builder: (context, _) {
        if (client.auth.currentSession == null) return const AuthScreen();
        return Shell(
          sessions: SupabaseSessionRepo(client, prefs),
          friends: FriendsRepo(client),
          settings: settings,
        );
      },
    );
  }
}
