import 'package:drift/drift.dart';
import 'package:gentleman_os/core/db/app_database.dart';
import 'package:gentleman_os/core/db/tables/purchase_wishes_table.dart';

part 'purchases_dao.g.dart';

@DriftAccessor(tables: [PurchaseWishes])
class PurchasesDao extends DatabaseAccessor<AppDatabase>
    with _$PurchasesDaoMixin {
  PurchasesDao(super.db);

  Stream<List<PurchaseWishesData>> watchAll() =>
      (select(purchaseWishes)
            ..orderBy([
              (t) => OrderingTerm.desc(t.priority),
              (t) => OrderingTerm.asc(t.createdAt),
            ]))
          .watch();

  Future<List<PurchaseWishesData>> getAll() => select(purchaseWishes).get();

  Future<void> upsert(PurchaseWishesCompanion wish) =>
      into(purchaseWishes).insertOnConflictUpdate(wish);

  Future<int> remove(String id) =>
      (delete(purchaseWishes)..where((t) => t.id.equals(id))).go();

  Future<void> updateStatus(String id, int status) =>
      (update(purchaseWishes)..where((t) => t.id.equals(id)))
          .write(PurchaseWishesCompanion(status: Value(status)));
}
