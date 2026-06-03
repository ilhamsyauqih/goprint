import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

/// Placeholder AdminDashboardScreen — akan diimplementasikan di task R3.
class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: isDark
                    ? AppColors.headerGradientDark
                    : AppColors.headerGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.dashboard_rounded,
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Dashboard Admin',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'Panel manajemen toko',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isDark
                    ? AppColors.darkMutedText
                    : AppColors.lightSubtleText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
