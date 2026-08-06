import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/models/finance_summary.dart';
import 'core_providers.dart';

part 'finance_providers.g.dart';

/// Rangkuman keuangan untuk bulan kalender yang memuat [monthAnchor].
@riverpod
Future<FinanceSummary> financeSummary(Ref ref, DateTime monthAnchor) {
  final firstDay = DateTime(monthAnchor.year, monthAnchor.month, 1);
  final lastDay = DateTime(monthAnchor.year, monthAnchor.month + 1, 0);
  return ref.watch(financeRepositoryProvider).computeSummary(firstDay, lastDay);
}
