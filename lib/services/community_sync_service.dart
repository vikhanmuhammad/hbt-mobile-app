import '../data/repositories/community/community_repository.dart';
import '../data/repositories/community/habit_log_backup_repository.dart';
import '../data/repositories/habit_group_link_repository.dart';
import '../data/repositories/habit_log_repository.dart';
import '../data/repositories/habit_repository.dart';
import '../domain/date_utils.dart';
import '../domain/habit_schedule.dart';
import '../domain/models/habit.dart';
import '../domain/models/habit_log.dart';

/// Tracking tetap offline-first — user tidak menambah langkah manual apapun
/// (update_v2.md §7). Setiap kali progress habit yang linked ke Group Habit
/// berubah, service ini menghitung ulang agregat (streak & total progress
/// periode berjalan) dan push ke Firestore. `cloud_firestore` sudah punya
/// offline persistence bawaan, jadi kalau device offline saat dipanggil,
/// write ini otomatis di-queue lokal dan jalan begitu koneksi kembali —
/// tidak perlu antrean manual terpisah.
class CommunitySyncService {
  CommunitySyncService({
    required HabitGroupLinkRepository linkRepository,
    required HabitRepository habitRepository,
    required HabitLogRepository habitLogRepository,
    required CommunityRepository communityRepository,
    required HabitLogBackupRepository habitLogBackupRepository,
  })  : _linkRepository = linkRepository,
        _habitRepository = habitRepository,
        _habitLogRepository = habitLogRepository,
        _communityRepository = communityRepository,
        _habitLogBackupRepository = habitLogBackupRepository;

  final HabitGroupLinkRepository _linkRepository;
  final HabitRepository _habitRepository;
  final HabitLogRepository _habitLogRepository;
  final CommunityRepository _communityRepository;
  final HabitLogBackupRepository _habitLogBackupRepository;

  /// Dipanggil (fire-and-forget, tidak boleh blokir alur tracking harian)
  /// setelah `HabitLogRepository.setProgress` sukses untuk habit manapun —
  /// no-op kalau habit itu tidak sedang linked ke Group Habit apapun. Selain
  /// push agregat (streak/progress periode) ke leaderboard, juga membackup
  /// log HARI [date] itu sendiri ke `HabitLogBackupRepository` — privat per
  /// akun, dipakai buat restore histori kalau user reconnect lagi ke Group
  /// Habit yang sama pasca uninstall (lihat `restoreCommunityHabitBackup`).
  /// Habit yang tidak linked tetap tidak pernah punya backup apapun.
  Future<void> syncHabit({
    required int habitId,
    required DateTime date,
    required String uid,
    required String displayName,
    String? avatarIcon,
  }) async {
    final links = await _linkRepository.getForHabit(habitId, uid);
    if (links.isEmpty) return;

    final habit = await _habitRepository.getById(habitId);
    if (habit == null) return;

    final logs = await _habitLogRepository.getLogsForHabit(habitId);
    final streak = _computeStreak(habit, logs);
    final progressValue = _computePeriodProgress(habit, logs);

    HabitLog? logForDate;
    for (final log in logs) {
      if (isSameDay(log.date, date)) {
        logForDate = log;
        break;
      }
    }

    for (final link in links) {
      await _communityRepository.upsertLeaderboardEntry(
        groupId: link.groupId,
        groupHabitId: link.groupHabitId,
        uid: uid,
        displayName: displayName,
        avatarIcon: avatarIcon,
        streak: streak,
        progressValue: progressValue,
      );
      await _habitLogBackupRepository.upsertLog(
        uid: uid,
        groupHabitId: link.groupHabitId,
        date: date,
        progressValue: logForDate?.progressValue ?? 0,
        isDone: logForDate?.isDone ?? false,
      );
      await _linkRepository.markSynced(link.id, DateTime.now());
    }
  }

  /// Dipanggil sekali tepat setelah user link/publish sebuah habit LAMA
  /// (yang sudah punya riwayat lokal) ke sebuah Group Habit — beda dari
  /// [syncHabit] yang jalan tiap ada progress baru dan cuma membackup log
  /// hari itu saja, method ini langsung: (1) push leaderboard entry supaya
  /// user langsung kelihatan tanpa menunggu update progress berikutnya, dan
  /// (2) membackup SELURUH riwayat log lokal habit itu sekaligus, supaya
  /// kalau nanti reconnect pasca uninstall, histori dari sebelum tanggal
  /// link pun ikut bisa dipulihkan (bukan cuma dari tanggal link ke depan).
  Future<void> backfillOnLink({
    required int habitId,
    required int linkId,
    required String groupId,
    required String groupHabitId,
    required String uid,
    required String displayName,
    String? avatarIcon,
  }) async {
    final habit = await _habitRepository.getById(habitId);
    if (habit == null) return;

    final logs = await _habitLogRepository.getLogsForHabit(habitId);
    final streak = _computeStreak(habit, logs);
    final progressValue = _computePeriodProgress(habit, logs);

    await _communityRepository.upsertLeaderboardEntry(
      groupId: groupId,
      groupHabitId: groupHabitId,
      uid: uid,
      displayName: displayName,
      avatarIcon: avatarIcon,
      streak: streak,
      progressValue: progressValue,
    );

    for (final log in logs) {
      await _habitLogBackupRepository.upsertLog(
        uid: uid,
        groupHabitId: groupHabitId,
        date: log.date,
        progressValue: log.progressValue,
        isDone: log.isDone,
      );
    }

    await _linkRepository.markSynced(linkId, DateTime.now());
  }

  /// Hari berturut-turut (mundur dari hari ini) di mana habit terjadwal
  /// aktif (`isHabitActiveOn`) dan tercapai — hari yang tidak terjadwal
  /// dilewati tanpa memutus streak.
  int _computeStreak(Habit habit, List<HabitLog> logs) {
    final byDate = {for (final log in logs) dateOnly(log.date): log};
    var streak = 0;
    var day = today();
    while (today().difference(day).inDays <= 730) {
      if (!isHabitActiveOn(habit, day)) {
        day = day.subtract(const Duration(days: 1));
        continue;
      }
      final log = byDate[day];
      if (log == null || !log.isDone) break;
      streak++;
      day = day.subtract(const Duration(days: 1));
    }
    return streak;
  }

  /// Akumulasi progressValue dalam periode berjalan sesuai `goalPeriod`
  /// habit (hari ini / minggu ini Senin-Minggu / bulan ini).
  int _computePeriodProgress(Habit habit, List<HabitLog> logs) {
    final (start, end) = periodBoundsFor(habit.goalPeriod, today());
    return logs
        .where((l) =>
            !dateOnly(l.date).isBefore(start) && !dateOnly(l.date).isAfter(end))
        .fold(0, (sum, l) => sum + l.progressValue);
  }
}
