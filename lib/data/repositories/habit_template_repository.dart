import '../../domain/models/habit_template.dart';
import '../assets/habit_templates_loader.dart';

class HabitTemplateRepository {
  HabitTemplateRepository(this._loader);

  final HabitTemplatesLoader _loader;

  List<CategoryTemplate>? _cache;

  Future<List<CategoryTemplate>> getAll() async {
    return _cache ??= await _loader.load();
  }

  /// Cari template kategori mentah yang goal phrase default-nya cocok
  /// dengan `goalPhrase` (nilai `Category.name` milik user).
  Future<CategoryTemplate?> findByGoalPhrase(String goalPhrase) async {
    final all = await getAll();
    for (final template in all) {
      if (template.defaultGoalPhrase == goalPhrase) return template;
    }
    return null;
  }
}
