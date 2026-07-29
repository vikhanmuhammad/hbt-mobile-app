import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/models/dashboard_summary.dart';
import '../../../providers/category_providers.dart';
import '../../../providers/stats_providers.dart';
import '../../theme/app_colors.dart';

/// Dashboard/Ringkasan: total hari tercatat, persentase keberhasilan,
/// breakdown per kategori, per habit, dan tren bulanan. Lihat DESIGN.md §4.4.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(dashboardSummaryProvider);
    final isWide = MediaQuery.sizeOf(context).width >= 900;

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: summaryAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Gagal memuat dashboard: $e')),
        data: (summary) {
          if (summary.totalLogs == 0) {
            return const _EmptyDashboard();
          }

          final header = _SummaryHeader(summary: summary);
          final categorySection = _CategoryBreakdown(summary: summary);
          final habitSection = _HabitBreakdown(summary: summary);
          final trendSection = _MonthlyTrend(summary: summary);

          if (isWide) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  header,
                  const SizedBox(height: 20),
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: categorySection),
                        const SizedBox(width: 20),
                        Expanded(child: trendSection),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  habitSection,
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              header,
              const SizedBox(height: 20),
              categorySection,
              const SizedBox(height: 20),
              trendSection,
              const SizedBox(height: 20),
              habitSection,
            ],
          );
        },
      ),
    );
  }
}

class _EmptyDashboard extends StatelessWidget {
  const _EmptyDashboard();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bar_chart_rounded, size: 48, color: Theme.of(context).disabledColor),
            const SizedBox(height: 16),
            const Text('Belum ada data untuk ditampilkan'),
            const SizedBox(height: 8),
            const Text(
              'Mulai centang habit hari ini supaya dashboard mulai terisi.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryHeader extends StatelessWidget {
  const _SummaryHeader({required this.summary});

  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'Hari Tercatat',
            value: '${summary.totalDaysTracked}',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            label: 'Keberhasilan',
            value: '${(summary.overallSuccessRate * 100).round()}%',
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: theme.textTheme.headlineSmall),
            const SizedBox(height: 4),
            Text(label, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _CategoryBreakdown extends ConsumerWidget {
  const _CategoryBreakdown({required this.summary});

  final DashboardSummary summary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final categories = ref.watch(categoriesProvider).value ?? [];
    final indexById = {for (var i = 0; i < categories.length; i++) categories[i].id: i};

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Per Kategori', style: theme.textTheme.titleMedium),
            const SizedBox(height: 14),
            for (final stat in summary.categoryStats)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ProgressRow(
                  label: stat.category.name,
                  ratio: stat.successRate,
                  color: AppColors.categoryColorFromHex(
                    stat.category.colorHex,
                    indexById[stat.category.id] ?? 0,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _HabitBreakdown extends StatelessWidget {
  const _HabitBreakdown({required this.summary});

  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Per Habit', style: theme.textTheme.titleMedium),
            const SizedBox(height: 14),
            for (final stat in summary.habitStats)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ProgressRow(
                  label: stat.habit.name,
                  ratio: stat.successRate,
                  color: AppColors.teal,
                  trailing: '${stat.doneLogs}/${stat.totalLogs}',
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MonthlyTrend extends StatelessWidget {
  const _MonthlyTrend({required this.summary});

  final DashboardSummary summary;

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final points = summary.monthlyStats.length > 6
        ? summary.monthlyStats.sublist(summary.monthlyStats.length - 6)
        : summary.monthlyStats;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tren Bulanan', style: theme.textTheme.titleMedium),
            const SizedBox(height: 20),
            SizedBox(
              height: 120,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (final point in points)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text('${(point.successRate * 100).round()}%',
                                style: theme.textTheme.labelSmall),
                            const SizedBox(height: 4),
                            FractionallySizedBox(
                              heightFactor: point.successRate.clamp(0.03, 1),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.teal,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(_months[point.month.month - 1],
                                style: theme.textTheme.labelSmall),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressRow extends StatelessWidget {
  const _ProgressRow({
    required this.label,
    required this.ratio,
    required this.color,
    this.trailing,
  });

  final String label;
  final double ratio;
  final Color color;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
            Text(
              trailing ?? '${(ratio * 100).round()}%',
              style: theme.textTheme.labelMedium,
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: ratio.clamp(0, 1),
            minHeight: 8,
            backgroundColor: color.withValues(alpha: 0.15),
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }
}
