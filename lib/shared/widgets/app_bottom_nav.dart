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
        decoration: const BoxDecoration(
          color: Color(0xFF090D14),
          border: Border(
            top: BorderSide(color: Color(0xFF1A2331), width: 1),
          ),
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: shell.currentIndex,
          onTap: _onNavTap,
          backgroundColor: const Color(0xFF090D14),
          selectedItemColor: const Color(0xFF4D8DFF),
          unselectedItemColor: const Color(0xFF8A94A6),
          elevation: 0,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedFontSize: 11,
          unselectedFontSize: 11,
          items: const [
            BottomNavigationBarItem(icon: Icon(Iconsax.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Iconsax.receipt), label: 'Activity'),
            BottomNavigationBarItem(icon: Icon(Iconsax.wallet_2), label: 'Budget'),
            BottomNavigationBarItem(icon: Icon(Iconsax.chart_2), label: 'Statistics'),
            BottomNavigationBarItem(icon: Icon(Iconsax.setting), label: 'Profile'),
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
