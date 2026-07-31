import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/models/dashboard_summary.dart';
import '../../../providers/category_providers.dart';
import '../../../providers/stats_providers.dart';
import '../../theme/app_colors.dart';
import '../../widgets/daily_progress_ring.dart';

/// Dashboard/Ringkasan: ring keberhasilan keseluruhan, breakdown per
/// kategori, per habit, dan tren bulanan. Tanpa AppBar/judul halaman,
/// persis prototipe. Lihat DESIGN.md §4.4.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(dashboardSummaryProvider);
    final isWide = MediaQuery.sizeOf(context).width >= 900;
    final isTablet = MediaQuery.sizeOf(context).width >= 600;

    return Scaffold(
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
              padding: const EdgeInsets.all(32),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        header,
                        const SizedBox(height: 20),
                        categorySection,
                        const SizedBox(height: 20),
                        habitSection,
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(child: trendSection),
                ],
              ),
            );
          }

          return ListView(
            padding: EdgeInsets.fromLTRB(isTablet ? 32 : 16, isTablet ? 32 : 20, isTablet ? 32 : 16, 24),
            children: [
              header,
              const SizedBox(height: 20),
              categorySection,
              const SizedBox(height: 20),
              habitSection,
              const SizedBox(height: 20),
              trendSection,
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
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Row(
          children: [
            DailyProgressRing(
              done: (summary.overallSuccessRate * 100).round(),
              total: 100,
              size: 84,
              strokeWidth: 9,
              centerLabel: '${(summary.overallSuccessRate * 100).round()}%',
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${summary.totalDaysTracked} hari tercatat', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 4),
                  Text('Rata-rata keberhasilan keseluruhan', style: theme.textTheme.bodySmall),
                ],
              ),
            ),
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
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Per Kategori', style: theme.textTheme.titleMedium),
            const SizedBox(height: 16),
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
                  showDot: true,
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
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Per Habit', style: theme.textTheme.titleMedium),
            const SizedBox(height: 16),
            for (final stat in summary.habitStats)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ProgressRow(
                  label: stat.habit.name,
                  ratio: stat.successRate,
                  color: theme.colorScheme.primary,
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
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tren Bulanan', style: theme.textTheme.titleMedium),
            const SizedBox(height: 20),
            SizedBox(
              height: 160,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (final point in points)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Column(
                          children: [
                            // Expanded gives this slot a bounded/tight height
                            // so FractionallySizedBox has something to size
                            // its heightFactor against — a bare Column doesn't
                            // bound non-flex children, which crashes it.
                            Expanded(
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: FractionallySizedBox(
                                  heightFactor: point.successRate.clamp(0.03, 1),
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(maxWidth: 44),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.primary,
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(10),
                                          topRight: Radius.circular(10),
                                          bottomLeft: Radius.circular(4),
                                          bottomRight: Radius.circular(4),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(_months[point.month.month - 1],
                                style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600)),
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
    this.showDot = false,
  });

  final String label;
  final double ratio;
  final Color color;
  final bool showDot;

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
              child: Row(
                children: [
                  if (showDot) ...[
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            Text('${(ratio * 100).round()}%', style: theme.textTheme.bodySmall),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: ratio.clamp(0, 1),
            minHeight: 10,
            backgroundColor: theme.brightness == Brightness.light
                ? AppColors.lightSurfaceAlt
                : AppColors.darkSurfaceAlt,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }
}
