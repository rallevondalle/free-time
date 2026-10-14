import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Per-device settings. Small on purpose.
class Settings extends ChangeNotifier {
  Settings(this._prefs);
  final SharedPreferences _prefs;

  static const defaultGoal = 600;
  static const goalPresets = [300, 600, 900, 1200, 1800];
  static const supportedLocales = [Locale('en'), Locale('da'), Locale('de'), Locale('fr'), Locale('nl')];
  static const localeNames = {'da': 'Dansk', 'en': 'English', 'de': 'Deutsch', 'fr': 'Français', 'nl': 'Nederlands'};

  int get dailyGoal => _prefs.getInt('daily_goal') ?? defaultGoal;

  Future<void> setDailyGoal(int v) async {
    await _prefs.setInt('daily_goal', v.clamp(60, 10000));
    notifyListeners();
  }

  /// null = follow the system language.
  Locale? get locale {
    final code = _prefs.getString('locale');
    return code == null ? null : Locale(code);
  }

  Future<void> setLocale(Locale? l) async {
    if (l == null) {
      await _prefs.remove('locale');
    } else {
      await _prefs.setString('locale', l.languageCode);
    }
    notifyListeners();
  }
}
