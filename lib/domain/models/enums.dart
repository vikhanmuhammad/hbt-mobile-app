enum GoalPeriod {
  daily,
  weekly,
  monthly;

  static GoalPeriod fromValue(String value) => GoalPeriod.values.firstWhere(
        (e) => e.name == value,
        orElse: () => GoalPeriod.daily,
      );

  String get label => switch (this) {
        GoalPeriod.daily => 'Daily',
        GoalPeriod.weekly => 'Weekly',
        GoalPeriod.monthly => 'Monthly',
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

  String get label => switch (this) {
        TimeRange.anytime => 'Anytime',
        TimeRange.morning => 'Morning',
        TimeRange.afternoon => 'Afternoon',
        TimeRange.evening => 'Evening',
        TimeRange.night => 'Night',
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

  String get label => switch (this) {
        GoalDirection.atLeast => 'At least (≥)',
        GoalDirection.atMost => 'At most (≤)',
      };

  String get helperText => switch (this) {
        GoalDirection.atLeast => 'Achieved when the result reaches or exceeds the target — the standard for most habits.',
        GoalDirection.atMost =>
          'Achieved when the result is at or below the target — suited for a maximum limit, such as a daily spending cap.',
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

const String allDaysKey = 'all';
