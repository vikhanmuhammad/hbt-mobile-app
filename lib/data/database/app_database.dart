import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'daos/category_dao.dart';
import 'daos/habit_dao.dart';
import 'daos/habit_group_link_dao.dart';
import 'daos/habit_log_dao.dart';
import 'daos/profile_dao.dart';
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Categories,
    Habits,
    HabitLogs,
    UserProfile,
    OnboardingResponses,
    HabitGroupLinks,
  ],
  daos: [CategoryDao, HabitDao, HabitLogDao, ProfileDao, HabitGroupLinkDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 8;

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
          if (from < 4) {
            // v4: goalDirection (atLeast/atMost) — kolom baru dengan default
            // 'atLeast', jadi cukup addColumn, tidak perlu wipe data.
            await m.addColumn(habits, habits.goalDirection);
          }
          if (from < 5) {
            // v5: HabitGroupLinks — tabel baru untuk fitur Community (Pro),
            // relasi habit lokal ke Group Habit di Firestore.
            await m.createTable(habitGroupLinks);
          }
          if (from < 6) {
            // v6: HabitGroupLinks.uid — scope link ke akun yang membuatnya,
            // supaya ganti-ganti akun di 1 device tidak saling menganggap
            // habit orang lain "sudah linked" (lihat dokumentasi kolom uid
            // di tables.dart). Baris lama (uid null) otomatis jadi tidak
            // terlihat oleh siapapun — aman, tinggal link ulang.
            await m.addColumn(habitGroupLinks, habitGroupLinks.uid);
          }
          if (from < 7) {
            // v7: dwibahasa (ID/EN) untuk title habit & goal phrase kategori,
            // plus isCustom/templateKey untuk mengunci edit title bawaan.
            // Semua kolom baru nullable/berdefault aman — baris lama otomatis
            // isCustom=true (bisa diedit) sampai routine backfill sekali-jalan
            // mencocokkannya ke template dan mengisi nameId/templateKey.
            await m.addColumn(categories, categories.nameId);
            await m.addColumn(categories, categories.templateKey);
            await m.addColumn(habits, habits.nameId);
            await m.addColumn(habits, habits.isCustom);
            await m.addColumn(habits, habits.templateKey);
          }
          if (from < 8) {
            // v8: reminderIntervalMinutes — repeat a reminder every N minutes
            // starting at reminderTime, instead of just once/day. Nullable,
            // defaults to null (single reminder, unchanged behavior).
            await m.addColumn(habits, habits.reminderIntervalMinutes);
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
      // Must go before `habits` — otherwise these links are left pointing
      // at habitIds that no longer exist. Previously missing here: the
      // Community tab would keep matching against those stale links
      // (`linkedGroupHabitIds`) so a re-created habit with the same name
      // could never re-link, and its progress would silently stop
      // reaching Firestore since no *current* habitId had a link anymore.
      await delete(habitGroupLinks).go();
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
