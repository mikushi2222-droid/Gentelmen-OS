import 'package:gentleman_os/core/db/daos/wardrobe_dao.dart';
import 'package:gentleman_os/features/wardrobe/data/wardrobe_mapper.dart';
import 'package:gentleman_os/features/wardrobe/domain/wardrobe_repository.dart';
import 'package:gentleman_os/shared/enums/clothing_category.dart';
import 'package:gentleman_os/shared/models/clothing_item.dart';

class WardrobeRepositoryImpl implements WardrobeRepository {
  const WardrobeRepositoryImpl(this._dao);

  final WardrobeDao _dao;

  @override
  Stream<List<ClothingItem>> watchAll() =>
      _dao.watchAll().map((rows) => rows.map((r) => r.toDomain()).toList());

  @override
  Stream<List<ClothingItem>> watchByCategory(ClothingCategory category) =>
      _dao
          .watchByCategory(category.index)
          .map((rows) => rows.map((r) => r.toDomain()).toList());

  @override
  Future<ClothingItem?> getById(String id) async {
    final row = await _dao.getById(id);
    return row?.toDomain();
  }

  @override
  Future<void> save(ClothingItem item) =>
      _dao.upsert(clothingItemToCompanion(item));

  @override
  Future<void> delete(String id) async => _dao.remove(id);

  @override
  Future<void> incrementWear(String id) => _dao.incrementWearCount(id);

  @override
  Future<List<ClothingItem>> getAvailable() async {
    final rows = await _dao.getAvailable();
    return rows.map((r) => r.toDomain()).toList();
  }
}
