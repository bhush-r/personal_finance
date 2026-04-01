
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

class AppBottomNav extends StatelessWidget {
  final StatefulNavigationShell shell;
  const AppBottomNav({super.key, required this.shell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: (index) => shell.goBranch(
          index,
          initialLocation: index == shell.currentIndex,
        ),
        destinations: const [
          NavigationDestination(
            icon: Icon(Iconsax.home_2),
            selectedIcon: Icon(Iconsax.home_25),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Iconsax.receipt),
            selectedIcon: Icon(Iconsax.receipt5),
            label: 'Transactions',
          ),
          NavigationDestination(
            icon: Icon(Iconsax.chart),
            selectedIcon: Icon(Iconsax.chart5),
            label: 'Goals',
          ),
          NavigationDestination(
            icon: Icon(Iconsax.graph),
            selectedIcon: Icon(Iconsax.graph5),
            label: 'Insights',
          ),
        ],
      ),
    );
  }
}