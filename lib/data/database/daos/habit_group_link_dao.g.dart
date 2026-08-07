// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit_group_link_dao.dart';

// ignore_for_file: type=lint
mixin _$HabitGroupLinkDaoMixin on DatabaseAccessor<AppDatabase> {
  $CategoriesTable get categories => attachedDatabase.categories;
  $HabitsTable get habits => attachedDatabase.habits;
  $HabitGroupLinksTable get habitGroupLinks => attachedDatabase.habitGroupLinks;
  HabitGroupLinkDaoManager get managers => HabitGroupLinkDaoManager(this);
}

class HabitGroupLinkDaoManager {
  final _$HabitGroupLinkDaoMixin _db;
  HabitGroupLinkDaoManager(this._db);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db.attachedDatabase, _db.categories);
  $$HabitsTableTableManager get habits =>
      $$HabitsTableTableManager(_db.attachedDatabase, _db.habits);
  $$HabitGroupLinksTableTableManager get habitGroupLinks =>
      $$HabitGroupLinksTableTableManager(
        _db.attachedDatabase,
        _db.habitGroupLinks,
      );
}
