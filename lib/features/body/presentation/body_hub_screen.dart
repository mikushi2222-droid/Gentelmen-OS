import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gentleman_os/core/constants/spacing.dart';
import 'package:gentleman_os/core/theme/app_colors.dart';
import 'package:gentleman_os/core/widgets/module_card.dart';

class BodyHubScreen extends StatelessWidget {
  const BodyHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            snap: true,
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
                Text('Тело', style: tt.titleMedium),
              ],
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(Spacing.screenPadding),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                ModuleCard(
                  icon: Icons.favorite_border,
                  title: 'Здоровье',
                  subtitle: 'Маркеры, давление, анализы',
                  onTap: () => context.go('/health'),
                ),
                ModuleCard(
                  icon: Icons.trending_up,
                  title: 'Прогресс',
                  subtitle: 'Вес, замеры и тренировки',
                  onTap: () => context.go('/progress'),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
