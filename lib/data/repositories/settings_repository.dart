import 'package:shared_preferences/shared_preferences.dart';

class SettingsRepository {
  SettingsRepository(this._prefs);

  final SharedPreferences _prefs;

  static const _defaultReminderTimeKey = 'default_reminder_time';
  static const _darkModeKey = 'dark_mode_enabled';
  static const _onboardingGoalKey = 'onboarding_goal';

  String? get defaultReminderTime => _prefs.getString(_defaultReminderTimeKey);

  Future<void> setDefaultReminderTime(String time) =>
      _prefs.setString(_defaultReminderTimeKey, time);

  /// null = ikuti tema sistem, belum pernah diubah manual dari Settings.
  bool? get darkModeEnabled =>
      _prefs.containsKey(_darkModeKey) ? _prefs.getBool(_darkModeKey) : null;

  Future<void> setDarkModeEnabled(bool enabled) =>
      _prefs.setBool(_darkModeKey, enabled);

  /// Goal chosen on the "What's your name?" onboarding step (e.g. "Kesehatan
  /// & Olahraga") — UI-only signal for now, not yet wired into
  /// recommendation logic.
  String? get onboardingGoal => _prefs.getString(_onboardingGoalKey);

  Future<void> setOnboardingGoal(String goal) =>
      _prefs.setString(_onboardingGoalKey, goal);
}
