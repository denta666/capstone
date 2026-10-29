import 'package:flutter/material.dart';
import '../core/widgets/empty_state.dart';
import '../features/home/home_screens.dart';
import 'app_navigation.dart';



class MainShell extends StatelessWidget {    
  const MainShell({super.key});

  static const _pages = <Widget>[
    HomeScreen(),
    _TabPlaceholder(
        title: 'Marketplace', icon: Icons.storefront_rounded, tahap: 4),
    _TabPlaceholder(
        title: 'Mulai Produksi', icon: Icons.spa_rounded, tahap: 5),
    _TabPlaceholder(title: 'EcoBot', icon: Icons.smart_toy_rounded, tahap: 7),
    _TabPlaceholder(title: 'Akun', icon: Icons.person_rounded, tahap: 7),
  ];

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: mainTabIndex,
      builder: (context, index, _) {
        return Scaffold(
          body: Center(
            // Dibatasi lebarnya supaya di Chrome tampil seperti layar HP.
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: double.infinity),
              child: IndexedStack(index: index, children: _pages),
            ),
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: index,
            onDestinationSelected: (i) => mainTabIndex.value = i,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_rounded),
                label: 'Beranda',
              ),
              NavigationDestination(
                icon: Icon(Icons.storefront_outlined),
                selectedIcon: Icon(Icons.storefront_rounded),
                label: 'Marketplace',
              ),
              NavigationDestination(
                icon: Icon(Icons.spa_outlined),
                selectedIcon: Icon(Icons.spa_rounded),
                label: 'Produksi',
              ),
              NavigationDestination(
                icon: Icon(Icons.smart_toy_outlined),
                selectedIcon: Icon(Icons.smart_toy_rounded),
                label: 'EcoBot',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person_rounded),
                label: 'Akun',
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TabPlaceholder extends StatelessWidget {
  const _TabPlaceholder({
    required this.title,
    required this.icon,
    required this.tahap,
  });

  final String title;
  final IconData icon;
  final int tahap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: EmptyState(
        icon: icon,
        title: 'Halaman $title',
        message: 'Akan dibuat di Tahap $tahap.',
      ),
    );
  }
}