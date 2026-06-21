import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:gentleman_os/shared/enums/clothing_category.dart';
import 'package:gentleman_os/shared/enums/condition.dart';
import 'package:gentleman_os/shared/enums/fit.dart';
import 'package:gentleman_os/shared/enums/season.dart';

part 'clothing_item.freezed.dart';
part 'clothing_item.g.dart';

@freezed
abstract class ClothingItem with _$ClothingItem {
  const factory ClothingItem({
    required String id,
    required String name,
    required ClothingCategory category,
    String? brand,
    String? size,
    String? color,
    String? material,
    @Default(Season.all) Season season,
    @Default(Fit.regular) Fit fit,
    double? price,
    DateTime? purchaseDate,
    String? imagePath,
    String? notes,
    @Default(Condition.good) Condition condition,
    int? rating,
    @Default(0) int wearCount,
    @Default(true) bool isAvailable,
    required DateTime createdAt,
  }) = _ClothingItem;

  const ClothingItem._();

  double? get costPerWear =>
      price != null && wearCount > 0 ? price! / wearCount : null;

  bool get isShinyOrThin {
    final m = material?.toLowerCase() ?? '';
    return m.contains('polyester') ||
        m.contains('полиэстер') ||
        m.contains('nylon') ||
        m.contains('нейлон') ||
        m.contains('satin') ||
        m.contains('атлас') ||
        m.contains('shine') ||
        m.contains('блеск');
  }

  factory ClothingItem.fromJson(Map<String, dynamic> json) =>
      _$ClothingItemFromJson(json);
}
