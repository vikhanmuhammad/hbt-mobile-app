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
  static const _languageKey = 'app_language';
  static const _templateBackfillDoneKey = 'template_backfill_done';
  static const _cachedThemeKeyKey = 'cached_theme_key';

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

  /// Clears the previously chosen gender — used when replaying onboarding
  /// from Settings ("Lihat ulang alur onboarding (demo)"). Without this,
  /// `deleteAllData()` wipes the Drift DB but leaves this SharedPreferences
  /// key behind, so the "What's your name?" step's gender dropdown comes
  /// back pre-selected with the old value instead of its "select gender"
  /// hint, even though every habit/category/profile was reset.
  Future<void> clearGender() => _prefs.remove(_genderKey);

  /// Point 10 — Health/Calendar/Alarm sync toggles, each independently
  /// opt-in and defaulting to off (a device permission prompt is only
  /// triggered the moment the user turns one on).
  bool get stepsSyncEnabled => _prefs.getBool(_stepsSyncKey) ?? false;
  Future<void> setStepsSyncEnabled(bool value) => _prefs.setBool(_stepsSyncKey, value);

  bool get calendarSyncEnabled => _prefs.getBool(_calendarSyncKey) ?? false;
  Future<void> setCalendarSyncEnabled(bool value) => _prefs.setBool(_calendarSyncKey, value);

  bool get alarmSyncEnabled => _prefs.getBool(_alarmSyncKey) ?? false;
  Future<void> setAlarmSyncEnabled(bool value) => _prefs.setBool(_alarmSyncKey, value);

  /// Bahasa tampilan aplikasi ('en'/'id') — setting global persisten,
  /// dipakai di seluruh app (bukan cuma onboarding). Default 'en' supaya
  /// tampilan awal tidak berubah untuk instalasi yang sudah ada.
  String get language => _prefs.getString(_languageKey) ?? 'en';
  Future<void> setLanguage(String code) => _prefs.setString(_languageKey, code);

  /// True setelah routine backfill sekali-jalan (cocokkan habit/kategori
  /// lama ke `habit_templates.json` untuk mengisi isCustom/templateKey/
  /// nameId) selesai dijalankan — mencegah pengulangan di setiap start.
  bool get templateBackfillDone => _prefs.getBool(_templateBackfillDoneKey) ?? false;
  Future<void> setTemplateBackfillDone(bool value) =>
      _prefs.setBool(_templateBackfillDoneKey, value);

  /// Last-known `UserProfile.themeKey`, mirrored here purely so the splash
  /// screen/first frame can pick the right accent color synchronously —
  /// `UserProfile` itself only loads asynchronously (Drift stream), which
  /// otherwise leaves a brief flash of the default gold palette before the
  /// real one arrives. Null until the user has ever had a saved theme.
  String? get cachedThemeKey => _prefs.getString(_cachedThemeKeyKey);
  Future<void> setCachedThemeKey(String key) => _prefs.setString(_cachedThemeKeyKey, key);
}
