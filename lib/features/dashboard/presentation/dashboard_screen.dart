import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gentleman_os/core/constants/spacing.dart';
import 'package:gentleman_os/core/db/app_database.dart';
import 'package:gentleman_os/core/db/database_provider.dart';
import 'package:gentleman_os/core/services/services_provider.dart';
import 'package:gentleman_os/core/theme/app_colors.dart';
import 'package:gentleman_os/core/widgets/mascot_avatar.dart';
import 'package:gentleman_os/core/widgets/score_ring.dart';
import 'package:gentleman_os/features/dashboard/application/dashboard_providers.dart';
import 'package:gentleman_os/features/dashboard/presentation/widgets/mission_tile.dart';
import 'package:gentleman_os/features/dashboard/presentation/widgets/quick_action_button.dart';
import 'package:gentleman_os/features/health/application/health_providers.dart';
import 'package:gentleman_os/shared/enums/xp_type.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final hour = DateTime.now().hour;

    final greeting = switch (hour) {
      < 6 => 'Доброй ночи',
      < 12 => 'Доброе утро',
      < 18 => 'Добрый день',
      _ => 'Добрый вечер',
    };

    final score = ref.watch(gentlemanScoreProvider).valueOrNull ?? 0.0;
    final mood = moodFromScore(score);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 0,
            floating: true,
            snap: true,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: MascotAvatar(size: 36, mood: mood),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'GENTLEMAN OS',
                  style: tt.labelSmall?.copyWith(
                    color: AppColors.gold,
                    letterSpacing: 2,
                    fontSize: 10,
                  ),
                ),
                Text(greeting, style: tt.titleMedium),
              ],
            ),
            actions: [
              IconButton(
                tooltip: 'Профиль',
                icon: const Icon(Icons.person_outline),
                onPressed: () => context.push('/profile'),
              ),
              IconButton(
                tooltip: 'Настройки',
                icon: const Icon(Icons.settings_outlined),
                onPressed: () => context.push('/settings'),
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(Spacing.screenPadding),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _GentlemanScoreCard(),
                const SizedBox(height: Spacing.md),
                _HealthIndexMini(),
                const SizedBox(height: Spacing.md),
                _ColorPaletteHint(),
                const SizedBox(height: Spacing.sectionGap),
                _DailyMissionsSection(),
                const SizedBox(height: Spacing.sectionGap),
                _QuickActionsSection(),
                const SizedBox(height: 80),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

/// Блок Gentleman Score из макета (732, круговой ring, золото)
class _GentlemanScoreCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final asyncScore = ref.watch(gentlemanScoreProvider);
    final asyncCount = ref.watch(wardrobeCountProvider);
    final score = asyncScore.valueOrNull ?? 0.0;
    final wardrobeCount = asyncCount.valueOrNull ?? 0;

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.3), width: 0.5),
      ),
      padding: const EdgeInsets.all(Spacing.cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ScoreRing(
                score: score,
                size: 110,
                strokeWidth: 8,
                label: 'SCORE',
                color: AppColors.gold,
              ),
              const SizedBox(width: Spacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gentleman\nScore',
                      style: tt.headlineSmall?.copyWith(
                        color: AppColors.textPrimary,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.checkroom_outlined,
                            color: cs.primary, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '$wardrobeCount вещей',
                          style: tt.bodySmall?.copyWith(color: cs.primary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                            color: AppColors.gold.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        score >= 70
                            ? 'Отличный прогресс'
                            : score >= 40
                                ? 'Хороший старт'
                                : 'Добавьте активности',
                        style: tt.labelSmall?.copyWith(
                          color: AppColors.gold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Подсказка цветовой палитры — из левой панели макета
class _ColorPaletteHint extends StatelessWidget {
  static const _colors = [
    (color: Color(0xFF1A1A1A), label: 'Фон'),
    (color: AppColors.gold, label: 'Акцент'),
    (color: Color(0xFF9E9E9E), label: 'Текст'),
    (color: Color(0xFF4A5568), label: 'Slate'),
  ];

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Row(
      children: [
        Text(
          'ПАЛИТРА',
          style: tt.labelSmall?.copyWith(
            color: AppColors.textSecondary,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(width: Spacing.md),
        ..._colors.map(
          (c) => Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: c.color,
                shape: BoxShape.circle,
                border: Border.all(color: cs.outline, width: 0.5),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Мини-плитка «Индекс здоровья» на дашборде.
class _HealthIndexMini extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncIndex = ref.watch(healthIndexProvider);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: () => context.push('/health'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.gold.withValues(alpha: 0.2), width: 0.5),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.favorite_outline,
                color: AppColors.success,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'МУЖСКОЕ ЗДОРОВЬЕ',
                    style: tt.labelSmall?.copyWith(
                      color: AppColors.textSecondary,
                      letterSpacing: 1.2,
                      fontSize: 9,
                    ),
                  ),
                  asyncIndex.when(
                    loading: () => Text('—', style: tt.titleMedium),
                    error: (_, __) => Text('—', style: tt.titleMedium),
                    data: (index) => Text(
                      index == 0
                          ? 'Внесите анализы'
                          : 'Индекс ${index.toStringAsFixed(0)}/100',
                      style: tt.titleSmall?.copyWith(
                        color: index == 0
                            ? cs.onSurfaceVariant
                            : index >= 70
                                ? AppColors.success
                                : index >= 40
                                    ? AppColors.warning
                                    : AppColors.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: cs.onSurfaceVariant, size: 18),
          ],
        ),
      ),
    );
  }
}

class _DailyMissionsSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tt = Theme.of(context).textTheme;
    final asyncMissions = ref.watch(dailyMissionsProvider);

    return asyncMissions.when(
      loading: () => const SizedBox(
        height: 120,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => const SizedBox.shrink(),
      data: (missions) {
        final completed = missions.where((m) => m.completed).length;
        final total = missions.length;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Задачи дня', style: tt.titleMedium),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$completed / $total',
                    style: tt.labelSmall?.copyWith(color: AppColors.gold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: Spacing.sm),
            ...missions.map(
              (m) => MissionTile(
                title: m.title,
                xpReward: m.xpReward,
                completed: m.completed,
                xpTypeIndex: m.xpType,
                onTap: () => _completeMission(ref, m),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _completeMission(WidgetRef ref, DailyMissionsData m) async {
    await ref.read(dailyMissionsDaoProvider).complete(m.id);
    final xpType = XpType.values[m.xpType.clamp(0, XpType.values.length - 1)];
    await ref
        .read(xpServiceProvider)
        .award(xpType, m.xpReward, 'Миссия: ${m.title}');
  }
}

class _QuickActionsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Быстрый доступ', style: tt.titleMedium),
        const SizedBox(height: Spacing.sm),
        GridView.count(
          crossAxisCount: 3,
          crossAxisSpacing: Spacing.sm,
          mainAxisSpacing: Spacing.sm,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.1,
          children: const [
            QuickActionButton(
              icon: Icons.checkroom,
              label: 'Гардероб',
              route: '/wardrobe',
            ),
            QuickActionButton(
              icon: Icons.style,
              label: 'Образы',
              route: '/outfits',
            ),
            QuickActionButton(
              icon: Icons.auto_awesome,
              label: 'Подобрать',
              route: '/outfits/build',
            ),
            QuickActionButton(
              icon: Icons.person_outline,
              label: 'Профиль',
              route: '/profile',
            ),
            QuickActionButton(
              icon: Icons.trending_up,
              label: 'Прогресс',
              route: '/progress',
            ),
            QuickActionButton(
              icon: Icons.shopping_bag_outlined,
              label: 'Покупки',
              route: '/purchases',
            ),
            QuickActionButton(
              icon: Icons.lightbulb_outline,
              label: 'Советник',
              route: '/style-advisor',
            ),
            QuickActionButton(
              icon: Icons.favorite_outline,
              label: 'Здоровье',
              route: '/health',
            ),
            QuickActionButton(
              icon: Icons.repeat,
              label: 'Привычки',
              route: '/progress/habits',
            ),
          ],
        ),
      ],
    );
  }
}
