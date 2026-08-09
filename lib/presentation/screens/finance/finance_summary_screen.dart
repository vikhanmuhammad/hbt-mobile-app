import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/format_utils.dart';
import '../../../domain/models/enums.dart';
import '../../../domain/models/finance_summary.dart';
import '../../../providers/community_providers.dart';
import '../../../providers/finance_providers.dart';
import '../../../providers/ui_state_providers.dart';
import '../../theme/app_colors.dart';
import '../../widgets/habit_icon.dart';
import '../../widgets/pro_feature_teaser.dart';

const _monthNames = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
];

/// Finance Summary: total expenses, amount saved, and savings deposits
/// from all rupiah-unit habits (across categories), per calendar month —
/// plus daily spending trend and a per-habit breakdown.
class FinanceSummaryScreen extends ConsumerWidget {
  const FinanceSummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPro = ref.watch(isProProvider);
    if (!isPro) {
      return const ProFeatureTeaser(
        icon: Icons.account_balance_wallet_rounded,
        title: 'Finance — Pro Feature',
        description: 'Track spending, savings, and saving habits in one monthly summary. '
            'Upgrade to Pro to unlock this feature.',
      );
    }

    final month = ref.watch(selectedFinanceMonthProvider);
    final summaryAsync = ref.watch(financeSummaryProvider(month));
    final isTablet = MediaQuery.sizeOf(context).width >= 600;

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.fromLTRB(isTablet ? 32 : 16, isTablet ? 32 : 20, isTablet ? 32 : 16, 24),
        children: [
          _MonthNav(
            month: month,
            onChangeMonth: (m) => ref.read(selectedFinanceMonthProvider.notifier).state = m,
          ),
          const SizedBox(height: 20),
          summaryAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(40),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, st) => Padding(
              padding: const EdgeInsets.all(24),
              child: Text('Failed to load finance summary: $e'),
            ),
            data: (summary) {
              if (!summary.hasData) return const _EmptyFinance();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _TotalsSection(summary: summary),
                  if (summary.dailyTrend.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    _SpendingTrendCard(summary: summary),
                  ],
                  const SizedBox(height: 20),
                  _HabitBreakdownCard(summary: summary),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _MonthNav extends StatelessWidget {
  const _MonthNav({required this.month, required this.onChangeMonth});

  final DateTime month;
  final ValueChanged<DateTime> onChangeMonth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _NavCircleButton(
          icon: Icons.chevron_left_rounded,
          onTap: () => onChangeMonth(DateTime(month.year, month.month - 1)),
        ),
        Text('${_monthNames[month.month - 1]} ${month.year}', style: theme.textTheme.titleLarge),
        _NavCircleButton(
          icon: Icons.chevron_right_rounded,
          onTap: () => onChangeMonth(DateTime(month.year, month.month + 1)),
        ),
      ],
    );
  }
}

class _NavCircleButton extends StatelessWidget {
  const _NavCircleButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.cardColor,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(width: 36, height: 36, child: Icon(icon)),
      ),
    );
  }
}

class _EmptyFinance extends StatelessWidget {
  const _EmptyFinance();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.account_balance_wallet_outlined, size: 48, color: Theme.of(context).disabledColor),
              const SizedBox(height: 16),
              const Text('No finance habits yet'),
              const SizedBox(height: 8),
              const Text(
                'Add a Rupiah-unit habit (e.g. a daily spending cap in "Save Money") to start seeing a summary here.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TotalsSection extends StatelessWidget {
  const _TotalsSection({required this.summary});

  final FinanceSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final saved = summary.totalSaved;
    final isOverBudget = saved < 0;
    final hasBudget = summary.totalBudget > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total Spending', style: theme.textTheme.bodyMedium),
                const SizedBox(height: 6),
                Text(formatRupiah(summary.totalExpense), style: theme.textTheme.headlineMedium),
                if (hasBudget) ...[
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: (summary.totalExpense / summary.totalBudget).clamp(0, 1).toDouble(),
                      minHeight: 8,
                      backgroundColor: theme.brightness == Brightness.light
                          ? AppColors.lightSurfaceAlt
                          : AppColors.darkSurfaceAlt,
                      valueColor: AlwaysStoppedAnimation(
                        isOverBudget ? theme.colorScheme.error : theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text('of ${formatRupiah(summary.totalBudget)} budget', style: theme.textTheme.bodySmall),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _StatChip(
                label: isOverBudget ? 'Over Budget' : 'Total Saved',
                value: formatRupiah(saved.abs()),
                color: isOverBudget ? theme.colorScheme.error : theme.colorScheme.primary,
                icon: isOverBudget ? Icons.trending_up_rounded : Icons.savings_rounded,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatChip(
                label: 'Total Deposited',
                value: formatRupiah(summary.totalSavingsDeposit),
                color: theme.colorScheme.primary,
                icon: Icons.account_balance_wallet_rounded,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String label;
  final String value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(height: 10),
            Text(label, style: theme.textTheme.labelSmall),
            const SizedBox(height: 4),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _SpendingTrendCard extends StatelessWidget {
  const _SpendingTrendCard({required this.summary});

  final FinanceSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final points = summary.dailyTrend;
    final maxValue = points.fold<int>(0, (m, p) => p.totalExpense > m ? p.totalExpense : m);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Daily Spending Trend', style: theme.textTheme.titleMedium),
            const SizedBox(height: 20),
            SizedBox(
              height: 140,
              child: maxValue == 0
                  ? Center(child: Text('No data yet', style: theme.textTheme.bodySmall))
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          for (final point in points)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    height: 100,
                                    child: Align(
                                      alignment: Alignment.bottomCenter,
                                      child: FractionallySizedBox(
                                        heightFactor: (point.totalExpense / maxValue).clamp(0.04, 1).toDouble(),
                                        child: Container(
                                          width: 20,
                                          decoration: BoxDecoration(
                                            color: theme.colorScheme.primary,
                                            borderRadius: const BorderRadius.only(
                                              topLeft: Radius.circular(4),
                                              topRight: Radius.circular(4),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text('${point.date.day}', style: theme.textTheme.labelSmall),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HabitBreakdownCard extends StatelessWidget {
  const _HabitBreakdownCard({required this.summary});

  final FinanceSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('By Habit', style: theme.textTheme.titleMedium),
            const SizedBox(height: 16),
            for (final stat in summary.habitStats)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _HabitFinanceRow(stat: stat),
              ),
          ],
        ),
      ),
    );
  }
}

class _HabitFinanceRow extends StatelessWidget {
  const _HabitFinanceRow({required this.stat});

  final FinanceHabitStat stat;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final habit = stat.habit;
    final isAtMost = habit.goalDirection == GoalDirection.atMost;
    final overBudget = isAtMost && stat.totalValue > stat.totalTarget;
    final ratio = isAtMost
        ? (stat.totalTarget == 0 ? 0.0 : (stat.totalValue / stat.totalTarget).clamp(0, 1).toDouble())
        : (stat.loggedDays == 0 ? 0.0 : stat.achievedDays / stat.loggedDays);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(color: theme.colorScheme.primary, shape: BoxShape.circle),
              child: Center(child: HabitIcon(icon: habit.icon, size: 13, color: Colors.white)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                habit.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            Text(
              isAtMost
                  ? '${formatRupiah(stat.totalValue)} / ${formatRupiah(stat.totalTarget)}'
                  : formatRupiah(stat.totalValue),
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 8,
            backgroundColor:
                theme.brightness == Brightness.light ? AppColors.lightSurfaceAlt : AppColors.darkSurfaceAlt,
            valueColor: AlwaysStoppedAnimation(overBudget ? theme.colorScheme.error : theme.colorScheme.primary),
          ),
        ),
      ],
    );
  }
}
