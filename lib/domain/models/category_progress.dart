import 'category.dart';
import 'habit_with_progress.dart';

/// Progress kategori untuk hari tertentu: habit yang aktif ditagih hari itu
/// di dalam kategori tsb, besera berapa yang sudah selesai.
class CategoryProgress {
  const CategoryProgress({
    required this.category,
    required this.habitsToday,
  });

  final Category category;
  final List<HabitWithProgress> habitsToday;

  int get totalCount => habitsToday.length;

  int get doneCount => habitsToday.where((h) => h.isDone).length;

  double get ratio => totalCount == 0 ? 0 : doneCount / totalCount;
}
