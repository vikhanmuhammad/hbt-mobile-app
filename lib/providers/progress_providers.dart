import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/date_utils.dart';
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
///
/// Only logs up to and including [upTo] count — a later day in the same
/// period must not make an earlier day look done, and this must match the
/// date-strip/calendar rings, which use the same rule (`StatsRepository`,
/// feedback 7, slide 15-17).
int _sumProgressInRange(List<HabitLog> logs, int habitId, DateTime upTo) => logs
    .where((l) => l.habitId == habitId && !l.date.isAfter(upTo))
    .fold(0, (sum, l) => sum + l.progressValue);

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

  final day = dateOnly(date);
  return activeHabits.map((h) {
    // The Budget Tracker card always shows one day against the daily-
    // prorated limit, so its progress is that day's spending only — not the
    // week/month running total, which read as e.g. "Rp65.000 of Rp33.333"
    // on a day that only had Rp50.000 (feedback 7, slide 29).
    if (h.isRupiah && h.goalDirection == GoalDirection.atMost) {
      final dayLog = dayLogByHabit[h.id];
      final spent = dayLog?.progressValue ?? 0;
      return HabitWithProgress(
        habit: h,
        date: date,
        progressValue: spent,
        isDone: dayLog != null && spent <= h.dailyRateFor(day),
      );
    }
    // A day only shows progress when something was logged on that day
    // itself. Carrying the week/month's earlier logs onto every later day
    // made a weekly habit look done on days the user never touched it —
    // missed days and days not reached yet included (feedback 8, slide 5 &
    // 6). On a day that does have its own log, the period's running total up
    // to that day is shown, so a 3x/week habit reads 1/3, 2/3, 3/3 on the
    // days it was actually done. A 0 left behind by unchecking counts as
    // nothing logged, except for `atMost` habits where 0 is a real entry.
    final ownValue = dayLogByHabit[h.id]?.progressValue;
    final hasLog = ownValue != null && (ownValue > 0 || h.goalDirection == GoalDirection.atMost);
    final progressValue = !hasLog
        ? 0
        : switch (h.goalPeriod) {
            GoalPeriod.daily => ownValue,
            GoalPeriod.weekly => _sumProgressInRange(weeklyLogs!, h.id, day),
            GoalPeriod.monthly => _sumProgressInRange(monthlyLogs!, h.id, day),
          };
    return HabitWithProgress(
      habit: h,
      date: date,
      progressValue: progressValue,
      // `hasLog` penting untuk habit `atMost` (mis. Budget Tracker): progress
      // 0 secara teknis "di bawah limit" jadi akan selalu terhitung tercapai,
      // padahal user belum input apapun untuk periode ini (feedback 6, slide
      // 10 & 11). Lihat `Habit.isAchieved`.
      isDone: h.isAchieved(progressValue, date: date, hasLog: hasLog),
    );
  }).toList();
}
