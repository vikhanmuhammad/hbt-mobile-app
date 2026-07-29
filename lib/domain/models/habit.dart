import 'enums.dart';

class Habit {
  const Habit({
    required this.id,
    required this.categoryId,
    required this.name,
    this.description,
    required this.goalPeriod,
    required this.goalValue,
    required this.taskDays,
    required this.timeRange,
    required this.reminderEnabled,
    this.reminderTime,
    required this.startDate,
    this.endDate,
    required this.isActive,
    required this.createdAt,
  });

  final int id;
  final int categoryId;
  final String name;
  final String? description;
  final GoalPeriod goalPeriod;
  final int goalValue;
  final List<String> taskDays;
  final TimeRange timeRange;
  final bool reminderEnabled;
  final String? reminderTime;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isActive;
  final DateTime createdAt;
}
