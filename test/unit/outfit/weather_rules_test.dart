import 'package:flutter_test/flutter_test.dart';
import 'package:gentleman_os/features/outfit_builder/domain/weather_rules.dart';
import 'package:gentleman_os/shared/enums/clothing_category.dart';
import 'package:gentleman_os/shared/enums/season.dart';
import 'package:gentleman_os/shared/enums/weather_condition.dart';
import 'package:gentleman_os/shared/models/clothing_item.dart';

ClothingItem _item(
  ClothingCategory cat, {
  Season season = Season.all,
  String? material,
  String name = 'Item',
}) =>
    ClothingItem(
      id: '${cat.name}_${season.name}',
      name: name,
      category: cat,
      season: season,
      material: material,
      createdAt: DateTime(2024),
    );

void main() {
  group('weatherScore', () {
    test('score в [0, 1] при любых данных', () {
      final cases = [
        weatherScore([], null, null, Season.all),
        weatherScore(
          [_item(ClothingCategory.shirt)],
          WeatherCondition.clear,
          20,
          Season.summer,
        ),
        weatherScore(
          [_item(ClothingCategory.coat)],
          WeatherCondition.snow,
          -5,
          Season.winter,
        ),
      ];
      for (final r in cases) {
        expect(r.score, inInclusiveRange(0.0, 1.0));
      }
    });

    test('все вещи соответствуют сезону → бонус', () {
      final summer = [
        _item(ClothingCategory.shirt, season: Season.summer),
        _item(ClothingCategory.trousers, season: Season.summer),
      ];
      final r = weatherScore(summer, null, null, Season.summer);
      expect(r.notes, anyElement(contains('сезону')));
      expect(r.score, greaterThanOrEqualTo(0.7));
    });

    test('несезонная вещь → штраф', () {
      final mixed = [
        _item(ClothingCategory.shirt, season: Season.summer),
        _item(ClothingCategory.coat, season: Season.winter),
      ];
      final r = weatherScore(mixed, null, null, Season.summer);
      expect(r.notes, anyElement(contains('Несезонн')));
    });

    test('холодная погода без верхней одежды → штраф', () {
      final items = [
        _item(ClothingCategory.shirt),
        _item(ClothingCategory.trousers),
      ];
      final r = weatherScore(items, null, 0, Season.all);
      expect(r.notes, anyElement(contains('верхняя одежда')));
      expect(r.score, lessThan(0.7));
    });

    test('холодная погода с пальто → бонус', () {
      final items = [
        _item(ClothingCategory.shirt),
        _item(ClothingCategory.trousers),
        _item(ClothingCategory.coat),
      ];
      final r = weatherScore(items, null, 0, Season.all);
      expect(r.notes, anyElement(contains('Верхний слой')));
    });

    test('жаркая погода с шерстью → штраф', () {
      final items = [
        ClothingItem(
          id: 'wool',
          name: 'Шерстяной свитер',
          category: ClothingCategory.shirt,
          material: 'шерсть',
          createdAt: DateTime(2024),
        ),
      ];
      final r = weatherScore(items, null, 30, Season.summer);
      expect(r.notes, anyElement(contains('жар')));
    });

    test('дождь без защиты → замечание', () {
      final items = [
        _item(ClothingCategory.shirt),
        _item(ClothingCategory.trousers),
      ];
      final r = weatherScore(items, WeatherCondition.rain, null, Season.all);
      expect(r.notes, anyElement(contains('осад')));
    });

    test('дождь с пальто → бонус', () {
      final items = [
        _item(ClothingCategory.coat),
        _item(ClothingCategory.trousers),
      ];
      final r = weatherScore(items, WeatherCondition.rain, null, Season.all);
      expect(r.notes, anyElement(contains('Защитный')));
    });
  });
}
