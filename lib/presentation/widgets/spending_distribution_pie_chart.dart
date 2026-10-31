import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../domain/format_utils.dart';
import '../../domain/language.dart';
import '../../domain/models/enums.dart';
import '../../l10n/generated/app_localizations.dart';
import 'category_breakdown_list.dart';

/// One consistent color per spending-breakdown category, reused by the pie
/// chart's slices and legend swatches.
Color categoryColor(SpendingBreakdownCategory category) => switch (category) {
      SpendingBreakdownCategory.dailyNeeds => const Color(0xFF4C8DFF),
      SpendingBreakdownCategory.dailyWants => const Color(0xFFF2A93B),
      SpendingBreakdownCategory.unexpectedNeeds => const Color(0xFFE5695A),
      SpendingBreakdownCategory.fixedSpending => const Color(0xFF6FBF8B),
    };

/// Pie chart showing the percentage split of spending across the 4 fixed
/// [SpendingBreakdownCategory] buckets for the active Finance period, with a
/// legend row below (category label, percentage, amount).
class SpendingDistributionPieChart extends StatelessWidget {
  const SpendingDistributionPieChart({super.key, required this.items, this.currencyPrefix = 'Rp '});

  final List<CategoryBreakdownItem> items;
  final String currencyPrefix;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (items.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final lang = Localizations.localeOf(context).languageCode == 'id' ? AppLang.id : AppLang.en;
    final totalsByCategory = <SpendingBreakdownCategory, int>{};
    for (final item in items) {
      totalsByCategory[item.category] = (totalsByCategory[item.category] ?? 0) + item.amount;
    }
    final grandTotal = totalsByCategory.values.fold<int>(0, (a, b) => a + b);
    if (grandTotal <= 0) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.financeSpendingDistribution, style: theme.textTheme.titleMedium),
            const SizedBox(height: 16),
            SizedBox(
              height: 180,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 44,
                  sections: [
                    for (final category in SpendingBreakdownCategory.values)
                      if ((totalsByCategory[category] ?? 0) > 0)
                        PieChartSectionData(
                          value: totalsByCategory[category]!.toDouble(),
                          color: categoryColor(category),
                          radius: 46,
                          title: '${(totalsByCategory[category]! / grandTotal * 100).round()}%',
                          titleStyle: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            for (final category in SpendingBreakdownCategory.values)
              if ((totalsByCategory[category] ?? 0) > 0)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(color: categoryColor(category), shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(category.label(lang), style: theme.textTheme.bodySmall),
                      ),
                      Text(
                        formatCurrency(totalsByCategory[category]!, currencyPrefix),
                        style: theme.textTheme.bodySmall,
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
