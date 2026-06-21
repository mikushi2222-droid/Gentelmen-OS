import 'package:gentleman_os/shared/enums/clothing_category.dart';
import 'package:gentleman_os/shared/models/clothing_item.dart';

abstract interface class WardrobeRepository {
  Stream<List<ClothingItem>> watchAll();
  Stream<List<ClothingItem>> watchByCategory(ClothingCategory category);
  Future<ClothingItem?> getById(String id);
  Future<void> save(ClothingItem item);
  Future<void> delete(String id);
  Future<void> incrementWear(String id);
  Future<List<ClothingItem>> getAvailable();
}
