import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gentleman_os/core/ai/router_ai_client.dart';
import 'package:gentleman_os/core/db/app_database.dart';
import 'package:gentleman_os/core/db/daos/food_log_dao.dart';
import 'package:gentleman_os/core/db/database_provider.dart';
import 'package:gentleman_os/core/utils/app_logger.dart';
import 'package:gentleman_os/features/food_log/domain/nutrition_ai_result.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();
const _tag = 'FoodLog';

/// Записи питания за сегодня (реактивный стрим).
final todayFoodLogsProvider = StreamProvider<List<FoodLogsData>>((ref) {
  return ref.watch(foodLogDaoProvider).watchForDate(DateTime.now());
});

/// Сумма калорий за сегодня. null — нет логов или нет оценки.
final todayKcalTotalProvider = Provider<int?>((ref) {
  final logs = ref.watch(todayFoodLogsProvider).asData?.value;
  if (logs == null || logs.isEmpty) return null;
  final total = logs.fold<int>(0, (sum, l) => sum + (l.kcalEstimate ?? 0));
  return total > 0 ? total : null;
});

/// Анализирует текстовое описание еды через RouterAI.
/// Деградирует на [NutritionAiResult.empty] при любой ошибке или отсутствии ключа.
Future<NutritionAiResult> analyzeFood({
  required String description,
  required RouterAiClient? client,
}) async {
  if (client == null || description.trim().isEmpty) {
    return NutritionAiResult.empty;
  }
  try {
    final prompt = '''
Ты — ассистент по питанию. Проанализируй описание приёма пищи.
ВАЖНО: все значения приблизительные; никогда не симулируй точность.

Описание: "$description"

Верни СТРОГО валидный JSON без markdown:
{
  "kcal": <int или null>,
  "protein_level": "adequate"|"low"|"high",
  "processing_level": "whole"|"minimal"|"processed"|"ultra-processed",
  "satiety_note": "<одно предложение на английском>",
  "insights": ["<инсайт на рус>", ...]
}''';

    final raw = await client.chat(
      messages: [
        {'role': 'user', 'content': prompt},
      ],
      jsonMode: true,
      temperature: 0.2,
    );

    final j = jsonDecode(raw) as Map<String, dynamic>;
    return NutritionAiResult(
      kcalEstimate: j['kcal'] as int?,
      proteinLevel: j['protein_level'] as String?,
      processingLevel: j['processing_level'] as String?,
      satietyNote: j['satiety_note'] as String?,
      insights: (j['insights'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  } catch (e, st) {
    log.e(_tag, 'AI food analysis error: $e', error: e, stackTrace: st);
    return NutritionAiResult.empty;
  }
}

/// Сохраняет запись питания с результатом анализа.
Future<void> saveFoodEntry({
  required FoodLogDao dao,
  required String description,
  required MealType mealType,
  NutritionAiResult? analysis,
}) async {
  final entry = FoodLogsCompanion.insert(
    id: _uuid.v4(),
    loggedAt: DateTime.now(),
    description: description,
    kcalEstimate: Value(analysis?.kcalEstimate),
    proteinEstimate: Value(analysis?.proteinLevel),
    mealType: Value(mealType.value),
    aiResponse: analysis != null
        ? Value(jsonEncode({
            'protein_level': analysis.proteinLevel,
            'processing_level': analysis.processingLevel,
            'satiety_note': analysis.satietyNote,
            'insights': analysis.insights,
          }))
        : const Value(null),
  );
  await dao.insert(entry);
  log.i(_tag, 'Saved food entry: $description');
}
