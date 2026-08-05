// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_dao.dart';

// ignore_for_file: type=lint
mixin _$ProfileDaoMixin on DatabaseAccessor<AppDatabase> {
  $UserProfileTable get userProfile => attachedDatabase.userProfile;
  $OnboardingResponsesTable get onboardingResponses =>
      attachedDatabase.onboardingResponses;
  ProfileDaoManager get managers => ProfileDaoManager(this);
}

class ProfileDaoManager {
  final _$ProfileDaoMixin _db;
  ProfileDaoManager(this._db);
  $$UserProfileTableTableManager get userProfile =>
      $$UserProfileTableTableManager(_db.attachedDatabase, _db.userProfile);
  $$OnboardingResponsesTableTableManager get onboardingResponses =>
      $$OnboardingResponsesTableTableManager(
        _db.attachedDatabase,
        _db.onboardingResponses,
      );
}
