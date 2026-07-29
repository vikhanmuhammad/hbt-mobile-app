import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'daos/category_dao.dart';
import 'daos/habit_dao.dart';
import 'daos/habit_log_dao.dart';
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [Categories, Habits, HabitLogs],
  daos: [CategoryDao, HabitDao, HabitLogDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
      );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'habit_tracker.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
