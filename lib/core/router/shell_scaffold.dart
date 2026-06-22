import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gentleman_os/core/theme/app_colors.dart';

class ShellScaffold extends StatelessWidget {
  const ShellScaffold({required this.child, super.key});

  final Widget child;

  static const _tabs = [
    _Tab(label: 'Главная', icon: Icons.home_outlined, active: Icons.home, path: '/dashboard'),
    _Tab(label: 'Гардероб', icon: Icons.checkroom_outlined, active: Icons.checkroom, path: '/wardrobe'),
    _Tab(label: 'Здоровье', icon: Icons.favorite_outline, active: Icons.favorite, path: '/health'),
    _Tab(label: 'Биохакинг', icon: Icons.bolt_outlined, active: Icons.bolt, path: '/biohacking'),
    _Tab(label: 'Профиль', icon: Icons.person_outline, active: Icons.person, path: '/profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final currentIndex = _currentIndex(location);

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (i) => context.go(_tabs[i].path),
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.gold.withValues(alpha: 0.2),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: _tabs
            .map(
              (t) => NavigationDestination(
                icon: Icon(t.icon, color: AppColors.textSecondary),
                selectedIcon: Icon(t.active, color: AppColors.gold),
                label: t.label,
              ),
            )
            .toList(),
      ),
    );
  }

  int _currentIndex(String location) {
    for (var i = _tabs.length - 1; i >= 0; i--) {
      if (location.startsWith(_tabs[i].path)) return i;
    }
    return 0;
  }
}

class _Tab {
  const _Tab({
    required this.label,
    required this.icon,
    required this.active,
    required this.path,
  });

  final String label;
  final IconData icon;
  final IconData active;
  final String path;
}
