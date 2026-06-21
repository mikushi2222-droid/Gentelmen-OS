import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gentleman_os/core/db/database_provider.dart';
import 'package:gentleman_os/features/settings/domain/export_service.dart';

final exportServiceProvider = Provider<ExportService>((ref) {
  return ExportService(
    profileDao: ref.watch(profileDaoProvider),
    wardrobeDao: ref.watch(wardrobeDaoProvider),
    outfitDao: ref.watch(outfitDaoProvider),
    measurementDao: ref.watch(measurementDaoProvider),
    knowledgeDao: ref.watch(knowledgeDaoProvider),
    habitsDao: ref.watch(habitsDaoProvider),
    rpgDao: ref.watch(rpgDaoProvider),
    purchasesDao: ref.watch(purchasesDaoProvider),
  );
});
