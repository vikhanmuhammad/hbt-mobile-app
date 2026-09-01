import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/habit_schedule.dart';
import '../domain/models/enums.dart';
import '../domain/models/habit_log.dart';
import '../domain/models/habit_with_progress.dart';
import 'core_providers.dart';
import 'habit_providers.dart';

part 'progress_providers.g.dart';

@riverpod
Stream<List<HabitLog>> logsForDate(Ref ref, DateTime date) {
  return ref.watch(habitLogRepositoryProvider).watchLogsForDate(date);
}

@riverpod
Stream<List<HabitLog>> logsInRange(Ref ref, DateTime start, DateTime end) {
  return ref.watch(habitLogRepositoryProvider).watchLogsInRange(start, end);
}

/// Total progressValue habit [habitId] dalam periode ([start]-[end], lihat
/// [periodBoundsFor]) yang memuat [date] — dijumlahkan dari semua log
/// harian dalam rentang itu, bukan cuma log hari [date] itu sendiri. Ini
/// yang bikin progress habit weekly/monthly tetap "nyambung" ketika hari
/// berganti, bukannya balik ke 0 (log baru untuk hari baru memang belum
/// ada, tapi kontribusi hari-hari sebelumnya dalam periode yang sama tetap
/// terhitung).
int _sumProgressInRange(List<HabitLog> logs, int habitId) =>
    logs.where((l) => l.habitId == habitId).fold(0, (sum, l) => sum + l.progressValue);

/// Semua habit aktif ditagih pada [date] (flat, lintas goal phrase), dengan
/// progress-nya. Dipakai di Beranda (flat list, CLAUDE.md v3 §6.1) dan
/// Riwayat/Kalender (detail hari, untuk backfill).
@riverpod
List<HabitWithProgress> habitsWithProgressForDate(Ref ref, DateTime date) {
  final habits = ref.watch(allActiveHabitsProvider).value ?? [];
  final activeHabits = habits.where((h) => isHabitActiveOn(h, date)).toList();

  final dayLogs = ref.watch(logsForDateProvider(date)).value ?? [];
  final dayLogByHabit = {for (final l in dayLogs) l.habitId: l};

  List<HabitLog>? weeklyLogs;
  if (activeHabits.any((h) => h.goalPeriod == GoalPeriod.weekly)) {
    final (start, end) = periodBoundsFor(GoalPeriod.weekly, date);
    weeklyLogs = ref.watch(logsInRangeProvider(start, end)).value ?? [];
  }

  List<HabitLog>? monthlyLogs;
  if (activeHabits.any((h) => h.goalPeriod == GoalPeriod.monthly)) {
    final (start, end) = periodBoundsFor(GoalPeriod.monthly, date);
    monthlyLogs = ref.watch(logsInRangeProvider(start, end)).value ?? [];
  }

  return activeHabits.map((h) {
    final progressValue = switch (h.goalPeriod) {
      GoalPeriod.daily => dayLogByHabit[h.id]?.progressValue ?? 0,
      GoalPeriod.weekly => _sumProgressInRange(weeklyLogs!, h.id),
      GoalPeriod.monthly => _sumProgressInRange(monthlyLogs!, h.id),
    };
    return HabitWithProgress(
      habit: h,
      date: date,
      progressValue: progressValue,
      isDone: h.isAchieved(progressValue, date: date),
    );
  }).toList();
}
