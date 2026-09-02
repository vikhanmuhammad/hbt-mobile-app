import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/date_utils.dart';
import '../domain/models/finance_summary.dart';
import 'core_providers.dart';
import 'ui_state_providers.dart';

part 'finance_providers.g.dart';

/// Rangkuman keuangan untuk bulan kalender yang memuat [monthAnchor].
@riverpod
Future<FinanceSummary> financeSummary(Ref ref, DateTime monthAnchor) {
  final firstDay = DateTime(monthAnchor.year, monthAnchor.month, 1);
  final lastDay = DateTime(monthAnchor.year, monthAnchor.month + 1, 0);
  // `watch` (bukan `read`) supaya provider ini otomatis rebuild begitu Home
  // menandai habit sebagai "sedang dihapus" — Finance langsung ikut
  // melupakannya, tidak perlu menunggu delete fisik ~5 detik kemudian.
  final excludeHabitIds = ref.watch(pendingDeleteHabitIdsProvider);
  return ref
      .watch(financeRepositoryProvider)
      .computeSummary(firstDay, lastDay, excludeHabitIds: excludeHabitIds);
}

/// Rangkuman keuangan bulan kalender yang memuat [monthAnchor], tapi
/// di-clamp sampai hari ini (bukan sampai akhir bulan) — dasar "Total
/// Saved" di Finance: akumulasi sisa budget berjalan dari hari habit
/// budget itu di-set (`isHabitActiveOn` sudah otomatis mengecualikan hari
/// sebelum `habit.startDate`) sampai hari ini, bukan diproyeksikan ke
/// seluruh bulan yang belum berjalan. Beda dari [financeSummaryProvider]
/// biasa, yang sengaja TIDAK di-clamp supaya "X dari Rp Y budget" &
/// `paceAt` di tab Monthly tetap membandingkan ke cap bulan penuh. Untuk
/// bulan yang sudah lewat, clamp ke hari ini tidak berpengaruh — hasilnya
/// otomatis sama dengan bulan penuh karena akhir bulan sudah di masa lalu.
@riverpod
Future<FinanceSummary> financeMonthToDateSummary(Ref ref, DateTime monthAnchor) {
  final firstDay = DateTime(monthAnchor.year, monthAnchor.month, 1);
  final lastDay = DateTime(monthAnchor.year, monthAnchor.month + 1, 0);
  final now = today();
  var end = now.isBefore(lastDay) ? now : lastDay;
  if (end.isBefore(firstDay)) end = firstDay;
  final excludeHabitIds = ref.watch(pendingDeleteHabitIdsProvider);
  return ref
      .watch(financeRepositoryProvider)
      .computeSummary(firstDay, end, excludeHabitIds: excludeHabitIds);
}

/// Start/end (inclusive) for a [FinancePeriod] anchored at [anchor] — Monday
/// as the first day of a week, matching `weekdayKeys`/`DateTime.weekday`
/// conventions used elsewhere in the app.
(DateTime, DateTime) financePeriodRange(FinancePeriod period, DateTime anchor) {
  switch (period) {
    case FinancePeriod.daily:
      final day = DateTime(anchor.year, anchor.month, anchor.day);
      return (day, day);
    case FinancePeriod.weekly:
      final day = DateTime(anchor.year, anchor.month, anchor.day);
      final start = day.subtract(Duration(days: day.weekday - 1));
      final end = start.add(const Duration(days: 6));
      return (start, end);
    case FinancePeriod.monthly:
      final firstDay = DateTime(anchor.year, anchor.month, 1);
      final lastDay = DateTime(anchor.year, anchor.month + 1, 0);
      return (firstDay, lastDay);
  }
}

/// Rangkuman keuangan untuk [period] (harian/mingguan/bulanan) yang memuat
/// [anchor] — dipakai layar Rangkuman Keuangan untuk toggle Daily/Weekly/
/// Monthly (`selectedFinancePeriodProvider`).
@riverpod
Future<FinanceSummary> financeSummaryForPeriod(
  Ref ref,
  FinancePeriod period,
  DateTime anchor,
) {
  final (start, end) = financePeriodRange(period, anchor);
  final excludeHabitIds = ref.watch(pendingDeleteHabitIdsProvider);
  return ref.watch(financeRepositoryProvider).computeSummary(
        start,
        end,
        excludeHabitIds: excludeHabitIds,
        // Monthly tab buckets the trend chart into ~4-5 weekly bars instead
        // of ~30 daily ones — Daily/Weekly stay per-day (small ranges).
        trendBucket: period == FinancePeriod.monthly ? FinanceTrendBucket.week : FinanceTrendBucket.day,
      );
}
