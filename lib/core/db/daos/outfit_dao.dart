import 'package:drift/drift.dart';
import 'package:gentleman_os/core/db/app_database.dart';
import 'package:gentleman_os/core/db/tables/outfits_table.dart';

part 'outfit_dao.g.dart';

@DriftAccessor(tables: [Outfits, OutfitItems, WearLogs])
class OutfitDao extends DatabaseAccessor<AppDatabase> with _$OutfitDaoMixin {
  OutfitDao(super.db);

  Stream<List<OutfitsData>> watchAll() =>
      (select(outfits)..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .watch();

  Future<OutfitsData?> getById(String id) =>
      (select(outfits)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<List<OutfitItemsData>> getItemsForOutfit(String outfitId) =>
      (select(outfitItems)..where((t) => t.outfitId.equals(outfitId))).get();

  Future<void> saveOutfit(
    OutfitsCompanion outfit,
    List<String> itemIds,
  ) =>
      transaction(() async {
        await into(outfits).insertOnConflictUpdate(outfit);
        await (delete(outfitItems)
              ..where((t) => t.outfitId.equals(outfit.id.value)))
            .go();
        for (final itemId in itemIds) {
          await into(outfitItems).insert(
            OutfitItemsCompanion.insert(
              outfitId: outfit.id.value,
              itemId: itemId,
            ),
          );
        }
      });

  Future<int> remove(String id) =>
      (delete(outfits)..where((t) => t.id.equals(id))).go();

  Future<void> updateScore(String id, double score) =>
      (update(outfits)..where((t) => t.id.equals(id)))
          .write(OutfitsCompanion(score: Value(score)));

  Future<void> updateNotes(String id, String? notes) =>
      (update(outfits)..where((t) => t.id.equals(id)))
          .write(OutfitsCompanion(notes: Value(notes)));

  Future<bool> wasCreatedToday() async {
    final today = DateTime.now();
    final dayStart = DateTime(today.year, today.month, today.day);
    final row = await (select(outfits)
          ..where((t) => t.createdAt.isBiggerOrEqualValue(dayStart))
          ..limit(1))
        .getSingleOrNull();
    return row != null;
  }
}
