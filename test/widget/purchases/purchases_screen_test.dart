import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:gentleman_os/core/db/app_database.dart';
import 'package:gentleman_os/features/purchases/application/purchases_providers.dart';
import 'package:gentleman_os/features/purchases/presentation/purchases_screen.dart';

final _now = DateTime(2026, 1, 1);

PurchaseWishesData _wish({
  String id = 'w1',
  String name = 'Hugo Boss Shirt',
  int category = 0,
  int status = 0, // WishStatus.wish
  double? budget,
}) =>
    PurchaseWishesData(
      id: id,
      itemName: name,
      category: category,
      priority: 3,
      budget: budget,
      reason: null,
      status: status,
      createdAt: _now,
    );

Widget _buildApp(List<Override> overrides) {
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (_, __) => const PurchasesScreen(),
      ),
      GoRoute(path: '/wardrobe/add', builder: (_, __) => const Scaffold()),
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

void main() {
  group('PurchasesScreen — вкладки', () {
    testWidgets('пустой список → "Список желаний пуст"', (tester) async {
      await tester.pumpWidget(_buildApp([
        purchasesListProvider
            .overrideWith((_) => Stream.value(<PurchaseWishesData>[])),
      ]));
      await tester.pumpAndSettle();
      expect(find.text('Список желаний пуст'), findsOneWidget);
    });

    testWidgets('отображаются все 5 вкладок', (tester) async {
      await tester.pumpWidget(_buildApp([
        purchasesListProvider
            .overrideWith((_) => Stream.value([_wish()])),
      ]));
      await tester.pumpAndSettle();

      expect(find.text('Все'), findsOneWidget);
      expect(find.text('Хочу'), findsOneWidget);
      expect(find.text('Планирую'), findsOneWidget);
      expect(find.text('Куплено'), findsOneWidget);
      expect(find.text('Отклонено'), findsOneWidget);
    });

    testWidgets('вещь видна на вкладке Все', (tester) async {
      await tester.pumpWidget(_buildApp([
        purchasesListProvider
            .overrideWith((_) => Stream.value([_wish(name: 'Hugo Boss Shirt')])),
      ]));
      await tester.pumpAndSettle();
      expect(find.text('Hugo Boss Shirt'), findsOneWidget);
    });

    testWidgets('вкладка Хочу показывает нужные вещи', (tester) async {
      final items = [
        _wish(id: 'a', name: 'Рубашка Wish', status: 0),    // wish
        _wish(id: 'b', name: 'Рубашка Planned', status: 1), // planned
      ];
      await tester.pumpWidget(_buildApp([
        purchasesListProvider.overrideWith((_) => Stream.value(items)),
      ]));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Хочу'));
      await tester.pumpAndSettle();

      expect(find.text('Рубашка Wish'), findsOneWidget);
      expect(find.text('Рубашка Planned'), findsNothing);
    });

    testWidgets('вкладка Планирую — пусто если нет запланированных',
        (tester) async {
      await tester.pumpWidget(_buildApp([
        purchasesListProvider
            .overrideWith((_) => Stream.value([_wish(status: 0)])),
      ]));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Планирую'));
      await tester.pumpAndSettle();

      expect(find.text('Список пуст'), findsOneWidget);
    });

    testWidgets('бюджет отображается при наличии', (tester) async {
      await tester.pumpWidget(_buildApp([
        purchasesListProvider
            .overrideWith((_) => Stream.value([_wish(budget: 5000)])),
      ]));
      await tester.pumpAndSettle();
      expect(find.textContaining('5'), findsWidgets);
    });
  });
}
