import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Per-device settings. Small on purpose.
class Settings extends ChangeNotifier {
  Settings(this._prefs);
  final SharedPreferences _prefs;

  static const defaultGoal = 600;
  static const goalPresets = [300, 600, 900, 1200, 1800];

  int get dailyGoal => _prefs.getInt('daily_goal') ?? defaultGoal;

  Future<void> setDailyGoal(int v) async {
    await _prefs.setInt('daily_goal', v.clamp(60, 10000));
    notifyListeners();
  }
}
