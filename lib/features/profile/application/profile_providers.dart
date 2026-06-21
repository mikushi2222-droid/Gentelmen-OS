import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gentleman_os/core/db/database_provider.dart';
import 'package:gentleman_os/features/profile/data/profile_repository_impl.dart';
import 'package:gentleman_os/features/profile/domain/profile_repository.dart';
import 'package:gentleman_os/shared/models/user_profile.dart';

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => ProfileRepositoryImpl(ref.watch(profileDaoProvider)),
);

final profileProvider = StreamProvider<UserProfileModel?>(
  (ref) => ref.watch(profileRepositoryProvider).watchProfile(),
);
