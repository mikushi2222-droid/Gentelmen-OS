import 'package:gentleman_os/shared/models/user_profile.dart';

abstract interface class ProfileRepository {
  Stream<UserProfileModel?> watchProfile();
  Future<UserProfileModel?> getProfile();
  Future<void> save(UserProfileModel profile);
}
