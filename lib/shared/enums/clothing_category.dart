enum ClothingCategory {
  shirt,
  polo,
  tShirt,
  trousers,
  jeans,
  blazer,
  jacket,
  coat,
  shoes,
  accessory;

  String get label => switch (this) {
        ClothingCategory.shirt => 'Рубашка',
        ClothingCategory.polo => 'Поло',
        ClothingCategory.tShirt => 'Футболка',
        ClothingCategory.trousers => 'Брюки',
        ClothingCategory.jeans => 'Джинсы',
        ClothingCategory.blazer => 'Блейзер',
        ClothingCategory.jacket => 'Куртка',
        ClothingCategory.coat => 'Пальто',
        ClothingCategory.shoes => 'Обувь',
        ClothingCategory.accessory => 'Аксессуар',
      };

  bool get isTop => switch (this) {
        ClothingCategory.shirt ||
        ClothingCategory.polo ||
        ClothingCategory.tShirt =>
          true,
        _ => false,
      };

  bool get isBottom => switch (this) {
        ClothingCategory.trousers || ClothingCategory.jeans => true,
        _ => false,
      };

  bool get isLayer => switch (this) {
        ClothingCategory.blazer ||
        ClothingCategory.jacket ||
        ClothingCategory.coat =>
          true,
        _ => false,
      };
}
