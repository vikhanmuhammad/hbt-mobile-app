import 'package:flutter/material.dart';

import '../../domain/format_utils.dart';
import '../../domain/models/habit_with_progress.dart';
import 'habit_icon.dart';

/// Kartu habit flat-list Beranda — 2 state visual (in-progress fill parsial,
/// complete solid+checkmark) dan affordance Edit Mode (reorder/edit/hapus).
/// CLAUDE.md v3 §6.2/§6.3.
class HabitProgressCard extends StatelessWidget {
  const HabitProgressCard({
    super.key,
    required this.item,
    required this.accentColor,
    required this.isEditMode,
    required this.onTap,
    this.onEdit,
    this.onDelete,
    this.dragHandle,
  });

  final HabitWithProgress item;
  final Color accentColor;
  final bool isEditMode;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  /// Handle drag reorder (mis. dari `ReorderableDragStartListener`),
  /// disuntikkan dari HomeScreen supaya widget ini tidak perlu tahu index.
  final Widget? dragHandle;

  String get _progressLabel {
    final h = item.habit;
    if (h.isRupiah) {
      return '${formatRupiah(item.progressValue)}/${formatRupiah(h.goalValue)}';
    }
    final target = h.goalUnit == 'x' ? '${h.goalValue}x' : '${h.goalValue} ${h.goalUnit}';
    return '${item.progressValue}/$target';
  }

  double get _ratio {
    if (item.habit.goalValue <= 0) return 0;
    return (item.progressValue / item.habit.goalValue).clamp(0, 1).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final done = item.isDone;
    final ratio = _ratio;

    final baseColor = theme.cardColor;
    final fillColor = done
        ? accentColor.withValues(alpha: 0.9)
        : Color.lerp(baseColor, accentColor, 0.16 + ratio * 0.2)!;

    return Card(
      clipBehavior: Clip.antiAlias,
      color: baseColor,
      child: InkWell(
        onTap: isEditMode ? null : onTap,
        child: Stack(
          children: [
            if (!done)
              Positioned.fill(
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: ratio.clamp(0.04, 1),
                  child: Container(color: fillColor),
                ),
              )
            else
              Positioned.fill(child: Container(color: fillColor)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              child: Row(
                children: [
                  if (isEditMode && dragHandle != null) ...[
                    dragHandle!,
                    const SizedBox(width: 8),
                  ],
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(color: accentColor, shape: BoxShape.circle),
                    child: Center(
                      child: HabitIcon(icon: item.habit.icon, size: 16, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.habit.name,
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: done ? Colors.white : null,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _progressLabel,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: done ? Colors.white.withValues(alpha: 0.85) : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isEditMode) ...[
                    IconButton(
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit_outlined, size: 20),
                      style: IconButton.styleFrom(backgroundColor: baseColor),
                    ),
                    IconButton(
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete_outline_rounded, size: 20),
                      style: IconButton.styleFrom(backgroundColor: baseColor),
                    ),
                  ] else
                    Icon(
                      done ? Icons.check_circle_rounded : Icons.circle_outlined,
                      color: done ? Colors.white : theme.dividerColor,
                      size: 26,
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
