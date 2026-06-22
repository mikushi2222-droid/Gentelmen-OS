import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:gentleman_os/features/wardrobe/presentation/clothing_card.dart';
import 'package:gentleman_os/shared/enums/clothing_category.dart';
import 'package:gentleman_os/shared/enums/condition.dart';
import 'package:gentleman_os/shared/enums/season.dart';
import 'package:gentleman_os/shared/models/clothing_item.dart';

// Wrap ClothingCard in a router because it calls context.push().
Widget _wrap(ClothingItem item) {
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (_, __) => Scaffold(body: SizedBox(
          width: 200,
          height: 300,
          child: ClothingCard(item: item),
        )),
      ),
      GoRoute(
        path: '/wardrobe/:id',
        builder: (_, __) => const Scaffold(),
      ),
    ],
  );

  return MaterialApp.router(
    routerConfig: router,
    theme: ThemeData.dark(),
  );
}

ClothingItem _item({
  Season season = Season.all,
  Condition condition = Condition.good,
  int wearCount = 0,
  DateTime? createdAt,
  String name = 'Test Shirt',
  String? brand,
}) =>
    ClothingItem(
      id: 'test-id',
      name: name,
      category: ClothingCategory.shirt,
      season: season,
      condition: condition,
      wearCount: wearCount,
      createdAt: createdAt ?? DateTime.now().subtract(const Duration(days: 60)),
    );

void main() {
  group('ClothingCard — wear forecast strip', () {
    testWidgets('отображает имя вещи', (tester) async {
      await tester.pumpWidget(_wrap(_item(name: 'Белая рубашка')));
      await tester.pumpAndSettle();
      expect(find.text('Белая рубашка'), findsOneWidget);
    });

    testWidgets('зимняя вещь летом → Не сезон', (tester) async {
      await tester.pumpWidget(_wrap(_item(season: Season.winter)));
      await tester.pumpAndSettle();
      expect(find.text('Не сезон'), findsOneWidget);
    });

    testWidgets('списанная вещь → Списана', (tester) async {
      await tester.pumpWidget(_wrap(_item(condition: Condition.retired)));
      await tester.pumpAndSettle();
      expect(find.text('Списана'), findsOneWidget);
    });

    testWidgets('не носили 60 дней → Надень сегодня!', (tester) async {
      final oldItem = _item(
        season: Season.all,
        wearCount: 0,
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
      );
      await tester.pumpWidget(_wrap(oldItem));
      await tester.pumpAndSettle();
      expect(find.text('Надень сегодня!'), findsOneWidget);
    });

    testWidgets('всесезонная вещь → не показывает Не сезон', (tester) async {
      await tester.pumpWidget(_wrap(_item(season: Season.all)));
      await tester.pumpAndSettle();
      expect(find.text('Не сезон'), findsNothing);
    });
  });

  group('ClothingCard — визуальные элементы', () {
    testWidgets('значок бренда виден при наличии', (tester) async {
      final item = ClothingItem(
        id: 'b1',
        name: 'Пиджак',
        category: ClothingCategory.jacket,
        brand: 'Hugo Boss',
        season: Season.all,
        wearCount: 3,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      );
      await tester.pumpWidget(_wrap(item));
      await tester.pumpAndSettle();
      expect(find.text('Hugo Boss'), findsOneWidget);
    });

    testWidgets('счётчик носок виден при wearCount > 0', (tester) async {
      final item = _item(wearCount: 7);
      await tester.pumpWidget(_wrap(item));
      await tester.pumpAndSettle();
      expect(find.text('×7'), findsOneWidget);
    });

    testWidgets('счётчик носок скрыт при wearCount == 0', (tester) async {
      final item = _item(wearCount: 0);
      await tester.pumpWidget(_wrap(item));
      await tester.pumpAndSettle();
      expect(find.textContaining('×'), findsNothing);
    });
  });
}
