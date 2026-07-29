enum GoalPeriod {
  daily,
  weekly,
  monthly;

  static GoalPeriod fromValue(String value) => GoalPeriod.values.firstWhere(
        (e) => e.name == value,
        orElse: () => GoalPeriod.daily,
      );

  String get label => switch (this) {
        GoalPeriod.daily => 'Harian',
        GoalPeriod.weekly => 'Mingguan',
        GoalPeriod.monthly => 'Bulanan',
      };

  String get unitLabel => switch (this) {
        GoalPeriod.daily => 'hari',
        GoalPeriod.weekly => 'minggu',
        GoalPeriod.monthly => 'bulan',
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
        TimeRange.anytime => 'Kapan saja',
        TimeRange.morning => 'Pagi',
        TimeRange.afternoon => 'Siang',
        TimeRange.evening => 'Sore',
        TimeRange.night => 'Malam',
      };
}

/// Kunci hari Senin..Minggu, selaras dengan `DateTime.weekday` (1 = Senin).
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
  'mon': 'Sen',
  'tue': 'Sel',
  'wed': 'Rab',
  'thu': 'Kam',
  'fri': 'Jum',
  'sat': 'Sab',
  'sun': 'Min',
};

const String allDaysKey = 'all';
