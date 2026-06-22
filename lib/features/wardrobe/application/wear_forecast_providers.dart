import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gentleman_os/core/db/database_provider.dart';
import 'package:gentleman_os/features/wardrobe/application/wardrobe_providers.dart';
import 'package:gentleman_os/features/wardrobe/domain/wear_forecast.dart';

/// Дата последней носки вещи из WearLogs.
final lastWornAtProvider =
    FutureProvider.family.autoDispose<DateTime?, String>((ref, itemId) {
  return ref.watch(wardrobeDaoProvider).lastWornAt(itemId);
});

/// Полный прогноз носки для конкретной вещи (с lastWornAt из БД).
final wearForecastProvider =
    FutureProvider.family.autoDispose<WearForecast, String>((ref, itemId) async {
  final item = await ref.watch(wardrobeItemProvider(itemId).future);
  if (item == null) {
    return const WearForecast(urgency: WearUrgency.offSeason, headline: '—');
  }
  final lastWorn = await ref.watch(lastWornAtProvider(itemId).future);
  return computeWearForecast(
    item: item,
    now: DateTime.now(),
    lastWornAt: lastWorn,
  );
});
