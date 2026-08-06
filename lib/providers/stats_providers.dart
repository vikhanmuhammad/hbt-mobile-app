import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/models/dashboard_summary.dart';
import '../domain/models/day_summary.dart';
import 'core_providers.dart';
import 'ui_state_providers.dart';

part 'stats_providers.g.dart';

/// Otomatis reaktif terhadap filter icon habit di layar Dashboard —
/// `selectedDashboardHabitIdsProvider` di-watch di sini (bukan lewat family
/// parameter) supaya perubahan Set tidak bergantung pada `Set` punya value
/// equality (defaultnya identity-based di Dart).
@riverpod
Future<DashboardSummary> dashboardSummary(Ref ref) {
  final habitIds = ref.watch(selectedDashboardHabitIdsProvider);
  return ref.watch(statsRepositoryProvider).computeDashboard(habitIds: habitIds);
}

@riverpod
Future<List<DaySummary>> monthSummaries(Ref ref, DateTime monthAnchor) {
  final habitIds = ref.watch(selectedDashboardHabitIdsProvider);
  return ref
      .watch(statsRepositoryProvider)
      .computeMonthSummaries(monthAnchor, habitIds: habitIds);
}

@riverpod
Future<DaySummary> daySummary(Ref ref, DateTime date) {
  return ref.watch(statsRepositoryProvider).computeDaySummary(date);
}
