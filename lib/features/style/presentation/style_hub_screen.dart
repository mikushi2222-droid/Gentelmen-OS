import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gentleman_os/core/constants/spacing.dart';
import 'package:gentleman_os/core/theme/app_colors.dart';
import 'package:gentleman_os/core/widgets/module_card.dart';

class StyleHubScreen extends StatelessWidget {
  const StyleHubScreen({super.key});

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
                Text('Стиль', style: tt.titleMedium),
              ],
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(Spacing.screenPadding),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                ModuleCard(
                  icon: Icons.checkroom_outlined,
                  title: 'Гардероб',
                  subtitle: 'Вещи и коллекция',
                  onTap: () => context.go('/wardrobe'),
                ),
                ModuleCard(
                  icon: Icons.style_outlined,
                  title: 'Образы',
                  subtitle: 'Составить и оценить аутфит',
                  onTap: () => context.go('/outfits'),
                ),
                ModuleCard(
                  icon: Icons.auto_fix_high,
                  title: 'Советник стиля',
                  subtitle: 'AI-рекомендации по образу',
                  onTap: () => context.go('/style-advisor'),
                ),
                ModuleCard(
                  icon: Icons.shopping_bag_outlined,
                  title: 'Покупки',
                  subtitle: 'Вишлист и желаемые вещи',
                  onTap: () => context.go('/purchases'),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
