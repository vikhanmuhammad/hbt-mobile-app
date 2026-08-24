import '../format_utils.dart';
import '../language.dart';
import 'enums.dart';

class Habit {
  const Habit({
    required this.id,
    required this.categoryId,
    required this.name,
    this.description,
    this.icon,
    required this.goalPeriod,
    required this.goalValue,
    this.goalUnit = 'x',
    this.goalDirection = GoalDirection.atLeast,
    required this.taskDays,
    required this.timeRange,
    required this.reminderEnabled,
    this.reminderTime,
    this.reminderIntervalMinutes,
    required this.startDate,
    this.endDate,
    required this.isActive,
    this.sortOrder = 0,
    required this.createdAt,
    this.nameId,
    this.isCustom = true,
    this.templateKey,
  });

  final int id;
  final int categoryId;
  final String name;
  final String? description;
  final String? icon;
  final GoalPeriod goalPeriod;
  final int goalValue;
  final String goalUnit;
  final GoalDirection goalDirection;
  final List<String> taskDays;
  final TimeRange timeRange;
  final bool reminderEnabled;
  final String? reminderTime;

  /// Minutes between repeats starting at [reminderTime] — null means a
  /// single reminder at that time (the original behavior). No end time:
  /// repeats until the end of the day.
  final int? reminderIntervalMinutes;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isActive;
  final int sortOrder;
  final DateTime createdAt;

  /// Terjemahan Indonesia dari [name] — null kalau belum diisi (habit
  /// lama/custom), fallback ke [name] lewat [displayName].
  final String? nameId;

  /// False kalau title berasal dari template bawaan yang sudah
  /// dikonfirmasi (lihat backfill di `HabitRepository`) — title bawaan
  /// dikunci dari edit. Default true (bisa diedit) supaya habit yang gagal
  /// dicocokkan ke template tidak tiba-tiba terkunci tanpa alasan jelas.
  final bool isCustom;

  /// Key stabil ke entri habit di `habit_templates.json`. Null untuk habit
  /// custom buatan user.
  final String? templateKey;

  String displayName(AppLang lang) =>
      lang == AppLang.id ? (nameId ?? name) : name;

  bool get isRupiah => goalUnit == 'rupiah';

  /// Mis. "8 gelas", "1x", atau "Rp 50.000" untuk satuan rupiah, persis
  /// format `unitLabel` di prototipe. Diberi prefix "Maks." untuk habit
  /// `atMost` (mis. batas pengeluaran) supaya arah target langsung jelas
  /// dibaca.
  String get goalValueLabel {
    final value = isRupiah
        ? formatRupiah(goalValue)
        : (goalUnit == 'x' ? '${goalValue}x' : '$goalValue $goalUnit');
    return goalDirection == GoalDirection.atMost ? 'Maks. $value' : value;
  }

  String goalLabel(AppLang lang) => '$goalValueLabel • ${goalPeriod.label(lang)}';

  /// Satu sumber kebenaran untuk "tercapai atau belum" — dipakai baik saat
  /// menyimpan progress (`HabitLogRepository.setProgress`) maupun di tempat
  /// lain yang perlu mengevaluasi ulang. `atLeast` (standar): tercapai kalau
  /// progress >= goalValue. `atMost` (mis. batas pengeluaran harian):
  /// tercapai kalau progress <= goalValue.
  bool isAchieved(int progressValue) => goalDirection == GoalDirection.atMost
      ? progressValue <= goalValue
      : progressValue >= goalValue;

  /// Kontribusi [progressValue] terhadap goal, 0.0-1.0 — dipakai stats/
  /// Dashboard supaya habit yang belum tercapai (mis. 4 dari target 10)
  /// tetap tercatat sebagian, bukan cuma dihitung kalau sudah `isAchieved`
  /// penuh. Untuk `atMost` (batas maksimum) tetap biner: progres di bawah
  /// limit tidak punya "porsi" yang natural untuk dihitung parsial.
  double progressCredit(int progressValue) {
    if (goalDirection == GoalDirection.atMost || goalValue <= 0) {
      return isAchieved(progressValue) ? 1.0 : 0.0;
    }
    return (progressValue / goalValue).clamp(0.0, 1.0);
  }
}
