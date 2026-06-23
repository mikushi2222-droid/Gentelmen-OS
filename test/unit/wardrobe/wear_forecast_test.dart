import 'package:flutter_test/flutter_test.dart';
import 'package:gentleman_os/features/wardrobe/domain/wear_forecast.dart';
import 'package:gentleman_os/shared/enums/clothing_category.dart';

void main() {
  group('garmentWearForecast', () {
    test('доля износа = носки / ресурс', () {
      // рубашка: ресурс 80, носок 40 → 50%
      final f = garmentWearForecast(
        category: ClothingCategory.shirt,
        wearCount: 40,
      );
      expect(f.wearPercent, 50);
      expect(f.remainingWears, 40);
      expect(f.remainingMonths, isNull);
    });

    test('износ ограничен 100% при перенашивании', () {
      final f = garmentWearForecast(
        category: ClothingCategory.shirt,
        wearCount: 1000,
      );
      expect(f.wearFraction, 1.0);
      expect(f.remainingWears, 0);
    });

    test('прогноз в месяцах при известной частоте', () {
      // джинсы: ресурс 300, носок 60 → остаток 240; 240/8 = 30 мес
      final f = garmentWearForecast(
        category: ClothingCategory.jeans,
        wearCount: 60,
        wearsPerMonth: 8,
      );
      expect(f.remainingMonths, 30);
    });

    test('объяснение непустое и упоминает категорию', () {
      final f = garmentWearForecast(
        category: ClothingCategory.coat,
        wearCount: 10,
      );
      expect(f.explanation, isNotEmpty);
      expect(f.explanation.first, contains(ClothingCategory.coat.label));
    });
  });

  group('statusLabel', () {
    WearForecast forecastFor(int wearCount) => garmentWearForecast(
          category: ClothingCategory.shirt, // ресурс 80
          wearCount: wearCount,
        );

    test('пороги статуса по доле износа', () {
      expect(forecastFor(0).statusLabel, 'Как новая'); // 0%
      expect(forecastFor(28).statusLabel, 'Рабочее состояние'); // 35%
      expect(forecastFor(56).statusLabel, 'Заметный износ'); // 70%
      expect(forecastFor(76).statusLabel, 'Пора задуматься о замене'); // 95%
      expect(forecastFor(1000).statusLabel, 'Пора задуматься о замене'); // 100%
    });
  });

  group('fabricDurabilityFactor', () {
    test('плотные ткани продлевают ресурс (×1.3)', () {
      expect(fabricDurabilityFactor('Деним'), 1.3);
      expect(fabricDurabilityFactor('100% шерсть'), 1.3);
      expect(fabricDurabilityFactor('Genuine leather'), 1.3);
    });

    test('деликатные ткани сокращают ресурс (×0.75)', () {
      expect(fabricDurabilityFactor('Шёлк'), 0.75);
      expect(fabricDurabilityFactor('Viscose blend'), 0.75);
    });

    test('неизвестная/пустая ткань нейтральна (1.0)', () {
      expect(fabricDurabilityFactor(null), 1.0);
      expect(fabricDurabilityFactor(''), 1.0);
      expect(fabricDurabilityFactor('хлопок'), 1.0);
    });
  });

  group('garmentWearForecast с поправкой на ткань', () {
    test('деним поднимает ресурс рубашки 80 → 104, доля падает', () {
      // 40 носок: без ткани 50%, с денимом 40/104 ≈ 38%
      final f = garmentWearForecast(
        category: ClothingCategory.shirt,
        wearCount: 40,
        material: 'деним',
      );
      expect(f.wearPercent, 38);
      expect(f.remainingWears, 64);
      expect(f.explanation.any((l) => l.contains('Поправка на ткань')), isTrue);
    });

    test('без материала поведение неизменно (обратная совместимость)', () {
      final f = garmentWearForecast(
        category: ClothingCategory.shirt,
        wearCount: 40,
      );
      expect(f.wearPercent, 50);
      expect(f.explanation.any((l) => l.contains('Поправка')), isFalse);
    });
  });

  group('wearsPerMonthSince', () {
    test('частота = носки / число календарных месяцев владения', () {
      // куплено 10 месяцев назад, 30 носок → 3 носки/мес
      final r = wearsPerMonthSince(
        purchaseDate: DateTime(2025, 1, 15),
        wearCount: 30,
        now: DateTime(2025, 11, 20),
      );
      expect(r, closeTo(3.0, 1e-9));
    });

    test('меньше месяца владения считается как один месяц', () {
      final r = wearsPerMonthSince(
        purchaseDate: DateTime(2025, 6, 1),
        wearCount: 5,
        now: DateTime(2025, 6, 20),
      );
      expect(r, 5.0);
    });

    test('null при отсутствии даты, отсутствии носок или дате в будущем', () {
      expect(
        wearsPerMonthSince(purchaseDate: null, wearCount: 10),
        isNull,
      );
      expect(
        wearsPerMonthSince(
          purchaseDate: DateTime(2025, 1, 1),
          wearCount: 0,
          now: DateTime(2025, 6, 1),
        ),
        isNull,
      );
      expect(
        wearsPerMonthSince(
          purchaseDate: DateTime(2026, 1, 1),
          wearCount: 10,
          now: DateTime(2025, 6, 1),
        ),
        isNull,
      );
    });
  });
}
