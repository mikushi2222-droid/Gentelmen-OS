import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:gentleman_os/core/db/app_database.dart';
import 'package:gentleman_os/features/outfit_builder/presentation/outfit_detail_screen.dart';
import 'package:gentleman_os/shared/models/clothing_item.dart';
import 'package:gentleman_os/shared/enums/clothing_category.dart';

final _now = DateTime(2026, 1, 1);

OutfitsData _outfit({
  String id = 'o1',
  String name = 'Деловой образ',
  double score = 82.0,
  String? scoreBreakdown,
}) =>
    OutfitsData(
      id: id,
      name: name,
      occasion: 1, // Occasion.work
      weather: null,
      temperatureC: null,
      dressCode: 0,
      season: 0,
      score: score,
      scoreBreakdown: scoreBreakdown ??
          jsonEncode({
            'fitScore': 0.85,
            'colorScore': 0.70,
            'occasionScore': 0.90,
            'weatherScore': 0.80,
            'comfortScore': 0.75,
            'explanation': ['Хорошая посадка', 'Подходит для работы'],
          }),
      notes: null,
      createdAt: _now,
    );

ClothingItem _clothingItem() => ClothingItem(
      id: 'c1',
      name: 'Белая рубашка',
      category: ClothingCategory.shirt,
      createdAt: _now,
    );

Widget _buildApp({
  required String outfitId,
  required (OutfitsData?, List<ClothingItem>) data,
}) {
  final router = GoRouter(
    initialLocation: '/outfit/$outfitId',
    routes: [
      GoRoute(
        path: '/outfit/:id',
        builder: (_, state) =>
            OutfitDetailScreen(outfitId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/outfits/:id/rate',
        builder: (_, __) => const Scaffold(),
      ),
      GoRoute(
        path: '/wardrobe/:id',
        builder: (_, __) => const Scaffold(),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      outfitDetailProvider(outfitId).overrideWith((_) => Future.value(data)),
    ],
    child: MaterialApp.router(
      routerConfig: router,
      theme: ThemeData.dark(),
    ),
  );
}

void main() {
  group('OutfitDetailScreen — разбивка оценки', () {
    testWidgets('рендерится без ошибок', (tester) async {
      await tester.pumpWidget(_buildApp(
        outfitId: 'o1',
        data: (_outfit(), [_clothingItem()]),
      ));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('показывает название образа', (tester) async {
      await tester.pumpWidget(_buildApp(
        outfitId: 'o1',
        data: (_outfit(name: 'Деловой образ'), []),
      ));
      await tester.pumpAndSettle();
      expect(find.text('Деловой образ'), findsOneWidget);
    });

    testWidgets('показывает строки разбивки оценки', (tester) async {
      await tester.pumpWidget(_buildApp(
        outfitId: 'o1',
        data: (_outfit(), []),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Посадка (×0.30)'), findsOneWidget);
      expect(find.text('Повод (×0.25)'), findsOneWidget);
      expect(find.text('Погода/сезон (×0.20)'), findsOneWidget);
      expect(find.text('Цветовая гармония (×0.15)'), findsOneWidget);
      expect(find.text('Комфорт (×0.10)'), findsOneWidget);
    });

    testWidgets('показывает пояснения к оценке', (tester) async {
      await tester.pumpWidget(_buildApp(
        outfitId: 'o1',
        data: (_outfit(), []),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Хорошая посадка'), findsOneWidget);
      expect(find.text('Подходит для работы'), findsOneWidget);
    });

    testWidgets('нет разбивки → не показывает строки', (tester) async {
      await tester.pumpWidget(_buildApp(
        outfitId: 'o1',
        data: (_outfit(scoreBreakdown: '{}'), []),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Посадка (×0.30)'), findsNothing);
    });

    testWidgets('образ не найден → текст-заглушка', (tester) async {
      await tester.pumpWidget(_buildApp(
        outfitId: 'missing',
        data: (null, []),
      ));
      await tester.pumpAndSettle();
      expect(find.text('Образ не найден'), findsOneWidget);
    });

    testWidgets('отображает вещи образа', (tester) async {
      await tester.pumpWidget(_buildApp(
        outfitId: 'o1',
        data: (_outfit(), [_clothingItem()]),
      ));
      await tester.pumpAndSettle();
      expect(find.text('Белая рубашка'), findsOneWidget);
    });
  });
}
