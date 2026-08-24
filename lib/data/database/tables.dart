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

/// goalPeriod is stored as text: daily / weekly / monthly.
///
/// Important note: `name` now holds the GOAL PHRASE ("Be Healthy"), not the
/// raw category name ("Health") — the goal phrase is what's shown
/// everywhere in the UI. The raw name only lives in `habit_templates.json`
/// (the `rawLabel` field), used for grouping while browsing recommendations.
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

  /// Terjemahan Indonesia dari `name` (goal phrase) — dwibahasa (CLAUDE.md
  /// §Bahasa). Nullable: kategori lama/custom yang belum sempat diisi
  /// fallback ke `name` (Inggris) saat ditampilkan.
  TextColumn get nameId => text().nullable()();

  /// Key stabil ke entri kategori di `habit_templates.json` (mis.
  /// 'save_money') — dipakai untuk mencocokkan ulang terjemahan/goal-phrase
  /// lookup tanpa bergantung ke string `name` yang sekarang bisa 2 bahasa.
  /// Null untuk kategori custom buatan user.
  TextColumn get templateKey => text().nullable()();
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
  // 'atLeast' (standar, progress >= goalValue) atau 'atMost' (progress <=
  // goalValue, mis. batas pengeluaran harian).
  TextColumn get goalDirection =>
      text().withDefault(const Constant('atLeast'))();
  TextColumn get taskDays => text()();
  TextColumn get timeRange =>
      text().withDefault(const Constant('anytime'))();
  BoolColumn get reminderEnabled =>
      boolean().withDefault(const Constant(false))();
  TextColumn get reminderTime => text().nullable()();
  /// Minutes between repeats starting at [reminderTime], e.g. every 30
  /// minutes — null means a single reminder at [reminderTime] (the
  /// pre-existing behavior). No end time: repeats until end of day.
  IntColumn get reminderIntervalMinutes => integer().nullable()();
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get endDate => dateTime().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();

  /// Terjemahan Indonesia dari `name` — dwibahasa (CLAUDE.md §Bahasa).
  /// Nullable: habit lama/custom yang belum sempat diisi fallback ke `name`
  /// (Inggris) saat ditampilkan.
  TextColumn get nameId => text().nullable()();

  /// True kalau title boleh diedit user. Habit dari template bawaan
  /// (`templateKey` non-null, dikonfirmasi lewat backfill) dikunci
  /// (`isCustom=false`); default true supaya baris lama yang gagal
  /// dicocokkan ke template tetap aman untuk diedit alih-alih tiba-tiba
  /// terkunci tanpa alasan jelas ke user.
  BoolColumn get isCustom =>
      boolean().withDefault(const Constant(true))();

  /// Key stabil ke entri habit di `habit_templates.json` (mis.
  /// 'drink_water'). Null untuk habit custom buatan user.
  TextColumn get templateKey => text().nullable()();
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

/// Relasi habit lokal ke Group Habit di Firestore (fitur Community, Pro-only)
/// — `groupId`/`groupHabitId` adalah document ID Firestore (text), bukan FK
/// lokal. Lihat update_v2.md §8.
@TableIndex(name: 'idx_habit_group_links_habit_id', columns: {#habitId})
class HabitGroupLinks extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get habitId =>
      integer().references(Habits, #id, onDelete: KeyAction.cascade)();
  TextColumn get groupId => text()();
  TextColumn get groupHabitId => text()();
  DateTimeColumn get linkedAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();

  /// Signed-in Firebase uid that created this link — this table is a local
  /// (per-device) DB, but a device isn't always 1:1 with 1 account (multiple
  /// accounts signed in/out on the same phone, or a shared/test device), so
  /// every link must be scoped to whoever actually made it. Without this,
  /// account B would see account A's links as "already linked" and vice
  /// versa. Nullable only for rows written before this column existed.
  TextColumn get uid => text().nullable()();

  @override
  List<Set<Column>> get uniqueKeys => [
        {habitId, groupHabitId},
      ];
}
