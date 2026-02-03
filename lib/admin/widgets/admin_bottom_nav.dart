import 'package:flutter/material.dart';

class AdminBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AdminBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const Color primaryColor = Color(0xFFBE4A31);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      selectedItemColor: primaryColor,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      items: const [
        // 0 — ALAT
        BottomNavigationBarItem(
          icon: Icon(Icons.build_outlined),
          label: 'Alat',
        ),

        // 1 — PEMINJAMAN
        BottomNavigationBarItem(
          icon: Icon(Icons.assignment_outlined),
          label: 'Peminjaman',
        ),

        // 2 — DASHBOARD
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_outlined),
          label: 'Dashboard',
        ),

        // 3 — PENGEMBALIAN
        BottomNavigationBarItem(
          icon: Icon(Icons.timer_outlined),
          label: 'Pengembalian',
        ),

        // 4 — SETTINGS
        BottomNavigationBarItem(
          icon: Icon(Icons.settings_outlined),
          label: 'Settings',
        ),
      ],
    );
  }
}
