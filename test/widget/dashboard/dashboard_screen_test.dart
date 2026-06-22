import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:gentleman_os/core/db/app_database.dart';
import 'package:gentleman_os/features/dashboard/application/dashboard_providers.dart';
import 'package:gentleman_os/features/dashboard/presentation/dashboard_screen.dart';
import 'package:gentleman_os/features/habits/application/habits_providers.dart';
import 'package:gentleman_os/features/health/application/health_providers.dart';
import 'package:gentleman_os/features/wardrobe/application/wardrobe_providers.dart';
import 'package:gentleman_os/shared/models/clothing_item.dart';

Widget _buildApp(List<Override> overrides) {
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (_, __) => const DashboardScreen(),
      ),
      GoRoute(path: '/profile', builder: (_, __) => const Scaffold()),
      GoRoute(path: '/settings', builder: (_, __) => const Scaffold()),
      GoRoute(path: '/health', builder: (_, __) => const Scaffold()),
      GoRoute(path: '/wardrobe/:id', builder: (_, __) => const Scaffold()),
      GoRoute(path: '/progress/habits', builder: (_, __) => const Scaffold()),
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

List<Override> get _emptyOverrides => [
      gentlemanScoreProvider.overrideWith((_) => Future.value(75.0)),
      wardrobeListProvider
          .overrideWith((_) => Stream.value(<ClothingItem>[])),
      healthIndexProvider.overrideWith((_) => Future.value(0.0)),
      activeHabitsWithCompletionProvider
          .overrideWith((_) => Future.value(<HabitWithCompletion>[])),
      dailyMissionsProvider
          .overrideWith((_) => Stream.value(<DailyMissionsData>[])),
    ];

void main() {
  group('DashboardScreen — smoke test', () {
    testWidgets('рендерится без ошибок', (tester) async {
      await tester.pumpWidget(_buildApp(_emptyOverrides));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('отображает заголовок GENTLEMAN OS', (tester) async {
      await tester.pumpWidget(_buildApp(_emptyOverrides));
      await tester.pumpAndSettle();
      expect(find.text('GENTLEMAN OS'), findsOneWidget);
    });

    testWidgets('отображает блок Gentleman Score', (tester) async {
      await tester.pumpWidget(_buildApp(_emptyOverrides));
      await tester.pumpAndSettle();
      expect(find.text('Gentleman\nScore'), findsOneWidget);
    });

    testWidgets('отображает секцию задач дня', (tester) async {
      await tester.pumpWidget(_buildApp(_emptyOverrides));
      await tester.pumpAndSettle();
      expect(find.text('Задачи дня'), findsOneWidget);
    });

    testWidgets('отображает быстрый доступ', (tester) async {
      await tester.pumpWidget(_buildApp(_emptyOverrides));
      await tester.pumpAndSettle();
      expect(find.text('Быстрый доступ'), findsOneWidget);
    });

    testWidgets('отображает счёт 75 в кольце', (tester) async {
      await tester.pumpWidget(_buildApp(_emptyOverrides));
      await tester.pumpAndSettle();
      expect(find.text('75'), findsWidgets);
    });

    testWidgets('пустой гардероб — нет виджета срочных вещей', (tester) async {
      await tester.pumpWidget(_buildApp(_emptyOverrides));
      await tester.pumpAndSettle();
      expect(find.text('Надеть сегодня'), findsNothing);
    });

    testWidgets('пустые привычки — блок привычек не показан', (tester) async {
      await tester.pumpWidget(_buildApp(_emptyOverrides));
      await tester.pumpAndSettle();
      expect(find.text('Привычки сегодня'), findsNothing);
    });
  });
}
