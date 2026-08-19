import 'package:shared_preferences/shared_preferences.dart';

class SettingsRepository {
  SettingsRepository(this._prefs);

  final SharedPreferences _prefs;

  static const _defaultReminderTimeKey = 'default_reminder_time';
  static const _darkModeKey = 'dark_mode_enabled';
  static const _onboardingGoalKey = 'onboarding_goal';
  static const _genderKey = 'onboarding_gender';
  static const _stepsSyncKey = 'health_sync_steps_enabled';
  static const _calendarSyncKey = 'health_sync_calendar_enabled';
  static const _alarmSyncKey = 'health_sync_alarm_enabled';

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

  /// Gender chosen on the "What's your name?" onboarding step — UI-only
  /// signal for now (greeting/illustration personalization), stored as the
  /// raw enum name.
  String? get gender => _prefs.getString(_genderKey);

  Future<void> setGender(String genderName) =>
      _prefs.setString(_genderKey, genderName);

  /// Point 10 — Health/Calendar/Alarm sync toggles, each independently
  /// opt-in and defaulting to off (a device permission prompt is only
  /// triggered the moment the user turns one on).
  bool get stepsSyncEnabled => _prefs.getBool(_stepsSyncKey) ?? false;
  Future<void> setStepsSyncEnabled(bool value) => _prefs.setBool(_stepsSyncKey, value);

  bool get calendarSyncEnabled => _prefs.getBool(_calendarSyncKey) ?? false;
  Future<void> setCalendarSyncEnabled(bool value) => _prefs.setBool(_calendarSyncKey, value);

  bool get alarmSyncEnabled => _prefs.getBool(_alarmSyncKey) ?? false;
  Future<void> setAlarmSyncEnabled(bool value) => _prefs.setBool(_alarmSyncKey, value);
}
