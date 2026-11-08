import 'package:flutter/material.dart';
import '../features/account/account_screen.dart';
import '../features/account/login_gate.dart';
import '../features/chatbot/chatbot_screen.dart';
import '../features/home/home_screen.dart';
import '../features/marketplace/marketplace_screen.dart';
import '../features/production/production_screen.dart';
import 'app_navigation.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key});

  static const _pages = <Widget>[
    HomeScreen(),
    MarketplaceScreen(),
    ProductionScreen(),
    LoginGate(
      title: 'EcoBot',
      icon: Icons.smart_toy_rounded,
      message:
          'EcoBot adalah asisten pintar untuk produksi kompos dan maggot BSF. Fitur ini hanya untuk pengguna yang sudah masuk. Daftar dan masuk dulu, ya.',
      child: ChatbotScreen(),
    ),
    AccountScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: mainTabIndex,
      builder: (context, index, _) {
        return Scaffold(
          body: Center(
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