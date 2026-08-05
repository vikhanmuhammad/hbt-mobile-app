import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'daos/category_dao.dart';
import 'daos/habit_dao.dart';
import 'daos/habit_log_dao.dart';
import 'daos/profile_dao.dart';
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [Categories, Habits, HabitLogs, UserProfile, OnboardingResponses],
  daos: [CategoryDao, HabitDao, HabitLogDao, ProfileDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.addColumn(habits, habits.goalUnit);
          }
          if (from < 3) {
            // v3: model goal phrase + icon/sortOrder habit + profil/kuesioner
            // onboarding. Masih tahap development, belum ada data pengguna
            // nyata yang berharga — wipe & reseed daripada migrasi kompatibel
            // data lama (Categories.name lama = nama mentah, bukan goal
            // phrase, jadi tidak ada mapping otomatis yang aman).
            await m.deleteTable('habit_logs');
            await m.deleteTable('habits');
            await m.deleteTable('categories');
            await m.createTable(categories);
            await m.createTable(habits);
            await m.createTable(habitLogs);
            await m.createTable(userProfile);
            await m.createTable(onboardingResponses);
          }
        },
      );

  /// Hapus semua kategori, habit, riwayat progress, profil, dan jawaban
  /// kuesioner — dipakai untuk "Lihat ulang alur onboarding (demo)" di
  /// Settings supaya app benar-benar mulai dari kosong. Menghapus
  /// `userProfile` penting supaya deteksi user baru/lama (CLAUDE.md v3 §4.2)
  /// kembali menganggap ini first launch.
  Future<void> clearAllData() {
    return transaction(() async {
      await delete(habitLogs).go();
      await delete(habits).go();
      await delete(categories).go();
      await delete(onboardingResponses).go();
      await delete(userProfile).go();
    });
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'habit_tracker.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
