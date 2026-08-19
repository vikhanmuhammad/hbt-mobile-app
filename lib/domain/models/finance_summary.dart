import 'habit.dart';

/// Result of comparing "how far through the period we are" against "how
/// much of the budget is already spent" — see [FinanceSummary.paceAt].
class BudgetPace {
  const BudgetPace({
    required this.onTrack,
    required this.expectedRatio,
    required this.actualRatio,
  });

  final bool onTrack;
  final double expectedRatio;
  final double actualRatio;
}

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
    required this.totalSavingsTarget,
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

  /// Target tabungan (sum goalValue*loggedDays) dari habit `atLeast` rupiah —
  /// dasar bandingan progress "Rp X / Rp Y saved", sama seperti [totalBudget]
  /// untuk habit `atMost`.
  final int totalSavingsTarget;

  final List<FinanceHabitStat> habitStats;
  final List<FinanceDayPoint> dailyTrend;

  /// Selisih budget - pengeluaran. Positif = hemat, negatif = kelebihan budget.
  int get totalSaved => totalBudget - totalExpense;

  bool get hasData => habitStats.isNotEmpty;

  /// Compares how far through the period "now" is against how much of the
  /// budget has already been spent — e.g. 60% of days elapsed but only 40%
  /// of budget spent = on track; 60% elapsed but 80% spent = overspending.
  /// Returns null when there's no budget to pace against (no `atMost`
  /// habits) or `now` falls outside the period (e.g. viewing a past/future
  /// month), where "pace" isn't a meaningful concept.
  BudgetPace? paceAt(DateTime now) {
    if (totalBudget <= 0) return null;
    final start = DateTime(periodStart.year, periodStart.month, periodStart.day);
    final endInclusive =
        DateTime(periodEndInclusive.year, periodEndInclusive.month, periodEndInclusive.day);
    final today = DateTime(now.year, now.month, now.day);
    if (today.isBefore(start) || today.isAfter(endInclusive)) return null;

    final totalDays = endInclusive.difference(start).inDays + 1;
    final elapsedDays = today.difference(start).inDays + 1;
    final expectedRatio = (elapsedDays / totalDays).clamp(0.0, 1.0);
    final actualRatio = (totalExpense / totalBudget).clamp(0.0, 10.0);

    return BudgetPace(
      onTrack: actualRatio <= expectedRatio + 0.05,
      expectedRatio: expectedRatio,
      actualRatio: actualRatio,
    );
  }

  static final empty = FinanceSummary(
    periodStart: DateTime(2000),
    periodEndInclusive: DateTime(2000),
    totalExpense: 0,
    totalBudget: 0,
    totalSavingsDeposit: 0,
    totalSavingsTarget: 0,
    habitStats: const [],
    dailyTrend: const [],
  );
}
