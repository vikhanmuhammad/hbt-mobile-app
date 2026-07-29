import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/models/dashboard_summary.dart';
import '../domain/models/day_summary.dart';
import 'core_providers.dart';

part 'stats_providers.g.dart';

@riverpod
Future<DashboardSummary> dashboardSummary(Ref ref) {
  return ref.watch(statsRepositoryProvider).computeDashboard();
}

@riverpod
Future<List<DaySummary>> monthSummaries(Ref ref, DateTime monthAnchor) {
  return ref.watch(statsRepositoryProvider).computeMonthSummaries(monthAnchor);
}

@riverpod
Future<DaySummary> daySummary(Ref ref, DateTime date) {
  return ref.watch(statsRepositoryProvider).computeDaySummary(date);
}
