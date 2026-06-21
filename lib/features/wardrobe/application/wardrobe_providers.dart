import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gentleman_os/core/db/database_provider.dart';
import 'package:gentleman_os/features/wardrobe/data/wardrobe_repository_impl.dart';
import 'package:gentleman_os/features/wardrobe/domain/wardrobe_repository.dart';
import 'package:gentleman_os/shared/enums/clothing_category.dart';
import 'package:gentleman_os/shared/models/clothing_item.dart';

final wardrobeRepositoryProvider = Provider<WardrobeRepository>(
  (ref) => WardrobeRepositoryImpl(ref.watch(wardrobeDaoProvider)),
);

final wardrobeListProvider = StreamProvider<List<ClothingItem>>(
  (ref) => ref.watch(wardrobeRepositoryProvider).watchAll(),
);

final wardrobeByCategoryProvider =
    StreamProvider.family<List<ClothingItem>, ClothingCategory>(
  (ref, category) =>
      ref.watch(wardrobeRepositoryProvider).watchByCategory(category),
);

final wardrobeItemProvider =
    FutureProvider.family<ClothingItem?, String>((ref, id) {
  return ref.watch(wardrobeRepositoryProvider).getById(id);
});
