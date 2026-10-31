// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit_spending_breakdown_dao.dart';

// ignore_for_file: type=lint
mixin _$HabitSpendingBreakdownDaoMixin on DatabaseAccessor<AppDatabase> {
  $CategoriesTable get categories => attachedDatabase.categories;
  $HabitsTable get habits => attachedDatabase.habits;
  $HabitSpendingBreakdownsTable get habitSpendingBreakdowns =>
      attachedDatabase.habitSpendingBreakdowns;
  HabitSpendingBreakdownDaoManager get managers =>
      HabitSpendingBreakdownDaoManager(this);
}

class HabitSpendingBreakdownDaoManager {
  final _$HabitSpendingBreakdownDaoMixin _db;
  HabitSpendingBreakdownDaoManager(this._db);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db.attachedDatabase, _db.categories);
  $$HabitsTableTableManager get habits =>
      $$HabitsTableTableManager(_db.attachedDatabase, _db.habits);
  $$HabitSpendingBreakdownsTableTableManager get habitSpendingBreakdowns =>
      $$HabitSpendingBreakdownsTableTableManager(
        _db.attachedDatabase,
        _db.habitSpendingBreakdowns,
      );
}
