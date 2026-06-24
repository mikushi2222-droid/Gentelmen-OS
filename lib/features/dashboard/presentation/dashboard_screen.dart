import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gentleman_os/core/constants/spacing.dart';
import 'package:gentleman_os/core/db/app_database.dart';
import 'package:gentleman_os/core/db/database_provider.dart';
import 'package:gentleman_os/core/services/services_provider.dart';
import 'package:gentleman_os/core/services/xp_service.dart';
import 'package:gentleman_os/core/theme/app_colors.dart';
import 'package:gentleman_os/core/widgets/mascot_avatar.dart';
import 'package:gentleman_os/core/widgets/score_ring.dart';
import 'package:gentleman_os/features/dashboard/application/dashboard_providers.dart';
import 'package:gentleman_os/features/dashboard/domain/sub_scores.dart';
import 'package:gentleman_os/features/dashboard/presentation/widgets/mission_tile.dart';
import 'package:gentleman_os/features/dashboard/presentation/widgets/quick_action_button.dart';
import 'package:gentleman_os/features/weight_loss/presentation/weight_compliance_card.dart';
import 'package:gentleman_os/shared/enums/xp_type.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tt = Theme.of(context).textTheme;
    final hour = DateTime.now().hour;

    final greeting = switch (hour) {
      < 6 => 'Доброй ночи',
      < 12 => 'Доброе утро',
      < 18 => 'Добрый день',
      _ => 'Добрый вечер',
    };

    final score = ref.watch(gentlemanScoreProvider).value ?? 0.0;
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
                const WeightComplianceCard(),
                const SizedBox(height: Spacing.md),
                _SubScoresBlock(),
                const SizedBox(height: Spacing.md),
                _ColorPaletteHint(),
                const SizedBox(height: Spacing.sectionGap),
                _DailyMissionsSection(),
                const SizedBox(height: Spacing.md),
                _DailyTipCard(),
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
    final score = asyncScore.value ?? 0.0;
    final wardrobeCount = asyncCount.value ?? 0;

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
            QuickActionButton(
              icon: Icons.restaurant_outlined,
              label: 'Питание',
              route: '/food-log',
            ),
          ],
        ),
      ],
    );
  }
}

/// Блок 2 — четыре под-оценки (Стиль/Здоровье/Биохакинг/Дисциплина).
class _SubScoresBlock extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(subScoresProvider);
    return async.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: LinearProgressIndicator(),
      ),
      error: (_, _) => const SizedBox.shrink(),
      data: (s) {
        final items = s.all;
        return Column(
          children: [
            Row(
              children: [
                Expanded(child: _SubScoreCard(item: items[0])),
                const SizedBox(width: Spacing.sm),
                Expanded(child: _SubScoreCard(item: items[1])),
              ],
            ),
            const SizedBox(height: Spacing.sm),
            Row(
              children: [
                Expanded(child: _SubScoreCard(item: items[2])),
                const SizedBox(width: Spacing.sm),
                Expanded(child: _SubScoreCard(item: items[3])),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _SubScoreCard extends StatelessWidget {
  const _SubScoreCard({required this.item});

  final SubScore item;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outline, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${item.value}',
            style: tt.headlineSmall?.copyWith(color: AppColors.gold),
          ),
          Text(
            item.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: tt.bodySmall?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

/// Блок 4 — совет дня, вытекающий из самого слабого звена.
class _DailyTipCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tt = Theme.of(context).textTheme;
    final scores = ref.watch(subScoresProvider).value;
    final tip = scores == null
        ? 'Маленькое действие сегодня лучше идеального плана завтра.'
        : dailyTip(scores);
    return Container(
      padding: const EdgeInsets.all(Spacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: AppColors.gold.withValues(alpha: 0.2), width: 0.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb_outline, color: AppColors.gold, size: 20),
          const SizedBox(width: Spacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Совет дня', style: tt.titleSmall),
                const SizedBox(height: 2),
                Text(
                  tip,
                  style: tt.bodySmall?.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
