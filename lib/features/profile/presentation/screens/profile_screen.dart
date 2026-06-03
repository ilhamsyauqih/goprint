import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/custom_app_bar.dart';

/// Placeholder ProfileScreen — akan diimplementasikan di task A3.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Profil',
        showBackButton: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: isDark
                    ? AppColors.headerGradientDark
                    : AppColors.headerGradient,
              ),
              child: const Icon(
                Icons.person_rounded,
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Profil Pengguna',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Kelola profil dan pengaturan',
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
