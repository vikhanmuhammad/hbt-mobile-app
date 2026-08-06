import '../format_utils.dart';
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
    required this.startDate,
    this.endDate,
    required this.isActive,
    this.sortOrder = 0,
    required this.createdAt,
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
  final DateTime startDate;
  final DateTime? endDate;
  final bool isActive;
  final int sortOrder;
  final DateTime createdAt;

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

  String get goalLabel => '$goalValueLabel • ${goalPeriod.label}';

  /// Satu sumber kebenaran untuk "tercapai atau belum" — dipakai baik saat
  /// menyimpan progress (`HabitLogRepository.setProgress`) maupun di tempat
  /// lain yang perlu mengevaluasi ulang. `atLeast` (standar): tercapai kalau
  /// progress >= goalValue. `atMost` (mis. batas pengeluaran harian):
  /// tercapai kalau progress <= goalValue.
  bool isAchieved(int progressValue) => goalDirection == GoalDirection.atMost
      ? progressValue <= goalValue
      : progressValue >= goalValue;
}
