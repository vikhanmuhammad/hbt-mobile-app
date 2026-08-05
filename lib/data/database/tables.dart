import 'package:drift/drift.dart';

/// Data diri user, dibuat sekali saat onboarding selesai. Keberadaan row di
/// tabel ini (bukan flag terpisah) yang dipakai untuk deteksi user baru vs
/// lama — lihat CLAUDE.md v3 §4.2.
///
/// `@DataClassName` dipakai supaya row generated Drift tidak bentrok nama
/// dengan `domain.UserProfile` (row-nya jadi `UserProfileRow`).
@DataClassName('UserProfileRow')
class UserProfile extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  IntColumn get age => integer().nullable()();
  TextColumn get photoPath => text().nullable()();
  TextColumn get themeKey =>
      text().withDefault(const Constant('teal_sage'))();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}

/// Jawaban kuesioner onboarding gaya hidup — disimpan untuk personalisasi
/// rekomendasi ke depan, belum dipakai untuk logic apapun saat ini.
class OnboardingResponses extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get questionKey => text()();
  TextColumn get answerValue => text()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}

/// goalPeriod disimpan sebagai text: daily / weekly / monthly.
///
/// Catatan penting: `name` sekarang berisi GOAL PHRASE ("Jadi Sehat"), bukan
/// nama kategori mentah ("Kesehatan") — goal phrase inilah yang ditampilkan
/// di semua tempat di UI. Nama mentah cuma hidup di `habit_templates.json`
/// (field `rawLabel`), dipakai untuk pengelompokan saat browsing rekomendasi.
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
  TextColumn get icon => text().nullable()(); // Font Awesome icon key
  TextColumn get goalPeriod => text()();
  IntColumn get goalValue => integer().withDefault(const Constant(1))();
  TextColumn get goalUnit => text().withDefault(const Constant('x'))();
  TextColumn get taskDays => text()();
  TextColumn get timeRange =>
      text().withDefault(const Constant('anytime'))();
  BoolColumn get reminderEnabled =>
      boolean().withDefault(const Constant(false))();
  TextColumn get reminderTime => text().nullable()();
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get endDate => dateTime().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
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
