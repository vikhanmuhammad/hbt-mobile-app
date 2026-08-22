import 'category.dart';
import 'habit.dart';

class HabitStat {
  const HabitStat({
    required this.habit,
    required this.totalLogs,
    required this.doneLogs,
  });

  final Habit habit;
  final int totalLogs;

  /// Jumlah kredit progress (lihat `Habit.progressCredit`), bukan cuma
  /// hitungan hari yang goal-nya sudah 100% tercapai — habit yang baru
  /// mencapai sebagian tetap menyumbang porsinya di sini.
  final double doneLogs;

  double get successRate => totalLogs == 0 ? 0 : doneLogs / totalLogs;
}

class CategoryStat {
  const CategoryStat({
    required this.category,
    required this.totalLogs,
    required this.doneLogs,
  });

  final Category category;
  final int totalLogs;
  final double doneLogs;

  double get successRate => totalLogs == 0 ? 0 : doneLogs / totalLogs;
}

class MonthlyStat {
  const MonthlyStat({
    required this.month,
    required this.totalLogs,
    required this.doneLogs,
  });

  /// Tanggal 1 di bulan terkait, cuma dipakai sebagai kunci/label.
  final DateTime month;
  final int totalLogs;
  final double doneLogs;

  double get successRate => totalLogs == 0 ? 0 : doneLogs / totalLogs;
}

class DashboardSummary {
  const DashboardSummary({
    required this.totalDaysTracked,
    required this.totalLogs,
    required this.doneLogs,
    required this.categoryStats,
    required this.habitStats,
    required this.monthlyStats,
  });

  final int totalDaysTracked;
  final int totalLogs;
  final double doneLogs;
  final List<CategoryStat> categoryStats;
  final List<HabitStat> habitStats;
  final List<MonthlyStat> monthlyStats;

  double get overallSuccessRate => totalLogs == 0 ? 0 : doneLogs / totalLogs;

  static const empty = DashboardSummary(
    totalDaysTracked: 0,
    totalLogs: 0,
    doneLogs: 0.0,
    categoryStats: [],
    habitStats: [],
    monthlyStats: [],
  );
}
