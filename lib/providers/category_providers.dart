import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/models/category.dart';
import 'core_providers.dart';

part 'category_providers.g.dart';

@riverpod
Stream<List<Category>> categories(Ref ref) {
  return ref.watch(categoryRepositoryProvider).watchActiveCategories();
}
