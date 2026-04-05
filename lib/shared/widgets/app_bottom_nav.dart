import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

class AppBottomNav extends StatelessWidget {
  final StatefulNavigationShell shell;

  const AppBottomNav({
    super.key,
    required this.shell,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
            )
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: shell.currentIndex,
          onTap: (index) => _onNavTap(index),
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          items: const [
            BottomNavigationBarItem(icon: Icon(Iconsax.home), label: 'Dashboard'),
            BottomNavigationBarItem(icon: Icon(Iconsax.receipt), label: 'Transactions'),
            BottomNavigationBarItem(icon: Icon(Iconsax.flag), label: 'Goals'),
            BottomNavigationBarItem(icon: Icon(Iconsax.chart_2), label: 'Insights'),
            BottomNavigationBarItem(icon: Icon(Iconsax.setting), label: 'Settings'),
          ],
        ),
      ),
    );
  }

  void _onNavTap(int index) {
    shell.goBranch(
      index,
      initialLocation: index == shell.currentIndex,
    );
  }
}