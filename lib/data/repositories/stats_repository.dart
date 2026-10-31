import '../../domain/date_utils.dart';
import '../../domain/habit_schedule.dart';
import '../../domain/models/category.dart';
import '../../domain/models/dashboard_summary.dart';
import '../../domain/models/day_summary.dart';
import '../../domain/models/enums.dart';
import '../../domain/models/habit.dart';
import '../../domain/models/habit_log.dart';
import '../database/app_database.dart' as db;
import 'mappers.dart';

class StatsRepository {
  StatsRepository(this._db);

  final db.AppDatabase _db;

  /// Habit finance (mis. batas pengeluaran) sengaja dikecualikan dari semua
  /// agregasi Dashboard — datanya cuma relevan/ditampilkan di halaman
  /// Keuangan supaya tidak membingungkan campur dengan habit non-finance.
  Future<List<Habit>> _dashboardEligibleHabits() async {
    final allHabits = (await _db.habitDao.getAll()).map(mapHabit).toList();
    final categories =
        (await _db.categoryDao.getAllActive()).map(mapCategory).toList();
    final categoryById = {for (final c in categories) c.id: c};
    return allHabits.where((h) {
      final category = categoryById[h.categoryId];
      return category == null || !isFinanceCategory(category);
    }).toList();
  }

  /// Earliest day whose logs can feed any goal period that overlaps
  /// [firstDay] — the Monday of its week (a month period starting on a 1st
  /// never starts earlier than that).
  DateTime _logWindowStart(DateTime firstDay) =>
      periodBoundsFor(GoalPeriod.weekly, firstDay).$1;

  /// Per (habit, day) for every day in [from]..[to]: the habit's progress
  /// summed from its goal period's start up to and including that day, plus
  /// whether any log exists in that stretch. Home's checklist uses exactly
  /// this rule (`habitsWithProgressForDate`), so the date-strip/calendar
  /// ring for a day always matches the checklist shown for it (feedback 7,
  /// slide 15-17). Only a day with its own log carries progress: a weekly
  /// habit done Monday doesn't make Tuesday look done (feedback 8, slide 5 &
  /// 6). [from] must be the start of a week (see [_logWindowStart]).
  Map<(int, DateTime), (int sum, bool hasLog)> _progressUpToDay(
    List<Habit> habits,
    List<HabitLog> logs,
    DateTime from,
    DateTime to,
  ) {
    final valueByHabitDay = <(int, DateTime), int>{};
    for (final log in logs) {
      final key = (log.habitId, dateOnly(log.date));
      valueByHabitDay[key] = (valueByHabitDay[key] ?? 0) + log.progressValue;
    }
    final result = <(int, DateTime), (int, bool)>{};
    for (final habit in habits) {
      var sum = 0;
      var hasLog = false;
      for (var day = from; !day.isAfter(to); day = day.add(const Duration(days: 1))) {
        if (isSameDay(periodBoundsFor(habit.goalPeriod, day).$1, day)) {
          sum = 0;
          hasLog = false;
        }
        final value = valueByHabitDay[(habit.id, day)];
        if (value != null) {
          sum += value;
          hasLog = true;
        }
        // A day with no log of its own stays empty even when earlier days
        // of the same period had progress (feedback 8, slide 5 & 6) — same
        // rule as `habitsWithProgressForDate`, where an unchecked 0 only
        // counts as a log for `atMost` habits.
        final ownLog = value != null && (value > 0 || habit.goalDirection == GoalDirection.atMost);
        result[(habit.id, day)] = ownLog ? (sum, hasLog) : (0, false);
      }
    }
    return result;
  }

  /// [habitIds] kosong berarti tanpa filter (semua habit ikut dihitung) —
  /// non-kosong membatasi agregasi cuma ke habit yang id-nya ada di set itu
  /// (dipakai filter icon habit di layar Dashboard gabungan).
  ///
  /// Iterasi dari sisi HABIT × hari terjadwal (sama seperti
  /// [computeMonthSummaries]/[computeDaySummary]), bukan dari sisi log —
  /// kalau tidak, habit yang baru dibuat dan belum pernah dilog sama sekali
  /// tidak akan pernah muncul di agregasi (dianggap "tidak ada" alih-alih
  /// "ada tapi 0%"), yang bikin rata-rata per kategori & Monthly Trend jadi
  /// bias ke atas karena diam-diam mengecualikan habit yang justru paling
  /// butuh terlihat progresnya masih 0.
  Future<DashboardSummary> computeDashboard({Set<int> habitIds = const {}}) async {
    final allHabits = await _dashboardEligibleHabits();
    final habits = habitIds.isEmpty
        ? allHabits
        : allHabits.where((h) => habitIds.contains(h.id)).toList();
    final categories =
        (await _db.categoryDao.getAllActive()).map(mapCategory).toList();

    if (habits.isEmpty) return DashboardSummary.empty;

    final now = dateOnly(DateTime.now());
    // Dibatasi 6 bulan terakhir (selaras dengan _MonthlyTrend yang cuma
    // menampilkan 6 bar) supaya biaya komputasi sebanding dengan aktivitas
    // baru-baru ini, bukan seluruh umur habit sejak dibuat.
    final windowStart = DateTime(now.year, now.month - 5, 1);
    final logStart = _logWindowStart(windowStart);
    final allLogs = (await _db.habitLogDao.getLogsInRange(logStart, now))
        .map(mapHabitLog)
        .toList();
    final progress = _progressUpToDay(habits, allLogs, logStart, now);

    // "Hari tercatat" tetap berarti hari yang benar-benar ada log-nya (bukan
    // hari yang cuma "terjadwal") — dipakai buat statistik "X Days Tracked",
    // jadi dihitung terpisah dari agregasi per-hari-terjadwal di bawah.
    //
    // Difilter ke `habits` (sama seperti `_periodProgressByHabit` di atas)
    // supaya log milik habit yang sudah dihapus — atau yang sedang
    // disaring oleh filter icon Dashboard — tidak ikut menaikkan angka ini.
    // Sebelumnya dihitung dari `allLogs` mentah tanpa filter sama sekali,
    // jadi kalau baris log-nya sempat tertinggal (mis. race dengan proses
    // hapus habit) atau kepilih di luar filter aktif, harinya tetap
    // "nyantol" selamanya di statistik ini walau habitnya sudah tidak ada
    // (feedback 7, slide 25).
    final habitIdsInScope = {for (final h in habits) h.id};
    final trackedDays = <DateTime>{
      for (final log in allLogs)
        if (habitIdsInScope.contains(log.habitId) && !log.date.isBefore(windowStart))
          dateOnly(log.date),
    };

    var totalLogs = 0;
    var doneLogs = 0.0;
    final habitTotals = <int, (int total, double done)>{};
    final monthTotals = <DateTime, (int total, double done)>{};

    for (final habit in habits) {
      for (var day = windowStart; !day.isAfter(now); day = day.add(const Duration(days: 1))) {
        if (!isHabitActiveOn(habit, day)) continue;

        final (sum, hasLog) = progress[(habit.id, day)]!;
        final credit = habit.progressCredit(sum, date: day, hasLog: hasLog);

        totalLogs++;
        doneLogs += credit;

        final habitPrev = habitTotals[habit.id] ?? (0, 0.0);
        habitTotals[habit.id] = (habitPrev.$1 + 1, habitPrev.$2 + credit);

        final monthKey = DateTime(day.year, day.month);
        final monthPrev = monthTotals[monthKey] ?? (0, 0.0);
        monthTotals[monthKey] = (monthPrev.$1 + 1, monthPrev.$2 + credit);
      }
    }

    final habitById = {for (final h in habits) h.id: h};
    final habitStats = habitTotals.entries
        .map((e) => HabitStat(
              habit: habitById[e.key]!,
              totalLogs: e.value.$1,
              doneLogs: e.value.$2,
            ))
        .toList()
      ..sort((a, b) => b.successRate.compareTo(a.successRate));

    final categoryById = {for (final c in categories) c.id: c};

    // Rata-rata per kategori dihitung dari successRate MASING-MASING habit
    // (unweighted per habit), bukan dijumlah dari log mentah — kalau tidak,
    // 1 habit yang sudah 100% tapi habit lain di kategori sama belum pernah
    // dilog sama sekali bisa membuat seluruh kategori tampak 100% padahal
    // habit-habit lain itu belum tersentuh.
    final categoryHabitRates = <int, List<double>>{};
    for (final stat in habitStats) {
      categoryHabitRates
          .putIfAbsent(stat.habit.categoryId, () => [])
          .add(stat.successRate);
    }
    final categoryStats = categoryHabitRates.entries
        .where((e) => categoryById.containsKey(e.key))
        .map((e) {
          final rates = e.value;
          final avg = rates.reduce((a, b) => a + b) / rates.length;
          return CategoryStat(
            category: categoryById[e.key]!,
            totalLogs: rates.length,
            doneLogs: avg * rates.length,
          );
        })
        .toList()
      ..sort((a, b) => b.successRate.compareTo(a.successRate));

    final monthlyStats = monthTotals.entries
        .map((e) => MonthlyStat(
              month: e.key,
              totalLogs: e.value.$1,
              doneLogs: e.value.$2,
            ))
        .toList()
      ..sort((a, b) => a.month.compareTo(b.month));

    return DashboardSummary(
      totalDaysTracked: trackedDays.length,
      totalLogs: totalLogs,
      doneLogs: doneLogs,
      categoryStats: categoryStats,
      habitStats: habitStats,
      monthlyStats: monthlyStats,
    );
  }

  /// Ringkasan tiap hari dalam bulan yang memuat [monthAnchor], dipakai untuk
  /// gradasi warna kalender Dashboard dan ring date strip Beranda. Sama
  /// seperti [computeDashboard], [habitIds] kosong berarti tanpa filter.
  ///
  /// Hari yang belum terjadi (setelah hari ini) sengaja kosong — belum
  /// dijalani, jadi tidak boleh tampak terisi (feedback 7, slide 17).
  Future<List<DaySummary>> computeMonthSummaries(
    DateTime monthAnchor, {
    Set<int> habitIds = const {},
  }) async {
    final allHabits = await _dashboardEligibleHabits();
    final habits = habitIds.isEmpty
        ? allHabits
        : allHabits.where((h) => habitIds.contains(h.id)).toList();
    final firstDay = DateTime(monthAnchor.year, monthAnchor.month, 1);
    final lastDay = DateTime(monthAnchor.year, monthAnchor.month + 1, 0);
    final logStart = _logWindowStart(firstDay);
    final logs = (await _db.habitLogDao.getLogsInRange(logStart, lastDay))
        .map(mapHabitLog)
        .toList();
    final progress = _progressUpToDay(habits, logs, logStart, lastDay);
    final todayDate = today();

    final summaries = <DaySummary>[];
    for (var day = firstDay;
        !day.isAfter(lastDay);
        day = day.add(const Duration(days: 1))) {
      var total = 0;
      var done = 0.0;
      if (!day.isAfter(todayDate)) {
        for (final habit in habits) {
          if (!isHabitActiveOn(habit, day)) continue;
          total++;
          final (sum, hasLog) = progress[(habit.id, day)]!;
          done += habit.progressCredit(sum, date: day, hasLog: hasLog);
        }
      }
      summaries.add(DaySummary(date: day, totalCount: total, doneCount: done));
    }
    return summaries;
  }

  /// Sama seperti [computeMonthSummaries] untuk 1 hari — dipakai Ringkasan
  /// Detail Persisten di Riwayat (§7) supaya panel detail konsisten dengan
  /// ring kalender & checklist Beranda untuk tanggal yang sama.
  Future<DaySummary> computeDaySummary(DateTime date) async {
    final habits = await _dashboardEligibleHabits();
    final day = dateOnly(date);
    final logStart = _logWindowStart(DateTime(day.year, day.month, 1));
    final logs = (await _db.habitLogDao.getLogsInRange(logStart, day)).map(mapHabitLog).toList();
    final progress = _progressUpToDay(habits, logs, logStart, day);

    var total = 0;
    var done = 0.0;
    for (final habit in habits) {
      if (!isHabitActiveOn(habit, day)) continue;
      total++;
      final (sum, hasLog) = progress[(habit.id, day)]!;
      done += habit.progressCredit(sum, date: day, hasLog: hasLog);
    }
    return DaySummary(date: day, totalCount: total, doneCount: done);
  }
}
