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
