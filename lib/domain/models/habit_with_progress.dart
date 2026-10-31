import 'habit.dart';

/// Habit hari ini beserta progress log-nya (kalau ada).
class HabitWithProgress {
  const HabitWithProgress({
    required this.habit,
    required this.date,
    required this.progressValue,
    required this.isDone,
  });

  final Habit habit;

  /// Tanggal yang dilihat (bisa beda dari hari ini kalau user membuka
  /// Riwayat/Kalender) — dipakai resolve goalValue efektif lewat
  /// `Habit.goalValueFor` untuk habit yang punya override weekend.
  final DateTime date;
  final int progressValue;
  final bool isDone;

  HabitWithProgress copyWith({int? progressValue, bool? isDone}) {
    return HabitWithProgress(
      habit: habit,
      date: date,
      progressValue: progressValue ?? this.progressValue,
      isDone: isDone ?? this.isDone,
    );
  }
}
