import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables.dart';

part 'profile_dao.g.dart';

@DriftAccessor(tables: [UserProfile, OnboardingResponses])
class ProfileDao extends DatabaseAccessor<AppDatabase>
    with _$ProfileDaoMixin {
  ProfileDao(super.db);

  Stream<UserProfileRow?> watchProfile() {
    return select(userProfile).watchSingleOrNull();
  }

  Future<UserProfileRow?> getProfile() {
    return select(userProfile).getSingleOrNull();
  }

  Future<int> insertProfile(UserProfileCompanion entry) {
    return into(userProfile).insert(entry);
  }

  Future<void> updateProfile(UserProfileCompanion entry) async {
    await update(userProfile).replace(entry);
  }

  Future<void> saveOnboardingResponses(
    List<OnboardingResponsesCompanion> entries,
  ) async {
    await batch((b) => b.insertAll(onboardingResponses, entries));
  }
}
