import '../../domain/models/habit.dart';
import '../../domain/models/habit_log.dart';
import '../database/app_database.dart' as db;
import 'mappers.dart';

class HabitLogRepository {
  HabitLogRepository(this._db);

  final db.AppDatabase _db;

  Stream<List<HabitLog>> watchLogsForDate(DateTime date) {
    return _db.habitLogDao
        .watchLogsForDate(date)
        .map((rows) => rows.map(mapHabitLog).toList());
  }

  Future<List<HabitLog>> getLogsForDate(DateTime date) async {
    final rows = await _db.habitLogDao.getLogsForDate(date);
    return rows.map(mapHabitLog).toList();
  }

  Future<List<HabitLog>> getLogsInRange(DateTime start, DateTime end) async {
    final rows = await _db.habitLogDao.getLogsInRange(start, end);
    return rows.map(mapHabitLog).toList();
  }

  Stream<List<HabitLog>> watchLogsInRange(DateTime start, DateTime end) {
    return _db.habitLogDao
        .watchLogsInRange(start, end)
        .map((rows) => rows.map(mapHabitLog).toList());
  }

  Future<List<HabitLog>> getLogsForHabit(int habitId) async {
    final rows = await _db.habitLogDao.getLogsForHabit(habitId);
    return rows.map(mapHabitLog).toList();
  }

  Future<HabitLog?> getLog(int habitId, DateTime date) async {
    final row = await _db.habitLogDao.getLog(habitId, date);
    return row == null ? null : mapHabitLog(row);
  }

  /// Set progress mutlak untuk habit pada tanggal tertentu. `isDone` dihitung
  /// otomatis lewat `habit.isAchieved()` — standar progressValue >=
  /// goalValue, kecuali habit `atMost` (mis. batas pengeluaran) yang
  /// terbalik: progressValue <= goalValue (CLAUDE.md §4).
  Future<void> setProgress({
    required Habit habit,
    required DateTime date,
    required int progressValue,
  }) async {
    final clamped = progressValue < 0 ? 0 : progressValue;
    await _db.habitLogDao.upsertProgress(
      habitId: habit.id,
      date: date,
      progressValue: clamped,
      isDone: habit.isAchieved(clamped, date: date),
    );
  }

  /// Toggle cepat untuk habit dengan goalValue 1 (checklist biasa).
  Future<void> toggleDone({
    required Habit habit,
    required DateTime date,
    required bool currentlyDone,
  }) async {
    await setProgress(
      habit: habit,
      date: date,
      progressValue: currentlyDone ? 0 : habit.goalValueFor(date),
    );
  }

  /// Menulis log historis mentah — dipakai saat restore backup Community
  /// (`HabitLogBackupRepository`) setelah reconnect pasca uninstall.
  /// `isDone` dipakai apa adanya dari nilai yang di-backup, bukan dihitung
  /// ulang lewat `Habit.isAchieved`, supaya tetap akurat walau habit yang
  /// baru dibuat ulang punya `goalDirection` berbeda dari aslinya (Group
  /// Habit belum menyimpan field itu).
  Future<void> restoreLog({
    required int habitId,
    required DateTime date,
    required int progressValue,
    required bool isDone,
  }) async {
    await _db.habitLogDao.upsertProgress(
      habitId: habitId,
      date: date,
      progressValue: progressValue,
      isDone: isDone,
    );
  }

  /// Applies an edit made against the *period total* (what the quick-
  /// progress sheet shows/edits for weekly/monthly habits — the sum across
  /// every day in the current period, see `progress_providers.dart`) onto
  /// [date]'s own log specifically, instead of overwriting that single
  /// day's log with the whole new total.
  ///
  /// Without this, saving the sheet for a weekly/monthly habit would stuff
  /// the *entire* new period total into just [date]'s log while every other
  /// day already contributing to that period keeps its own log untouched —
  /// so the period's real sum balloons by the old total on every single
  /// edit (openly visible once synced to a Community leaderboard, since
  /// that number is exactly this same period-sum, recomputed the same
  /// broken way). Applying just the delta (`newPeriodTotal -
  /// previousPeriodTotal`) on top of whatever [date] already had keeps the
  /// other days' contributions intact. For a `daily` habit, [date] IS the
  /// whole period, so `previousPeriodTotal` already equals its current log
  /// value and this reduces to a plain `setProgress` — same as before.
  Future<void> applyPeriodAwareEdit({
    required Habit habit,
    required DateTime date,
    required int previousPeriodTotal,
    required int newPeriodTotal,
  }) async {
    final delta = newPeriodTotal - previousPeriodTotal;
    final todayLog = await getLog(habit.id, date);
    final newTodayValue = (todayLog?.progressValue ?? 0) + delta;
    await setProgress(habit: habit, date: date, progressValue: newTodayValue);
  }

  Future<void> incrementProgress({
    required Habit habit,
    required DateTime date,
    required int currentValue,
    int step = 1,
  }) async {
    await setProgress(
      habit: habit,
      date: date,
      progressValue: currentValue + step,
    );
  }
}
