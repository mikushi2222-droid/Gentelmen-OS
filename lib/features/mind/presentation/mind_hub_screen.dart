import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gentleman_os/core/constants/spacing.dart';
import 'package:gentleman_os/core/theme/app_colors.dart';
import 'package:gentleman_os/core/widgets/module_card.dart';

class MindHubScreen extends StatelessWidget {
  const MindHubScreen({super.key});

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
                Text('Разум', style: tt.titleMedium),
              ],
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(Spacing.screenPadding),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                ModuleCard(
                  icon: Icons.bolt_outlined,
                  title: 'Биохакинг',
                  subtitle: 'Протоколы и оптимизация',
                  onTap: () => context.go('/biohacking'),
                ),
                ModuleCard(
                  icon: Icons.task_alt,
                  title: 'Привычки',
                  subtitle: 'Ежедневные ритуалы',
                  onTap: () => context.go('/habits'),
                ),
                ModuleCard(
                  icon: Icons.menu_book_outlined,
                  title: 'База знаний',
                  subtitle: 'Статьи и гайды',
                  onTap: () => context.go('/knowledge'),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
