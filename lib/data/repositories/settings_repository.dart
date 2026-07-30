import 'package:shared_preferences/shared_preferences.dart';

class SettingsRepository {
  SettingsRepository(this._prefs);

  final SharedPreferences _prefs;

  static const _onboardingDoneKey = 'onboarding_done';
  static const _defaultReminderTimeKey = 'default_reminder_time';
  static const _darkModeKey = 'dark_mode_enabled';

  bool get hasCompletedOnboarding =>
      _prefs.getBool(_onboardingDoneKey) ?? false;

  Future<void> setOnboardingComplete() =>
      _prefs.setBool(_onboardingDoneKey, true);

  Future<void> resetOnboarding() => _prefs.remove(_onboardingDoneKey);

  String? get defaultReminderTime => _prefs.getString(_defaultReminderTimeKey);

  Future<void> setDefaultReminderTime(String time) =>
      _prefs.setString(_defaultReminderTimeKey, time);

  /// null = ikuti tema sistem, belum pernah diubah manual dari Settings.
  bool? get darkModeEnabled =>
      _prefs.containsKey(_darkModeKey) ? _prefs.getBool(_darkModeKey) : null;

  Future<void> setDarkModeEnabled(bool enabled) =>
      _prefs.setBool(_darkModeKey, enabled);
}
