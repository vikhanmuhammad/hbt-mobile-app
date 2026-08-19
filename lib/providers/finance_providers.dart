import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/models/finance_summary.dart';
import 'core_providers.dart';
import 'ui_state_providers.dart';

part 'finance_providers.g.dart';

/// Rangkuman keuangan untuk bulan kalender yang memuat [monthAnchor].
@riverpod
Future<FinanceSummary> financeSummary(Ref ref, DateTime monthAnchor) {
  final firstDay = DateTime(monthAnchor.year, monthAnchor.month, 1);
  final lastDay = DateTime(monthAnchor.year, monthAnchor.month + 1, 0);
  return ref.watch(financeRepositoryProvider).computeSummary(firstDay, lastDay);
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
  return ref.watch(financeRepositoryProvider).computeSummary(start, end);
}
