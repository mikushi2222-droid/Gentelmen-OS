import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ShellScaffold extends StatelessWidget {
  const ShellScaffold({required this.child, super.key});

  final Widget child;

  static const _tabs = [
    _Tab(label: 'Главная', icon: Icons.home_outlined, active: Icons.home, path: '/dashboard'),
    _Tab(label: 'Гардероб', icon: Icons.checkroom_outlined, active: Icons.checkroom, path: '/wardrobe'),
    _Tab(label: 'Образы', icon: Icons.style_outlined, active: Icons.style, path: '/outfits'),
    _Tab(label: 'Знания', icon: Icons.menu_book_outlined, active: Icons.menu_book, path: '/knowledge'),
    _Tab(label: 'Прогресс', icon: Icons.trending_up_outlined, active: Icons.trending_up, path: '/progress'),
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
        destinations: _tabs
            .map(
              (t) => NavigationDestination(
                icon: Icon(t.icon),
                selectedIcon: Icon(t.active),
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
