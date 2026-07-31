import 'category.dart';
import 'habit_with_progress.dart';

/// Progress kategori untuk hari tertentu: habit yang aktif ditagih hari itu
/// di dalam kategori tsb, besera berapa yang sudah selesai.
class CategoryProgress {
  const CategoryProgress({
    required this.category,
    required this.habitsToday,
    required this.totalHabitsInCategory,
  });

  final Category category;
  final List<HabitWithProgress> habitsToday;

  /// Total habit di kategori ini (tidak dibatasi jadwal hari ini) — dipakai
  /// untuk menyembunyikan kategori yang belum punya habit sama sekali dari
  /// grid Beranda.
  final int totalHabitsInCategory;

  bool get hasAnyHabit => totalHabitsInCategory > 0;

  int get totalCount => habitsToday.length;

  int get doneCount => habitsToday.where((h) => h.isDone).length;

  double get ratio => totalCount == 0 ? 0 : doneCount / totalCount;
}
