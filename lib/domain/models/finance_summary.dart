import 'habit.dart';

/// Agregat satu habit keuangan (bersatuan rupiah) dalam suatu periode.
/// `totalTarget` = goalValue * loggedDays — dasar bandingan buat progress bar
/// (bukan target penuh sebulan, supaya adil untuk periode yang baru berjalan
/// sebagian atau habit yang baru dibuat di tengah bulan).
class FinanceHabitStat {
  const FinanceHabitStat({
    required this.habit,
    required this.totalValue,
    required this.totalTarget,
    required this.loggedDays,
    required this.achievedDays,
  });

  final Habit habit;
  final int totalValue;
  final int totalTarget;
  final int loggedDays;
  final int achievedDays;

  double get successRate => loggedDays == 0 ? 0 : achievedDays / loggedDays;
}

/// Total pengeluaran (habit `atMost`) pada satu tanggal — dasar tren harian.
class FinanceDayPoint {
  const FinanceDayPoint({required this.date, required this.totalExpense});

  final DateTime date;
  final int totalExpense;
}

/// Rangkuman keuangan untuk satu periode (biasanya 1 bulan kalender),
/// mencakup semua habit bersatuan rupiah lintas kategori. Habit `atMost`
/// (mis. batas pengeluaran harian) dihitung sebagai pengeluaran & budget;
/// habit `atLeast` (mis. target tabungan) dihitung sebagai setoran tabungan.
class FinanceSummary {
  const FinanceSummary({
    required this.periodStart,
    required this.periodEndInclusive,
    required this.totalExpense,
    required this.totalBudget,
    required this.totalSavingsDeposit,
    required this.habitStats,
    required this.dailyTrend,
  });

  final DateTime periodStart;
  final DateTime periodEndInclusive;

  /// Jumlah yang dihabiskan (sum progressValue) dari habit `atMost`.
  final int totalExpense;

  /// Jumlah batas/anggaran (sum goalValue*loggedDays) dari habit `atMost`.
  final int totalBudget;

  /// Jumlah yang disetor (sum progressValue) dari habit `atLeast` rupiah,
  /// mis. habit "Nabung" yang dibuat bersatuan rupiah.
  final int totalSavingsDeposit;

  final List<FinanceHabitStat> habitStats;
  final List<FinanceDayPoint> dailyTrend;

  /// Selisih budget - pengeluaran. Positif = hemat, negatif = kelebihan budget.
  int get totalSaved => totalBudget - totalExpense;

  bool get hasData => habitStats.isNotEmpty;

  static final empty = FinanceSummary(
    periodStart: DateTime(2000),
    periodEndInclusive: DateTime(2000),
    totalExpense: 0,
    totalBudget: 0,
    totalSavingsDeposit: 0,
    habitStats: const [],
    dailyTrend: const [],
  );
}
