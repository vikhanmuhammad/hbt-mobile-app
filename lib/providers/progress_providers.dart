import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/habit_schedule.dart';
import '../domain/models/category_progress.dart';
import '../domain/models/habit.dart';
import '../domain/models/habit_log.dart';
import '../domain/models/habit_with_progress.dart';
import 'category_providers.dart';
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

/// Habit dalam 1 kategori yang aktif ditagih pada [date], lengkap dengan
/// progress hari itu. Dipakai di Category Detail (Beranda level 2).
@riverpod
List<HabitWithProgress> habitsWithProgressForCategory(
  Ref ref,
  int categoryId,
  DateTime date,
) {
  final habits = ref.watch(habitsByCategoryProvider(categoryId)).value ?? [];
  final logs = ref.watch(logsForDateProvider(date)).value ?? [];
  return _mergeHabitsWithLogs(habits, logs, date);
}

/// Semua habit aktif ditagih pada [date] lintas kategori, dengan progress-nya.
/// Dipakai di Riwayat/Kalender (detail hari) untuk backfill. Lihat DESIGN.md §4.3.
@riverpod
List<HabitWithProgress> habitsWithProgressForDate(Ref ref, DateTime date) {
  final habits = ref.watch(allActiveHabitsProvider).value ?? [];
  final logs = ref.watch(logsForDateProvider(date)).value ?? [];
  return _mergeHabitsWithLogs(habits, logs, date);
}

/// Progress semua kategori pada [date]: dasar untuk grid kategori Beranda
/// (level 1) dan ring progress utama.
@riverpod
List<CategoryProgress> categoryProgressList(Ref ref, DateTime date) {
  final categories = ref.watch(categoriesProvider).value ?? [];
  final habits = ref.watch(allActiveHabitsProvider).value ?? [];
  final logs = ref.watch(logsForDateProvider(date)).value ?? [];

  final habitsByCategory = <int, List<Habit>>{};
  for (final h in habits) {
    habitsByCategory.putIfAbsent(h.categoryId, () => []).add(h);
  }

  return categories.map((c) {
    final catHabits = habitsByCategory[c.id] ?? [];
    return CategoryProgress(
      category: c,
      habitsToday: _mergeHabitsWithLogs(catHabits, logs, date),
    );
  }).toList();
}

@riverpod
({int done, int total}) homeProgress(Ref ref, DateTime date) {
  final categoryProgress = ref.watch(categoryProgressListProvider(date));
  var done = 0;
  var total = 0;
  for (final c in categoryProgress) {
    done += c.doneCount;
    total += c.totalCount;
  }
  return (done: done, total: total);
}
