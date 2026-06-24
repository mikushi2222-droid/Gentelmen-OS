import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gentleman_os/core/router/shell_scaffold.dart';
import 'package:gentleman_os/core/utils/app_logger.dart';
import 'package:gentleman_os/features/biohacking/presentation/biohacking_screen.dart';
import 'package:gentleman_os/features/body/presentation/body_hub_screen.dart';
import 'package:gentleman_os/features/dashboard/presentation/dashboard_screen.dart';
import 'package:gentleman_os/features/fitness/presentation/fitness_screen.dart';
import 'package:gentleman_os/features/fitness/presentation/add_measurement_screen.dart';
import 'package:gentleman_os/features/habits/presentation/habits_screen.dart';
import 'package:gentleman_os/features/health/presentation/health_screen.dart';
import 'package:gentleman_os/features/health/presentation/health_marker_detail_screen.dart';
import 'package:gentleman_os/features/knowledge/presentation/knowledge_screen.dart';
import 'package:gentleman_os/features/knowledge/presentation/article_screen.dart';
import 'package:gentleman_os/features/mind/presentation/mind_hub_screen.dart';
import 'package:gentleman_os/features/outfit_builder/presentation/outfits_screen.dart';
import 'package:gentleman_os/features/outfit_builder/presentation/outfit_builder_screen.dart';
import 'package:gentleman_os/features/outfit_builder/presentation/outfit_detail_screen.dart';
import 'package:gentleman_os/features/outfit_builder/presentation/outfit_rating_screen.dart';
import 'package:gentleman_os/features/profile/presentation/profile_screen.dart';
import 'package:gentleman_os/features/profile/presentation/edit_profile_screen.dart';
import 'package:gentleman_os/features/purchases/presentation/purchases_screen.dart';
import 'package:gentleman_os/features/rpg/presentation/rpg_screen.dart';
import 'package:gentleman_os/features/settings/presentation/settings_screen.dart';
import 'package:gentleman_os/features/settings/presentation/log_screen.dart';
import 'package:gentleman_os/features/style/presentation/style_hub_screen.dart';
import 'package:gentleman_os/features/style_advisor/presentation/style_advisor_screen.dart';
import 'package:gentleman_os/features/wardrobe/presentation/wardrobe_screen.dart';
import 'package:gentleman_os/features/wardrobe/presentation/item_detail_screen.dart';
import 'package:gentleman_os/features/wardrobe/presentation/add_item_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: '/dashboard',
    debugLogDiagnostics: false,
    routes: [
      ShellRoute(
        builder: (context, state, child) => ShellScaffold(child: child),
        routes: [
          // ── Штаб ──────────────────────────────────────────────────────
          GoRoute(
            path: '/dashboard',
            pageBuilder: (c, s) =>
                const NoTransitionPage(child: DashboardScreen()),
          ),

          // ── Стиль ─────────────────────────────────────────────────────
          GoRoute(
            path: '/style',
            pageBuilder: (c, s) =>
                const NoTransitionPage(child: StyleHubScreen()),
          ),
          GoRoute(
            path: '/wardrobe',
            pageBuilder: (c, s) =>
                const NoTransitionPage(child: WardrobeScreen()),
            routes: [
              GoRoute(
                path: 'add',
                builder: (c, s) {
                  final extra = s.extra as Map<String, dynamic>?;
                  return AddItemScreen(
                    initialName: extra?['name'] as String?,
                    initialCategory: extra?['category'] as int?,
                  );
                },
              ),
              GoRoute(
                path: ':itemId',
                builder: (c, s) =>
                    ItemDetailScreen(itemId: s.pathParameters['itemId']!),
                routes: [
                  GoRoute(
                    path: 'edit',
                    builder: (c, s) =>
                        AddItemScreen(itemId: s.pathParameters['itemId']),
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: '/outfits',
            pageBuilder: (c, s) =>
                const NoTransitionPage(child: OutfitsScreen()),
            routes: [
              GoRoute(
                path: 'build',
                builder: (c, s) => const OutfitBuilderScreen(),
              ),
              GoRoute(
                path: ':outfitId',
                builder: (c, s) =>
                    OutfitDetailScreen(outfitId: s.pathParameters['outfitId']!),
                routes: [
                  GoRoute(
                    path: 'rate',
                    builder: (c, s) => OutfitRatingScreen(
                        outfitId: s.pathParameters['outfitId']!),
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: '/style-advisor',
            pageBuilder: (c, s) =>
                const NoTransitionPage(child: StyleAdvisorScreen()),
          ),
          GoRoute(
            path: '/purchases',
            pageBuilder: (c, s) =>
                const NoTransitionPage(child: PurchasesScreen()),
          ),

          // ── Тело ──────────────────────────────────────────────────────
          GoRoute(
            path: '/body',
            pageBuilder: (c, s) =>
                const NoTransitionPage(child: BodyHubScreen()),
          ),
          GoRoute(
            path: '/health',
            pageBuilder: (c, s) =>
                const NoTransitionPage(child: HealthScreen()),
            routes: [
              GoRoute(
                path: 'marker/:typeIndex',
                builder: (c, s) => HealthMarkerDetailScreen(
                  typeIndex:
                      int.tryParse(s.pathParameters['typeIndex'] ?? '') ?? -1,
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/progress',
            pageBuilder: (c, s) =>
                const NoTransitionPage(child: FitnessScreen()),
            routes: [
              GoRoute(
                path: 'add-measurement',
                builder: (c, s) => const AddMeasurementScreen(),
              ),
              GoRoute(
                path: 'rpg',
                builder: (c, s) => const RpgScreen(),
              ),
              GoRoute(
                path: 'habits',
                builder: (c, s) => const HabitsScreen(),
              ),
            ],
          ),

          // ── Разум ─────────────────────────────────────────────────────
          GoRoute(
            path: '/mind',
            pageBuilder: (c, s) =>
                const NoTransitionPage(child: MindHubScreen()),
          ),
          GoRoute(
            path: '/biohacking',
            pageBuilder: (c, s) =>
                const NoTransitionPage(child: BiohackingScreen()),
          ),
          GoRoute(
            path: '/knowledge',
            pageBuilder: (c, s) =>
                const NoTransitionPage(child: KnowledgeScreen()),
            routes: [
              GoRoute(
                path: ':articleId',
                builder: (c, s) =>
                    ArticleScreen(articleId: s.pathParameters['articleId']!),
              ),
            ],
          ),
          GoRoute(
            path: '/habits',
            pageBuilder: (c, s) =>
                const NoTransitionPage(child: HabitsScreen()),
          ),

          // ── Система ───────────────────────────────────────────────────
          GoRoute(
            path: '/profile',
            pageBuilder: (c, s) =>
                const NoTransitionPage(child: ProfileScreen()),
            routes: [
              GoRoute(
                path: 'edit',
                builder: (c, s) => const EditProfileScreen(),
              ),
            ],
          ),
        ],
      ),

      // Вне shell — только настройки (полноэкранный режим)
      GoRoute(
        path: '/settings',
        builder: (c, s) => const SettingsScreen(),
        routes: [
          GoRoute(
            path: 'logs',
            builder: (c, s) => const LogScreen(),
          ),
        ],
      ),
    ],
  );

  // Централизованно логируем каждое перемещение по приложению, чтобы в
  // журнале отладки была видна цепочка действий пользователя.
  String? lastLocation;
  void onRouteChange() {
    final loc = router.routeInformationProvider.value.uri.toString();
    if (loc == lastLocation) return;
    lastLocation = loc;
    log.d('Nav', 'Переход: $loc');
  }

  router.routeInformationProvider.addListener(onRouteChange);
  ref.onDispose(
    () => router.routeInformationProvider.removeListener(onRouteChange),
  );
  onRouteChange(); // зафиксировать стартовый экран

  return router;
});
