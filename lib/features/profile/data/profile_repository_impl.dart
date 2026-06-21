import 'package:gentleman_os/core/db/daos/profile_dao.dart';
import 'package:gentleman_os/features/profile/data/profile_mapper.dart';
import 'package:gentleman_os/features/profile/domain/profile_repository.dart';
import 'package:gentleman_os/shared/models/user_profile.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  const ProfileRepositoryImpl(this._dao);

  final ProfileDao _dao;

  @override
  Stream<UserProfileModel?> watchProfile() =>
      _dao.watchProfile().map((row) => row?.toDomain());

  @override
  Future<UserProfileModel?> getProfile() async {
    final row = await _dao.getProfile();
    return row?.toDomain();
  }

  @override
  Future<void> save(UserProfileModel profile) =>
      _dao.upsertProfile(profileToCompanion(profile));
}
