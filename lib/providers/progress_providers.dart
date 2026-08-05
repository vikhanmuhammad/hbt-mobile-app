import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/habit_schedule.dart';
import '../domain/models/habit.dart';
import '../domain/models/habit_log.dart';
import '../domain/models/habit_with_progress.dart';
import 'core_providers.dart';
import 'habit_providers.dart';

part 'progress_providers.g.dart';

@riverpod
Stream<List<HabitLog>> logsForDate(Ref ref, DateTime date) {
  return ref.watch(habitLogRepositoryProvider).watchLogsForDate(date);
}

List<HabitWithProgress> _mergeHabitsWithLogs(
  List<Habit> habits,
  List<HabitLog> logs,
  DateTime date,
) {
  final logByHabit = {for (final l in logs) l.habitId: l};
  return habits.where((h) => isHabitActiveOn(h, date)).map((h) {
    final log = logByHabit[h.id];
    return HabitWithProgress(
      habit: h,
      progressValue: log?.progressValue ?? 0,
      isDone: log?.isDone ?? false,
    );
  }).toList();
}

/// Semua habit aktif ditagih pada [date] (flat, lintas goal phrase), dengan
/// progress-nya. Dipakai di Beranda (flat list, CLAUDE.md v3 §6.1) dan
/// Riwayat/Kalender (detail hari, untuk backfill).
@riverpod
List<HabitWithProgress> habitsWithProgressForDate(Ref ref, DateTime date) {
  final habits = ref.watch(allActiveHabitsProvider).value ?? [];
  final logs = ref.watch(logsForDateProvider(date)).value ?? [];
  return _mergeHabitsWithLogs(habits, logs, date);
}
