import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/custom_app_bar.dart';

/// Placeholder NotificationScreen — akan diimplementasikan di task A4.
class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Notifikasi',
        showBackButton: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_rounded,
              size: 64,
              color: isDark ? AppColors.teal300 : AppColors.teal700,
            ),
            const SizedBox(height: 16),
            Text(
              'Notifikasi',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Belum ada notifikasi',
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
