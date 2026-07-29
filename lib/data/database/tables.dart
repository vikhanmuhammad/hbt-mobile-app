import 'package:drift/drift.dart';

/// goalPeriod disimpan sebagai text: daily / weekly / monthly.
class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get icon => text().nullable()();
  TextColumn get colorHex => text().nullable()();
  BoolColumn get isDefault =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get isArchived =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}

/// taskDays disimpan sebagai JSON array text, mis. ["mon","wed","fri"] atau ["all"].
/// timeRange: anytime / morning / afternoon / evening / night.
class Habits extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get categoryId => integer().references(Categories, #id)();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  TextColumn get goalPeriod => text()();
  IntColumn get goalValue => integer().withDefault(const Constant(1))();
  TextColumn get taskDays => text()();
  TextColumn get timeRange =>
      text().withDefault(const Constant('anytime'))();
  BoolColumn get reminderEnabled =>
      boolean().withDefault(const Constant(false))();
  TextColumn get reminderTime => text().nullable()();
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get endDate => dateTime().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}

@TableIndex(name: 'idx_habit_logs_date', columns: {#date})
@TableIndex(name: 'idx_habit_logs_habit_id', columns: {#habitId})
class HabitLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get habitId =>
      integer().references(Habits, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get date => dateTime()();
  IntColumn get progressValue => integer().withDefault(const Constant(0))();
  BoolColumn get isDone => boolean().withDefault(const Constant(false))();

  @override
  List<Set<Column>> get uniqueKeys => [
        {habitId, date},
      ];
}
