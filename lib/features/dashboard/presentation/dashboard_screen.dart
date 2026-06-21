import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gentleman_os/core/constants/spacing.dart';
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
      backgroundColor: cs.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 0,
            floating: true,
            snap: true,
            title: Text(greeting, style: tt.headlineSmall),
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

class _GentlemanScoreCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.cardPadding),
        child: Row(
          children: [
            ScoreRing(
              score: 72,
              size: 100,
              label: 'SCORE',
              color: cs.primary,
            ),
            const SizedBox(width: Spacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Gentleman Score', style: tt.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    '↑ +5 за неделю',
                    style: tt.bodySmall?.copyWith(color: cs.primary),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Стиль · Форма · Дисциплина',
                    style: tt.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
            Text(
              '2/3',
              style: tt.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
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
              icon: Icons.add_circle_outline,
              label: 'Образ',
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
