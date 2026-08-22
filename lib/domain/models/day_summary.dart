class DaySummary {
  const DaySummary({
    required this.date,
    required this.totalCount,
    required this.doneCount,
  });

  final DateTime date;
  final int totalCount;

  /// Jumlah kredit progress (lihat `Habit.progressCredit`) di hari ini —
  /// habit yang belum 100% tercapai tetap menyumbang porsinya, bukan cuma
  /// dihitung kalau sudah penuh.
  final double doneCount;

  double get ratio => totalCount == 0 ? 0 : doneCount / totalCount;

  bool get hasData => totalCount > 0;
}
