import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gentleman_os/core/theme/app_colors.dart';

class ShellScaffold extends StatelessWidget {
  const ShellScaffold({required this.child, super.key});

  final Widget child;

  static const _tabs = [
    _Tab(
      label: 'Штаб',
      icon: Icons.home_outlined,
      active: Icons.home,
      path: '/dashboard',
    ),
    _Tab(
      label: 'Стиль',
      icon: Icons.checkroom_outlined,
      active: Icons.checkroom,
      path: '/style',
      aliases: ['/wardrobe', '/outfits', '/style-advisor', '/purchases'],
    ),
    _Tab(
      label: 'Тело',
      icon: Icons.favorite_border,
      active: Icons.favorite,
      path: '/body',
      aliases: ['/health', '/progress'],
    ),
    _Tab(
      label: 'Разум',
      icon: Icons.psychology_outlined,
      active: Icons.psychology,
      path: '/mind',
      aliases: ['/biohacking', '/knowledge', '/habits'],
    ),
    _Tab(
      label: 'Система',
      icon: Icons.person_outline,
      active: Icons.person,
      path: '/profile',
    ),
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
      if (_matchesPath(location, _tabs[i].path)) return i;
      for (final alias in _tabs[i].aliases) {
        if (_matchesPath(location, alias)) return i;
      }
    }
    return 0;
  }

  // Matches exact path or any sub-path (avoids /style matching /style-advisor).
  static bool _matchesPath(String location, String path) {
    return location == path || location.startsWith('$path/');
  }
}

class _Tab {
  const _Tab({
    required this.label,
    required this.icon,
    required this.active,
    required this.path,
    this.aliases = const [],
  });

  final String label;
  final IconData icon;
  final IconData active;
  final String path;
  final List<String> aliases;
}
