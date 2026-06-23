/// Ядро раздела «Биохакинг» — система принятия решений, а не склад БАДов.
/// Отвечает на главный вопрос: что ограничивает прогресс и что даст максимум
/// эффекта. Чистые функции без Flutter и БД — легко тестируются.
/// См. docs/16-vision-three-levels-and-biohacking.md.
library;

import 'dart:math' as math;

/// Домен оптимизации (сон, стресс, вес, ...) с текущей оценкой и важностью.
class OptimizationDomain {
  const OptimizationDomain({
    required this.name,
    required this.score,
    this.weight = 1.0,
  });

  /// Человекочитаемое имя домена («Сон», «Стресс», «Вес»).
  final String name;

  /// Текущая оптимизация домена, 0..1.
  final double score;

  /// Важность домена для общего результата, 0..1 (по умолчанию равная).
  final double weight;

  /// Потенциал прироста: сколько «недобрано» с учётом важности.
  /// Чем больше — тем сильнее домен тормозит общий прогресс.
  double get gap => (1 - score.clamp(0.0, 1.0)) * weight;
}

/// Рекомендованное действие с объяснимым ожидаемым эффектом.
class ImpactAction {
  const ImpactAction({
    required this.title,
    required this.impactPercent,
    required this.reason,
  });

  /// Что сделать («Улучшить сон», «Снизить талию»).
  final String title;

  /// Ожидаемый прирост общей оптимизации, целые проценты (+N%).
  final int impactPercent;

  /// Объяснение, почему это действие приоритетно (принцип объяснимости).
  final String reason;
}

/// Общая оптимизация в процентах (0..100) — взвешенное среднее доменов.
int optimizationScore(List<OptimizationDomain> domains) {
  if (domains.isEmpty) return 0;
  final totalWeight = domains.fold<double>(0, (s, d) => s + d.weight);
  if (totalWeight <= 0) return 0;
  final weighted = domains.fold<double>(
    0,
    (s, d) => s + d.score.clamp(0.0, 1.0) * d.weight,
  );
  return (weighted / totalWeight * 100).round().clamp(0, 100);
}

/// Узкие места — домены, отсортированные по убыванию потенциала прироста
/// (худшее/самое влияющее — первым).
List<OptimizationDomain> bottlenecks(List<OptimizationDomain> domains) {
  final sorted = [...domains]..sort((a, b) => b.gap.compareTo(a.gap));
  return sorted;
}

/// Что даст максимальный результат — топ-N действий по узким местам.
/// Эффект оценивается как доля закрываемого разрыва от общей суммы весов.
List<ImpactAction> maxImpactActions(
  List<OptimizationDomain> domains, {
  int top = 3,
}) {
  if (domains.isEmpty) return const [];
  final totalWeight = domains.fold<double>(0, (s, d) => s + d.weight);
  if (totalWeight <= 0) return const [];

  final ranked = bottlenecks(domains).where((d) => d.gap > 0).toList();
  final take = math.min(top, ranked.length);
  return [
    for (var i = 0; i < take; i++)
      ImpactAction(
        title: 'Улучшить: ${ranked[i].name}',
        impactPercent: (ranked[i].gap / totalWeight * 100).round(),
        reason: 'Сейчас «${ranked[i].name}» оптимизировано на '
            '${(ranked[i].score.clamp(0.0, 1.0) * 100).round()}% — '
            '${i == 0 ? 'это главное узкое место.' : 'следующее по влиянию узкое место (#${i + 1}).'}',
      ),
  ];
}
