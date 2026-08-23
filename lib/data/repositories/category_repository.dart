import 'package:drift/drift.dart' show Value;

import '../../domain/models/category.dart';
import '../../domain/models/habit_template.dart';
import '../database/app_database.dart' as db;
import 'mappers.dart';

class CategoryDeletionBlocked implements Exception {
  const CategoryDeletionBlocked();
}

class CategoryRepository {
  CategoryRepository(this._db);

  final db.AppDatabase _db;

  Stream<List<Category>> watchActiveCategories() {
    return _db.categoryDao
        .watchAllActive()
        .map((rows) => rows.map(mapCategory).toList());
  }

  Future<List<Category>> getActiveCategories() async {
    final rows = await _db.categoryDao.getAllActive();
    return rows.map(mapCategory).toList();
  }

  Future<Category?> getById(int id) async {
    final row = await _db.categoryDao.getById(id);
    return row == null ? null : mapCategory(row);
  }

  /// Dipanggil sekali di first launch: isi tabel Categories dari template
  /// JSON bawaan (isDefault = true), memakai goal phrase (bukan rawLabel)
  /// sebagai `name` — lihat CLAUDE.md v3 §3.1. Tidak melakukan apa-apa kalau
  /// sudah ada isi.
  Future<void> seedDefaultCategories(List<CategoryTemplate> templates) async {
    final existing = await _db.categoryDao.getAllActive();
    if (existing.isNotEmpty) return;

    for (final template in templates) {
      await _db.categoryDao.insertCategory(
        db.CategoriesCompanion.insert(
          name: template.defaultGoalPhrase,
          icon: Value(template.icon),
          colorHex: Value(template.colorHex),
          isDefault: const Value(true),
          nameId: Value(template.defaultGoalPhraseId),
          templateKey: Value(template.key),
        ),
      );
    }
  }

  Future<int> createCustomCategory({
    required String name,
    required String nameId,
    required String icon,
    required String colorHex,
  }) {
    return _db.categoryDao.insertCategory(
      db.CategoriesCompanion.insert(
        name: name,
        nameId: Value(nameId),
        icon: Value(icon),
        colorHex: Value(colorHex),
      ),
    );
  }

  Future<void> renameCategory(int id, String newName) {
    return _db.categoryDao.updateCategoryFields(id, name: newName);
  }

  /// Routine backfill sekali-jalan (lihat `HabitRepository.
  /// backfillTemplateProvenance`) — cocokkan kategori bawaan lama yang belum
  /// punya `templateKey` ke 13 goal phrase template lewat `name`, isi
  /// `nameId`/`templateKey`. Kategori custom (`isDefault=false`) tidak
  /// pernah dicocokkan.
  Future<void> backfillTemplateProvenance(List<CategoryTemplate> templates) async {
    final byNormalizedGoalPhrase = <String, CategoryTemplate>{
      for (final template in templates)
        template.defaultGoalPhrase.trim().toLowerCase(): template,
    };

    final rows = await _db.categoryDao.getAllActive();
    for (final row in rows) {
      if (!row.isDefault || row.templateKey != null) continue;
      final match = byNormalizedGoalPhrase[row.name.trim().toLowerCase()];
      if (match == null) continue;
      await _db.categoryDao.setTemplateProvenance(
        row.id,
        nameId: match.defaultGoalPhraseId ?? match.defaultGoalPhrase,
        templateKey: match.key,
      );
    }
  }

  /// Kategori bawaan hanya disembunyikan. Kategori custom dihapus permanen
  /// kalau tidak ada habit terkait; kalau ada, lempar [CategoryDeletionBlocked]
  /// supaya UI bisa minta konfirmasi eksplisit (data safety, CLAUDE.md §5/§7).
  Future<void> deleteOrArchive(Category category,
      {bool confirmedWithHabits = false}) async {
    if (category.isDefault) {
      await _db.categoryDao.archiveCategory(category.id);
      return;
    }

    final hasHabits = await _db.habitDao.hasHabitsInCategory(category.id);
    if (hasHabits && !confirmedWithHabits) {
      throw const CategoryDeletionBlocked();
    }
    await _db.categoryDao.deleteCustomCategory(category.id);
  }
}
