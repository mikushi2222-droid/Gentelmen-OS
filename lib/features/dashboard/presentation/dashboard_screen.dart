import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gentleman_os/core/constants/spacing.dart';
import 'package:gentleman_os/core/theme/app_colors.dart';
import 'package:gentleman_os/core/widgets/score_ring.dart';
import 'package:gentleman_os/features/dashboard/presentation/widgets/mission_tile.dart';
import 'package:gentleman_os/features/dashboard/presentation/widgets/quick_action_button.dart';

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

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 0,
            floating: true,
            snap: true,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: _GentlemanCrest(size: 36),
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

/// Герб/логотип из макета
class _GentlemanCrest extends StatelessWidget {
  const _GentlemanCrest({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.gold.withOpacity(0.15),
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.gold, width: 1),
      ),
      child: Icon(
        Icons.shield_outlined,
        color: AppColors.gold,
        size: size * 0.55,
      ),
    );
  }
}

/// Блок Gentleman Score из макета (732, круговой ring, золото)
class _GentlemanScoreCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gold.withOpacity(0.3), width: 0.5),
      ),
      padding: const EdgeInsets.all(Spacing.cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Большой score из макета
              ScoreRing(
                score: 73.2,
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
                        Icon(Icons.trending_up,
                            color: AppColors.success, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '+5 за неделю',
                          style: tt.bodySmall?.copyWith(
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Сегодняшняя рекомендация
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                            color: AppColors.gold.withOpacity(0.3)),
                      ),
                      child: Text(
                        'Образ дня готов',
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

class _DailyMissionsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Задачи дня', style: tt.titleMedium),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.gold.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '2 / 3',
                style: tt.labelSmall?.copyWith(color: AppColors.gold),
              ),
            ),
          ],
        ),
        const SizedBox(height: Spacing.sm),
        const MissionTile(
          title: 'Записать замеры',
          xpReward: 15,
          completed: true,
          xpType: 'fitness',
        ),
        const MissionTile(
          title: 'Собрать образ на сегодня',
          xpReward: 15,
          completed: true,
          xpType: 'style',
        ),
        const MissionTile(
          title: 'Прочитать одну статью',
          xpReward: 10,
          completed: false,
          xpType: 'reading',
        ),
      ],
    );
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
          ],
        ),
      ],
    );
  }
}
