import 'package:drift/drift.dart';
import 'package:gentleman_os/core/db/app_database.dart';
import 'package:gentleman_os/core/db/tables/user_profile_table.dart';

part 'profile_dao.g.dart';

@DriftAccessor(tables: [UserProfile])
class ProfileDao extends DatabaseAccessor<AppDatabase>
    with _$ProfileDaoMixin {
  ProfileDao(super.db);

  Future<UserProfileData?> getProfile() =>
      (select(userProfile)..where((t) => t.id.equals(0))).getSingleOrNull();

  Stream<UserProfileData?> watchProfile() =>
      (select(userProfile)..where((t) => t.id.equals(0))).watchSingleOrNull();

  Future<void> upsertProfile(UserProfileCompanion companion) =>
      into(userProfile).insertOnConflictUpdate(companion);
}
