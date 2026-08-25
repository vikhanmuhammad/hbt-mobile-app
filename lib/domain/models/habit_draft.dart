import 'enums.dart';

/// Everything needed to create one habit — mirrors
/// `HabitRepository.createHabit`'s parameters 1:1, but as a plain value
/// object so a batch of them can be built in the UI layer (no Drift types
/// leaking outside the data layer) and passed to
/// `HabitRepository.createHabitsBatch` in one call.
class HabitDraft {
  const HabitDraft({
    required this.categoryId,
    required this.name,
    this.nameId,
    this.description,
    this.icon,
    required this.goalPeriod,
    required this.goalValue,
    this.goalUnit = 'x',
    this.goalDirection = GoalDirection.atLeast,
    required this.taskDays,
    required this.timeRange,
    required this.reminderEnabled,
    this.reminderTime,
    this.reminderIntervalMinutes,
    required this.startDate,
    this.endDate,
    this.sortOrder = 0,
    this.isCustom = true,
    this.templateKey,
  });

  final int categoryId;
  final String name;
  final String? nameId;
  final String? description;
  final String? icon;
  final GoalPeriod goalPeriod;
  final int goalValue;
  final String goalUnit;
  final GoalDirection goalDirection;
  final List<String> taskDays;
  final TimeRange timeRange;
  final bool reminderEnabled;
  final String? reminderTime;
  final int? reminderIntervalMinutes;
  final DateTime startDate;
  final DateTime? endDate;
  final int sortOrder;
  final bool isCustom;
  final String? templateKey;
}
