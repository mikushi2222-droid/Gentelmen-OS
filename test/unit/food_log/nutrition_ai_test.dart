import 'package:flutter_test/flutter_test.dart';
import 'package:gentleman_os/features/food_log/application/food_log_providers.dart';
import 'package:gentleman_os/features/food_log/domain/nutrition_ai_result.dart';

void main() {
  group('analyzeFood — offline fallback', () {
    test('null client → NutritionAiResult.empty', () async {
      final r = await analyzeFood(description: 'Стейк', client: null);
      expect(r.kcalEstimate, isNull);
      expect(r.proteinLevel, isNull);
      expect(r.insights, isEmpty);
    });

    test('empty description → NutritionAiResult.empty', () async {
      final r = await analyzeFood(description: '  ', client: null);
      expect(r, NutritionAiResult.empty);
    });
  });

  group('MealType', () {
    test('fromValue mapping is correct', () {
      expect(MealType.fromValue(0), MealType.breakfast);
      expect(MealType.fromValue(1), MealType.lunch);
      expect(MealType.fromValue(2), MealType.dinner);
      expect(MealType.fromValue(3), MealType.snack);
      expect(MealType.fromValue(99), MealType.snack);
      expect(MealType.fromValue(null), MealType.snack);
    });

    test('все типы имеют непустой label', () {
      for (final t in MealType.values) {
        expect(t.label, isNotEmpty);
      }
    });
  });

  group('NutritionAiResult.empty', () {
    test('все поля null или пусты', () {
      const r = NutritionAiResult.empty;
      expect(r.kcalEstimate, isNull);
      expect(r.proteinLevel, isNull);
      expect(r.processingLevel, isNull);
      expect(r.satietyNote, isNull);
      expect(r.insights, isEmpty);
    });
  });
}
