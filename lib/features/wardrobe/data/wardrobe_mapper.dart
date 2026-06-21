import 'package:drift/drift.dart';
import 'package:gentleman_os/core/db/app_database.dart';
import 'package:gentleman_os/shared/enums/clothing_category.dart';
import 'package:gentleman_os/shared/enums/condition.dart';
import 'package:gentleman_os/shared/enums/fit.dart';
import 'package:gentleman_os/shared/enums/season.dart';
import 'package:gentleman_os/shared/models/clothing_item.dart';

extension ClothingItemRowMapper on ClothingItemsData {
  ClothingItem toDomain() => ClothingItem(
        id: id,
        name: name,
        category: ClothingCategory.values[category],
        brand: brand,
        size: size,
        color: color,
        material: material,
        season: Season.values[season],
        fit: Fit.values[fit],
        price: price,
        purchaseDate: purchaseDate,
        imagePath: imagePath,
        notes: notes,
        condition: Condition.values[condition],
        rating: rating,
        wearCount: wearCount,
        isAvailable: isAvailable,
        createdAt: createdAt,
      );
}

ClothingItemsCompanion clothingItemToCompanion(ClothingItem item) =>
    ClothingItemsCompanion(
      id: Value(item.id),
      name: Value(item.name),
      category: Value(item.category.index),
      brand: Value(item.brand),
      size: Value(item.size),
      color: Value(item.color),
      material: Value(item.material),
      season: Value(item.season.index),
      fit: Value(item.fit.index),
      price: Value(item.price),
      purchaseDate: Value(item.purchaseDate),
      imagePath: Value(item.imagePath),
      notes: Value(item.notes),
      condition: Value(item.condition.index),
      rating: Value(item.rating),
      wearCount: Value(item.wearCount),
      isAvailable: Value(item.isAvailable),
      createdAt: Value(item.createdAt),
    );
