import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:gentleman_os/core/ai/ai_advisor_provider.dart';
import 'package:gentleman_os/core/ai/style_advice.dart';
import 'package:gentleman_os/features/wardrobe/application/wardrobe_providers.dart';
import 'package:gentleman_os/features/wardrobe/presentation/wardrobe_screen.dart';
import 'package:gentleman_os/shared/enums/clothing_category.dart';
import 'package:gentleman_os/shared/models/clothing_item.dart';

final _testItems = [
  ClothingItem(
    id: '1',
    name: 'Белая рубашка',
    category: ClothingCategory.shirt,
    createdAt: DateTime(2026, 1, 1),
  ),
  ClothingItem(
    id: '2',
    name: 'Синяя рубашка',
    category: ClothingCategory.shirt,
    createdAt: DateTime(2026, 1, 2),
  ),
  ClothingItem(
    id: '3',
    name: 'Чёрные брюки',
    category: ClothingCategory.trousers,
    createdAt: DateTime(2026, 1, 3),
  ),
];

const _emptyAdvice = StyleAdvice(
  summary: '',
  suggestions: [],
  warnings: [],
);

Widget _buildApp({List<Override> overrides = const []}) {
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (_, __) => const WardrobeScreen(),
      ),
      GoRoute(path: '/wardrobe/add', builder: (_, __) => const Scaffold()),
      GoRoute(path: '/wardrobe/:id', builder: (_, __) => const Scaffold()),
    ],
  );

  return ProviderScope(
    overrides: overrides,
    child: MaterialApp.router(
      routerConfig: router,
      theme: ThemeData.dark(),
    ),
  );
}

List<Override> _overrides(List<ClothingItem> items) => [
      wardrobeListProvider.overrideWith((_) => Stream.value(items)),
      styleAdviceProvider.overrideWith((_) => Future.value(_emptyAdvice)),
    ];

void main() {
  group('WardrobeScreen — поиск и фильтрация', () {
    testWidgets('рендерится без ошибок', (tester) async {
      await tester.pumpWidget(_buildApp(overrides: _overrides(_testItems)));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('все три вещи видны без фильтра', (tester) async {
      await tester.pumpWidget(_buildApp(overrides: _overrides(_testItems)));
      await tester.pumpAndSettle();
      expect(find.text('Белая рубашка'), findsOneWidget);
      expect(find.text('Синяя рубашка'), findsOneWidget);
      expect(find.text('Чёрные брюки'), findsOneWidget);
    });

    testWidgets('поиск "рубашка" скрывает брюки', (tester) async {
      await tester.pumpWidget(_buildApp(overrides: _overrides(_testItems)));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.search));
      await tester.pump();

      await tester.enterText(find.byType(TextField), 'рубашка');
      await tester.pump();

      expect(find.text('Белая рубашка'), findsOneWidget);
      expect(find.text('Синяя рубашка'), findsOneWidget);
      expect(find.text('Чёрные брюки'), findsNothing);
    });

    testWidgets('поиск без совпадений → "Ничего не найдено"', (tester) async {
      await tester.pumpWidget(_buildApp(overrides: _overrides(_testItems)));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.search));
      await tester.pump();

      await tester.enterText(find.byType(TextField), 'пальто');
      await tester.pump();

      expect(find.text('Ничего не найдено'), findsOneWidget);
    });

    testWidgets('закрытие поиска восстанавливает все вещи', (tester) async {
      await tester.pumpWidget(_buildApp(overrides: _overrides(_testItems)));
      await tester.pumpAndSettle();

      // Открываем поиск
      await tester.tap(find.byIcon(Icons.search));
      await tester.pump();
      await tester.enterText(find.byType(TextField), 'рубашка');
      await tester.pump();

      // Закрываем поиск
      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();

      expect(find.text('Белая рубашка'), findsOneWidget);
      expect(find.text('Синяя рубашка'), findsOneWidget);
      expect(find.text('Чёрные брюки'), findsOneWidget);
    });

    testWidgets('пустой гардероб → "Гардероб пуст"', (tester) async {
      await tester.pumpWidget(_buildApp(overrides: _overrides([])));
      await tester.pumpAndSettle();
      expect(find.text('Гардероб пуст'), findsOneWidget);
    });

    testWidgets('поиск регистронезависим', (tester) async {
      await tester.pumpWidget(_buildApp(overrides: _overrides(_testItems)));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.search));
      await tester.pump();

      await tester.enterText(find.byType(TextField), 'БРЮКИ');
      await tester.pump();

      expect(find.text('Чёрные брюки'), findsOneWidget);
      expect(find.text('Белая рубашка'), findsNothing);
    });
  });
}
