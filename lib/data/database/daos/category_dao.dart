import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables.dart';

part 'category_dao.g.dart';

@DriftAccessor(tables: [Categories])
class CategoryDao extends DatabaseAccessor<AppDatabase>
    with _$CategoryDaoMixin {
  CategoryDao(super.db);

  Stream<List<Category>> watchAllActive() {
    return (select(categories)
          ..where((c) => c.isArchived.equals(false))
          ..orderBy([
            (c) => OrderingTerm(expression: c.isDefault, mode: OrderingMode.desc),
            (c) => OrderingTerm(expression: c.id),
          ]))
        .watch();
  }

  Future<List<Category>> getAllActive() {
    return (select(categories)..where((c) => c.isArchived.equals(false)))
        .get();
  }

  Future<Category?> getById(int id) {
    return (select(categories)..where((c) => c.id.equals(id)))
        .getSingleOrNull();
  }

  Future<int> insertCategory(CategoriesCompanion entry) {
    return into(categories).insert(entry);
  }

  Future<void> updateCategoryFields(
    int id, {
    String? name,
    String? icon,
    String? colorHex,
  }) async {
    await (update(categories)..where((c) => c.id.equals(id))).write(
      CategoriesCompanion(
        name: name == null ? const Value.absent() : Value(name),
        icon: icon == null ? const Value.absent() : Value(icon),
        colorHex: colorHex == null ? const Value.absent() : Value(colorHex),
      ),
    );
  }

  /// Kategori bawaan hanya bisa disembunyikan (soft archive), tidak dihapus.
  /// Kategori custom bisa dihapus permanen kalau tidak ada habit terkait.
  Future<void> archiveCategory(int id) async {
    await (update(categories)..where((c) => c.id.equals(id))).write(
      const CategoriesCompanion(isArchived: Value(true)),
    );
  }

  Future<void> deleteCustomCategory(int id) async {
    await (delete(categories)..where((c) => c.id.equals(id))).go();
  }
}
