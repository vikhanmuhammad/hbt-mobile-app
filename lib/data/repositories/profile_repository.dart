import 'package:drift/drift.dart' show Value;

import '../../domain/models/onboarding_response.dart';
import '../../domain/models/user_profile.dart';
import '../database/app_database.dart' as db;
import 'mappers.dart';

class ProfileRepository {
  ProfileRepository(this._db);

  final db.AppDatabase _db;

  Stream<UserProfile?> watchProfile() {
    return _db.profileDao
        .watchProfile()
        .map((row) => row == null ? null : mapUserProfile(row));
  }

  Future<UserProfile?> getProfile() async {
    final row = await _db.profileDao.getProfile();
    return row == null ? null : mapUserProfile(row);
  }

  /// Dipanggil sekali di akhir onboarding user baru. Menyimpan profil +
  /// jawaban kuesioner gaya hidup dalam satu transaksi.
  Future<void> completeOnboarding({
    required String name,
    int? age,
    String? photoPath,
    required List<OnboardingResponse> responses,
  }) async {
    await _db.transaction(() async {
      await _db.profileDao.insertProfile(
        db.UserProfileCompanion.insert(
          name: name,
          age: Value(age),
          photoPath: Value(photoPath),
        ),
      );
      if (responses.isNotEmpty) {
        await _db.profileDao.saveOnboardingResponses([
          for (final r in responses)
            db.OnboardingResponsesCompanion.insert(
              questionKey: r.questionKey,
              answerValue: r.answerValue,
            ),
        ]);
      }
    });
  }

  Future<void> updateProfile(UserProfile profile) {
    return _db.profileDao.updateProfile(
      db.UserProfileCompanion(
        id: Value(profile.id),
        name: Value(profile.name),
        age: Value(profile.age),
        photoPath: Value(profile.photoPath),
        themeKey: Value(profile.themeKey),
        createdAt: Value(profile.createdAt),
      ),
    );
  }

  Future<void> setThemeKey(String themeKey) async {
    final profile = await getProfile();
    if (profile == null) return;
    await updateProfile(
      UserProfile(
        id: profile.id,
        name: profile.name,
        age: profile.age,
        photoPath: profile.photoPath,
        themeKey: themeKey,
        createdAt: profile.createdAt,
      ),
    );
  }
}
