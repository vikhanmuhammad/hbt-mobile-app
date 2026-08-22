import '../data/repositories/community/community_repository.dart';
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
  })  : _linkRepository = linkRepository,
        _habitRepository = habitRepository,
        _habitLogRepository = habitLogRepository,
        _communityRepository = communityRepository;

  final HabitGroupLinkRepository _linkRepository;
  final HabitRepository _habitRepository;
  final HabitLogRepository _habitLogRepository;
  final CommunityRepository _communityRepository;

  /// Dipanggil (fire-and-forget, tidak boleh blokir alur tracking harian)
  /// setelah `HabitLogRepository.setProgress` sukses untuk habit manapun —
  /// no-op kalau habit itu tidak sedang linked ke Group Habit apapun.
  Future<void> syncHabit({
    required int habitId,
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
      await _linkRepository.markSynced(link.id, DateTime.now());
    }
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
