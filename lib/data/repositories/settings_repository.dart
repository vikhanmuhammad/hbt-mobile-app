import 'package:shared_preferences/shared_preferences.dart';

class SettingsRepository {
  SettingsRepository(this._prefs);

  final SharedPreferences _prefs;

  static const _onboardingDoneKey = 'onboarding_done';
  static const _defaultReminderTimeKey = 'default_reminder_time';

  bool get hasCompletedOnboarding =>
      _prefs.getBool(_onboardingDoneKey) ?? false;

  Future<void> setOnboardingComplete() =>
      _prefs.setBool(_onboardingDoneKey, true);

  String? get defaultReminderTime => _prefs.getString(_defaultReminderTimeKey);

  Future<void> setDefaultReminderTime(String time) =>
      _prefs.setString(_defaultReminderTimeKey, time);
}
