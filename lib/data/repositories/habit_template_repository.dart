import '../../domain/models/habit_template.dart';
import '../assets/habit_templates_loader.dart';

class HabitTemplateRepository {
  HabitTemplateRepository(this._loader);

  final HabitTemplatesLoader _loader;

  List<CategoryTemplate>? _cache;

  Future<List<CategoryTemplate>> getAll() async {
    return _cache ??= await _loader.load();
  }

  Future<CategoryTemplate?> findByCategoryName(String categoryName) async {
    final all = await getAll();
    for (final template in all) {
      if (template.name == categoryName) return template;
    }
    return null;
  }
}
