class HabitLog {
  const HabitLog({
    required this.id,
    required this.habitId,
    required this.date,
    required this.progressValue,
    required this.isDone,
  });

  final int id;
  final int habitId;
  final DateTime date;
  final int progressValue;
  final bool isDone;
}
