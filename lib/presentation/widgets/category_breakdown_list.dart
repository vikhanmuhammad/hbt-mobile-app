import 'package:flutter/material.dart';

import '../../domain/format_utils.dart';
import '../../domain/language.dart';
import '../../domain/models/enums.dart';
import '../../l10n/generated/app_localizations.dart';

/// One line of spending-breakdown data to render in [CategoryBreakdownList]
/// — either a pre-aggregated stat (finance screens, [id] null, not
/// editable) or a single raw entry/draft (quick-progress sheet, [id] set so
/// [CategoryBreakdownList.onEdit]/[onDelete] know which one was tapped).
class CategoryBreakdownItem {
  const CategoryBreakdownItem({
    required this.category,
    this.label,
    required this.amount,
    this.id,
  });

  final SpendingBreakdownCategory category;

  /// Free-text sub-category/detail (e.g. "Bensin"). Null/empty renders as a
  /// generic placeholder line rather than being merged into the category
  /// header, so every logged amount still gets its own visible row.
  final String? label;
  final int amount;

  /// Opaque identifier passed back via [CategoryBreakdownList.onEdit]/
  /// [onDelete] — null means this row isn't individually actionable (used
  /// for already-aggregated, read-only display).
  final Object? id;
}

/// Renders spending-breakdown data grouped by category, e.g.:
/// ```
/// Daily Needs = Rp80.000
///   - Makan siang = Rp50.000
///   - Ojek = Rp30.000
/// Fixed Spending = Rp150.000
///   - Langganan = Rp150.000
/// --------------------------
/// Total = Rp230.000
/// ```
/// Reused by the quick-progress sheet's breakdown editor (`editable: true`,
/// items carry an [CategoryBreakdownItem.id]) and by the Finance screen's
/// "Spending by Category" / "Month to Date" sections (`editable: false`,
/// items are already-aggregated [CategoryBreakdownItem]s with no id).
class CategoryBreakdownList extends StatelessWidget {
  const CategoryBreakdownList({
    super.key,
    required this.items,
    this.editable = false,
    this.onEdit,
    this.onDelete,
    this.showGrandTotal = true,
    this.currencyPrefix = 'Rp ',
  });

  final List<CategoryBreakdownItem> items;
  final bool editable;
  final ValueChanged<CategoryBreakdownItem>? onEdit;
  final ValueChanged<CategoryBreakdownItem>? onDelete;
  final bool showGrandTotal;

  /// e.g. "Rp " for IDR, "USD " for others — matches the Budget Tracker
  /// habit's selected currency (`Habit.currencyPrefix`), label only.
  final String currencyPrefix;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final lang = Localizations.localeOf(context).languageCode == 'id' ? AppLang.id : AppLang.en;

    final byCategory = <SpendingBreakdownCategory, List<CategoryBreakdownItem>>{};
    for (final item in items) {
      byCategory.putIfAbsent(item.category, () => []).add(item);
    }
    final grandTotal = items.fold<int>(0, (sum, i) => sum + i.amount);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final category in SpendingBreakdownCategory.values)
          if (byCategory[category] case final categoryItems?)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _CategoryGroup(
                category: category,
                items: categoryItems,
                lang: lang,
                editable: editable,
                onEdit: onEdit,
                onDelete: onDelete,
                currencyPrefix: currencyPrefix,
              ),
            ),
        if (showGrandTotal) ...[
          Divider(color: theme.dividerColor),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.spendingBreakdownGrandTotalLabel,
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
              Text(
                formatCurrency(grandTotal, currencyPrefix),
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _CategoryGroup extends StatelessWidget {
  const _CategoryGroup({
    required this.category,
    required this.items,
    required this.lang,
    required this.editable,
    required this.onEdit,
    required this.onDelete,
    required this.currencyPrefix,
  });

  final SpendingBreakdownCategory category;
  final List<CategoryBreakdownItem> items;
  final AppLang lang;
  final bool editable;
  final ValueChanged<CategoryBreakdownItem>? onEdit;
  final ValueChanged<CategoryBreakdownItem>? onDelete;
  final String currencyPrefix;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final categoryTotal = items.fold<int>(0, (sum, i) => sum + i.amount);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              category.label(lang),
              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            Text(
              formatCurrency(categoryTotal, currencyPrefix),
              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '- ${(item.label?.trim().isNotEmpty ?? false) ? item.label!.trim() : l10n.spendingBreakdownNoDetailLabel}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall,
                  ),
                ),
                Text(formatCurrency(item.amount, currencyPrefix), style: theme.textTheme.bodySmall),
                if (editable && item.id != null) ...[
                  IconButton(
                    onPressed: () => onEdit?.call(item),
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                  ),
                  IconButton(
                    onPressed: () => onDelete?.call(item),
                    icon: const Icon(Icons.close_rounded, size: 16),
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}
