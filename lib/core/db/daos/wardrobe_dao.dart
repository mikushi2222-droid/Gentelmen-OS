import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:gentleman_os/core/db/app_database.dart';
import 'package:gentleman_os/core/db/tables/clothing_items_table.dart';
import 'package:gentleman_os/core/db/tables/outfits_table.dart';
import 'package:gentleman_os/core/utils/app_logger.dart';

part 'wardrobe_dao.g.dart';

@DriftAccessor(tables: [ClothingItems, WearLogs])
class WardrobeDao extends DatabaseAccessor<AppDatabase>
    with _$WardrobeDaoMixin {
  WardrobeDao(super.db);

  static const String _tag = 'Wardrobe';

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

  Future<void> upsert(ClothingItemsCompanion item) {
    AppLogger.instance.i(_tag,
        'Сохранение вещи ${item.id.present ? item.id.value : '?'}'
        '${item.name.present ? ' «${item.name.value}»' : ''}');
    return into(clothingItems).insertOnConflictUpdate(item);
  }

  Future<int> remove(String id) {
    AppLogger.instance.i(_tag, 'Удаление вещи $id');
    return (delete(clothingItems)..where((t) => t.id.equals(id))).go();
  }

  Future<void> addWear(WearLogsCompanion wear) {
    AppLogger.instance.i(_tag,
        'Отметка носки ${wear.itemId.present ? wear.itemId.value : '?'}');
    return into(wearLogs).insert(wear);
  }

  Future<int> getWearCount(String itemId) async {
    final count = await (select(wearLogs)
          ..where((t) => t.itemId.equals(itemId)))
        .get();
    return count.length;
  }

  Future<void> incrementWearCount(String itemId) => transaction(() async {
        final count = await getWearCount(itemId);
        final now = DateTime.now();
        await (update(clothingItems)..where((t) => t.id.equals(itemId)))
            .write(ClothingItemsCompanion(wearCount: Value(count + 1)));
        await into(wearLogs).insert(
          WearLogsCompanion.insert(
            id: const Uuid().v4(),
            itemId: itemId,
            wornAt: now,
          ),
        );
      });

  Future<List<ClothingItemsData>> getAvailable() =>
      (select(clothingItems)
            ..where((t) => t.isAvailable.equals(true)))
          .get();

  Future<DateTime?> lastWornAt(String itemId) async {
    final rows = await (select(wearLogs)
          ..where((t) => t.itemId.equals(itemId))
          ..orderBy([(t) => OrderingTerm.desc(t.wornAt)])
          ..limit(1))
        .get();
    return rows.isEmpty ? null : rows.first.wornAt;
  }
}
