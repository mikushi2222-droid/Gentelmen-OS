import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gentleman_os/core/router/shell_scaffold.dart';
import 'package:gentleman_os/features/biohacking/presentation/biohacking_screen.dart';
import 'package:gentleman_os/features/dashboard/presentation/dashboard_screen.dart';
import 'package:gentleman_os/features/fitness/presentation/fitness_screen.dart';
import 'package:gentleman_os/features/fitness/presentation/add_measurement_screen.dart';
import 'package:gentleman_os/features/knowledge/presentation/knowledge_screen.dart';
import 'package:gentleman_os/features/knowledge/presentation/article_screen.dart';
import 'package:gentleman_os/features/outfit_builder/presentation/outfits_screen.dart';
import 'package:gentleman_os/features/outfit_builder/presentation/outfit_builder_screen.dart';
import 'package:gentleman_os/features/outfit_builder/presentation/outfit_detail_screen.dart';
import 'package:gentleman_os/features/profile/presentation/profile_screen.dart';
import 'package:gentleman_os/features/profile/presentation/edit_profile_screen.dart';
import 'package:gentleman_os/features/purchases/presentation/purchases_screen.dart';
import 'package:gentleman_os/features/habits/presentation/habits_screen.dart';
import 'package:gentleman_os/features/health/presentation/health_screen.dart';
import 'package:gentleman_os/features/health/presentation/health_marker_detail_screen.dart';
import 'package:gentleman_os/features/rpg/presentation/rpg_screen.dart';
import 'package:gentleman_os/features/settings/presentation/settings_screen.dart';
import 'package:gentleman_os/features/settings/presentation/log_screen.dart';
import 'package:gentleman_os/features/style_advisor/presentation/style_advisor_screen.dart';
import 'package:gentleman_os/features/wardrobe/presentation/wardrobe_screen.dart';
import 'package:gentleman_os/features/wardrobe/presentation/item_detail_screen.dart';
import 'package:gentleman_os/features/wardrobe/presentation/add_item_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/dashboard',
    debugLogDiagnostics: false,
    routes: [
      ShellRoute(
        builder: (context, state, child) => ShellScaffold(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            pageBuilder: (c, s) =>
                const NoTransitionPage(child: DashboardScreen()),
          ),
          GoRoute(
            path: '/wardrobe',
            pageBuilder: (c, s) =>
                const NoTransitionPage(child: WardrobeScreen()),
            routes: [
              GoRoute(
                path: 'add',
                builder: (c, s) => const AddItemScreen(),
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
              ),
            ],
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
            path: '/biohacking',
            pageBuilder: (c, s) =>
                const NoTransitionPage(child: BiohackingScreen()),
          ),
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
      // Вне shell
      GoRoute(
        path: '/purchases',
        builder: (c, s) => const PurchasesScreen(),
      ),
      GoRoute(
        path: '/style-advisor',
        builder: (c, s) => const StyleAdvisorScreen(),
      ),
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
});
