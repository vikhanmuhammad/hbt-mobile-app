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

/// Arah pencapaian target habit. `atLeast` (default, standar) = tercapai
/// kalau progress >= goalValue. `atMost` = tercapai kalau progress <=
/// goalValue — cocok untuk habit dengan target "batas maksimal", misalnya
/// batas pengeluaran harian ("hemat pengeluaran"), bukan habit menabung
/// (yang tetap pakai `atLeast` — makin banyak makin baik).
enum GoalDirection {
  atLeast,
  atMost;

  static GoalDirection fromValue(String value) => GoalDirection.values.firstWhere(
        (e) => e.name == value,
        orElse: () => GoalDirection.atLeast,
      );

  String get label => switch (this) {
        GoalDirection.atLeast => 'Minimal (≥)',
        GoalDirection.atMost => 'Maksimal (≤)',
      };

  String get helperText => switch (this) {
        GoalDirection.atLeast => 'Tercapai kalau hasil mencapai atau melebihi target — standar untuk kebanyakan habit.',
        GoalDirection.atMost =>
          'Tercapai kalau hasil di bawah atau sama dengan target — cocok untuk batas maksimal, misalnya batas pengeluaran harian.',
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
