import 'package:flutter/material.dart';

import '../../domain/models/habit_with_progress.dart';
import '../theme/app_colors.dart';
import 'daily_progress_ring.dart';

/// Checklist habit harian: checkbox besar, info goal, badge time range,
/// indikator reminder aktif. Dipakai sama untuk Beranda & Riwayat.
/// Lihat DESIGN.md §5.
class HabitCard extends StatelessWidget {
  const HabitCard({
    super.key,
    required this.item,
    required this.accentColor,
    required this.onIncrement,
    this.onDecrement,
    this.onTap,
  });

  final HabitWithProgress item;
  final Color accentColor;
  final VoidCallback onIncrement;
  final VoidCallback? onDecrement;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final habit = item.habit;
    final isMultiStep = habit.goalValue > 1;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CheckControl(
                isDone: item.isDone,
                progressValue: item.progressValue,
                goalValue: habit.goalValue,
                accentColor: accentColor,
                onIncrement: onIncrement,
                onDecrement: onDecrement,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      habit.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        decoration:
                            item.isDone ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _InfoChip(
                          label: isMultiStep
                              ? '${item.progressValue}/${habit.goalValue} • ${habit.goalPeriod.label}'
                              : habit.goalPeriod.label,
                        ),
                        _InfoChip(label: habit.timeRange.label),
                        if (habit.reminderEnabled &&
                            habit.reminderTime != null)
                          _InfoChip(
                            icon: Icons.notifications_active_rounded,
                            label: habit.reminderTime!,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CheckControl extends StatelessWidget {
  const _CheckControl({
    required this.isDone,
    required this.progressValue,
    required this.goalValue,
    required this.accentColor,
    required this.onIncrement,
    required this.onDecrement,
  });

  final bool isDone;
  final int progressValue;
  final int goalValue;
  final Color accentColor;
  final VoidCallback onIncrement;
  final VoidCallback? onDecrement;

  @override
  Widget build(BuildContext context) {
    final isMultiStep = goalValue > 1;

    if (!isMultiStep) {
      return GestureDetector(
        onTap: onIncrement,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDone ? accentColor : Colors.transparent,
            border: Border.all(
              color: isDone ? accentColor : AppColors.lightBorder,
              width: 2,
            ),
          ),
          child: isDone
              ? const Icon(Icons.check_rounded, color: Colors.white, size: 20)
              : null,
        ),
      );
    }

    return GestureDetector(
      onTap: onIncrement,
      onLongPress: onDecrement,
      child: DailyProgressRing(
        done: progressValue,
        total: goalValue,
        size: 32,
        strokeWidth: 4,
        color: accentColor,
        centerLabel: isDone ? '✓' : '$progressValue',
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label, this.icon});

  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: theme.textTheme.labelSmall?.color),
            const SizedBox(width: 4),
          ],
          Text(label, style: theme.textTheme.labelSmall),
        ],
      ),
    );
  }
}
