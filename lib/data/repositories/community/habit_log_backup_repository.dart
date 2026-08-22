import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../domain/date_utils.dart';

class BackedUpHabitLog {
  const BackedUpHabitLog({
    required this.date,
    required this.progressValue,
    required this.isDone,
  });

  final DateTime date;
  final int progressValue;
  final bool isDone;
}

/// Backup privat per-akun dari log harian habit yang terhubung ke Community
/// (`users/{uid}/linkedHabitLogs/{groupHabitId}/entries/{yyyy-MM-dd}`) — beda
/// dari `groupHabits/{id}/leaderboard/{uid}` (agregat streak/progress yang
/// dibagikan ke sesama member Group), koleksi ini hanya bisa dibaca/ditulis
/// oleh pemiliknya sendiri (lihat firestore.rules) dan isinya cuma log
/// harian yang persis sama dengan yang tersimpan lokal.
///
/// Tujuannya: kalau user uninstall lalu suatu saat "Add to My Habits" lagi
/// ke Group Habit yang sama, histori hariannya bisa direstore ke habit
/// lokal yang baru dibuat — bukan mulai kosong seolah habitnya baru. Habit
/// yang tidak pernah dihubungkan ke Community sama sekali tetap tidak
/// punya backup apapun (murni on-device, sesuai desain privasi awal).
class HabitLogBackupRepository {
  HabitLogBackupRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _entries(
    String uid,
    String groupHabitId,
  ) =>
      _firestore
          .collection('users')
          .doc(uid)
          .collection('linkedHabitLogs')
          .doc(groupHabitId)
          .collection('entries');

  String _dateKey(DateTime date) {
    final d = dateOnly(date);
    return '${d.year.toString().padLeft(4, '0')}-'
        '${d.month.toString().padLeft(2, '0')}-'
        '${d.day.toString().padLeft(2, '0')}';
  }

  Future<void> upsertLog({
    required String uid,
    required String groupHabitId,
    required DateTime date,
    required int progressValue,
    required bool isDone,
  }) async {
    await _entries(uid, groupHabitId).doc(_dateKey(date)).set({
      'date': Timestamp.fromDate(dateOnly(date)),
      'progressValue': progressValue,
      'isDone': isDone,
    });
  }

  Future<List<BackedUpHabitLog>> fetchAll({
    required String uid,
    required String groupHabitId,
  }) async {
    final snapshot = await _entries(uid, groupHabitId).get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return BackedUpHabitLog(
        date: (data['date'] as Timestamp).toDate(),
        progressValue: data['progressValue'] as int,
        isDone: data['isDone'] as bool,
      );
    }).toList();
  }
}
