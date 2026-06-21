import 'package:drift/drift.dart';
import 'package:gentleman_os/core/db/app_database.dart';
import 'package:gentleman_os/core/db/tables/clothing_items_table.dart';
import 'package:gentleman_os/core/db/tables/outfits_table.dart';

part 'wardrobe_dao.g.dart';

@DriftAccessor(tables: [ClothingItems, WearLogs])
class WardrobeDao extends DatabaseAccessor<AppDatabase>
    with _$WardrobeDaoMixin {
  WardrobeDao(super.db);

  Stream<List<ClothingItemsData>> watchAll() =>
      (select(clothingItems)
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .watch();

  Stream<List<ClothingItemsData>> watchByCategory(int categoryIndex) =>
      (select(clothingItems)
            ..where((t) => t.category.equals(categoryIndex))
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .watch();

  Future<ClothingItemsData?> getById(String id) =>
      (select(clothingItems)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<void> upsert(ClothingItemsCompanion item) =>
      into(clothingItems).insertOnConflictUpdate(item);

  Future<int> remove(String id) =>
      (delete(clothingItems)..where((t) => t.id.equals(id))).go();

  Future<void> addWear(WearLogsCompanion wear) =>
      into(wearLogs).insert(wear);

  Future<int> getWearCount(String itemId) async {
    final count = await (select(wearLogs)
          ..where((t) => t.itemId.equals(itemId)))
        .get();
    return count.length;
  }

  Future<void> incrementWearCount(String itemId) async {
    final count = await getWearCount(itemId);
    await (update(clothingItems)..where((t) => t.id.equals(itemId)))
        .write(ClothingItemsCompanion(wearCount: Value(count + 1)));
  }

  Future<List<ClothingItemsData>> getAvailable() =>
      (select(clothingItems)
            ..where((t) => t.isAvailable.equals(true)))
          .get();
}
