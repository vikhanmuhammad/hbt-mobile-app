import 'habit.dart';

/// Habit hari ini beserta progress log-nya (kalau ada).
class HabitWithProgress {
  const HabitWithProgress({
    required this.habit,
    required this.progressValue,
    required this.isDone,
  });

  final Habit habit;
  final int progressValue;
  final bool isDone;

  HabitWithProgress copyWith({int? progressValue, bool? isDone}) {
    return HabitWithProgress(
      habit: habit,
      progressValue: progressValue ?? this.progressValue,
      isDone: isDone ?? this.isDone,
    );
  }
}
