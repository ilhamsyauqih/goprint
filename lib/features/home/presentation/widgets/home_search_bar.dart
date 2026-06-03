import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

/// Bar pencarian mengambang (floating) di bawah header.
class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({
    this.onTap,
    super.key,
  });

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightCard,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Icon(
                    Icons.search_rounded,
                    color: isDark ? AppColors.teal300 : AppColors.teal700,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Cari toko atau layanan...',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isDark
                            ? AppColors.darkMutedText
                            : AppColors.lightSubtleText,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.teal800.withValues(alpha: 0.3)
                          : const Color(0xFFE0F2F1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      Icons.tune_rounded,
                      size: 16,
                      color: isDark ? AppColors.teal300 : AppColors.teal700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
