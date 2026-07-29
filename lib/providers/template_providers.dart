import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/models/habit_template.dart';
import 'core_providers.dart';

part 'template_providers.g.dart';

@riverpod
Future<List<CategoryTemplate>> habitTemplates(Ref ref) {
  return ref.watch(habitTemplateRepositoryProvider).getAll();
}
