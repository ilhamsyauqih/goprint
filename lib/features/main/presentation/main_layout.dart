import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/custom_bottom_nav_bar.dart';

/// Layout utama aplikasi — Scaffold dengan [CustomBottomNavBar] di bawah.
///
/// Menggunakan [StatefulNavigationShell] dari go_router untuk mempertahankan
/// state setiap tab (IndexedStack behavior).
class MainLayout extends StatelessWidget {
  const MainLayout({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) {
          navigationShell.goBranch(
            index,
            // Navigate to the initial location of the branch when tapping
            // the item that is already active.
            initialLocation: index == navigationShell.currentIndex,
          );
        },
      ),
    );
  }
}
