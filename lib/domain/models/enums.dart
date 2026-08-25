import '../language.dart';

enum GoalPeriod {
  daily,
  weekly,
  monthly;

  static GoalPeriod fromValue(String value) => GoalPeriod.values.firstWhere(
        (e) => e.name == value,
        orElse: () => GoalPeriod.daily,
      );

  String label(AppLang lang) => switch (lang) {
        AppLang.en => switch (this) {
            GoalPeriod.daily => 'Daily',
            GoalPeriod.weekly => 'Weekly',
            GoalPeriod.monthly => 'Monthly',
          },
        AppLang.id => switch (this) {
            GoalPeriod.daily => 'Harian',
            GoalPeriod.weekly => 'Mingguan',
            GoalPeriod.monthly => 'Bulanan',
          },
      };

  String get unitLabel => switch (this) {
        GoalPeriod.daily => 'day',
        GoalPeriod.weekly => 'week',
        GoalPeriod.monthly => 'month',
      };
}

enum TimeRange {
  anytime,
  morning,
  afternoon,
  evening,
  night;

  static TimeRange fromValue(String value) => TimeRange.values.firstWhere(
        (e) => e.name == value,
        orElse: () => TimeRange.anytime,
      );

  String label(AppLang lang) => switch (lang) {
        AppLang.en => switch (this) {
            TimeRange.anytime => 'Anytime',
            TimeRange.morning => 'Morning',
            TimeRange.afternoon => 'Afternoon',
            TimeRange.evening => 'Evening',
            TimeRange.night => 'Night',
          },
        AppLang.id => switch (this) {
            TimeRange.anytime => 'Kapan saja',
            TimeRange.morning => 'Pagi',
            TimeRange.afternoon => 'Siang',
            TimeRange.evening => 'Sore',
            TimeRange.night => 'Malam',
          },
      };
}

/// Direction for achieving a habit's goal. `atLeast` (default, standard) =
/// achieved when progress >= goalValue. `atMost` = achieved when progress
/// <= goalValue — suited for habits with a "maximum limit" target, e.g. a
/// daily spending cap ("save on spending"), not a saving habit (which still
/// uses `atLeast` — more is better).
enum GoalDirection {
  atLeast,
  atMost;

  static GoalDirection fromValue(String value) => GoalDirection.values.firstWhere(
        (e) => e.name == value,
        orElse: () => GoalDirection.atLeast,
      );

  String label(AppLang lang) => switch (lang) {
        AppLang.en => switch (this) {
            GoalDirection.atLeast => 'At least (≥)',
            GoalDirection.atMost => 'At most (≤)',
          },
        AppLang.id => switch (this) {
            GoalDirection.atLeast => 'Minimal (≥)',
            GoalDirection.atMost => 'Maksimal (≤)',
          },
      };

  String helperText(AppLang lang) => switch (lang) {
        AppLang.en => switch (this) {
            GoalDirection.atLeast =>
              'Achieved when the result reaches or exceeds the target — the standard for most habits.',
            GoalDirection.atMost =>
              'Achieved when the result is at or below the target — suited for a maximum limit, such as a daily spending cap.',
          },
        AppLang.id => switch (this) {
            GoalDirection.atLeast =>
              'Tercapai kalau hasilnya mencapai atau melebihi target — standar untuk kebanyakan habit.',
            GoalDirection.atMost =>
              'Tercapai kalau hasilnya di bawah atau sama dengan target — cocok untuk batas maksimum, seperti batas pengeluaran harian.',
          },
      };
}

/// Optional category for a single spending-breakdown entry (see
/// `SpendingBreakdownEntry`) — lets a user optionally split one logged
/// expense (e.g. Rp50.000) into where it actually went (e.g. Rp30.000 food +
/// Rp20.000 fuel), each tagged with one of these templates, or `custom` with
/// a free-text label.
enum SpendingBreakdownCategory {
  dailyNeeds,
  urgent,
  health,
  custom;

  static SpendingBreakdownCategory fromValue(String value) =>
      SpendingBreakdownCategory.values.firstWhere(
        (e) => e.name == value,
        orElse: () => SpendingBreakdownCategory.custom,
      );

  String label(AppLang lang) => switch (lang) {
        AppLang.en => switch (this) {
            SpendingBreakdownCategory.dailyNeeds => 'Daily Needs',
            SpendingBreakdownCategory.urgent => 'Unexpected Needs',
            SpendingBreakdownCategory.health => 'Health',
            SpendingBreakdownCategory.custom => 'Custom',
          },
        AppLang.id => switch (this) {
            SpendingBreakdownCategory.dailyNeeds => 'Kebutuhan Harian',
            SpendingBreakdownCategory.urgent => 'Kebutuhan Mendadak',
            SpendingBreakdownCategory.health => 'Kesehatan',
            SpendingBreakdownCategory.custom => 'Kustom',
          },
      };

  /// Short example text shown under the category chip, e.g. "food,
  /// transport" — purely descriptive, not stored anywhere.
  String? hint(AppLang lang) => switch (lang) {
        AppLang.en => switch (this) {
            SpendingBreakdownCategory.dailyNeeds => 'e.g. food, transport',
            SpendingBreakdownCategory.health => 'e.g. gym membership',
            _ => null,
          },
        AppLang.id => switch (this) {
            SpendingBreakdownCategory.dailyNeeds => 'mis. makan, transport',
            SpendingBreakdownCategory.health => 'mis. membership gym',
            _ => null,
          },
      };
}

/// Weekday keys Monday..Sunday, aligned with `DateTime.weekday` (1 = Monday).
const List<String> weekdayKeys = [
  'mon',
  'tue',
  'wed',
  'thu',
  'fri',
  'sat',
  'sun',
];

const Map<String, String> weekdayLabels = {
  'mon': 'Mon',
  'tue': 'Tue',
  'wed': 'Wed',
  'thu': 'Thu',
  'fri': 'Fri',
  'sat': 'Sat',
  'sun': 'Sun',
};

const Map<String, String> weekdayLabelsId = {
  'mon': 'Sen',
  'tue': 'Sel',
  'wed': 'Rab',
  'thu': 'Kam',
  'fri': 'Jum',
  'sat': 'Sab',
  'sun': 'Min',
};

String weekdayLabel(String key, AppLang lang) =>
    (lang == AppLang.id ? weekdayLabelsId : weekdayLabels)[key]!;

const String allDaysKey = 'all';
