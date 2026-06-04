import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Kartu statistik dasbor admin (StatCard) untuk menampilkan metrik operasional.
class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;
  final String trendText;
  final bool isPositiveTrend;
  final Color? trendColor;

  const StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.trendText,
    this.isPositiveTrend = true,
    this.trendColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Menentukan warna label indikator tren
    final effectiveTrendColor = trendColor ??
        (isPositiveTrend
            ? (isDark ? AppColors.successDark : AppColors.success)
            : (isDark ? AppColors.warningDark : AppColors.warning));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.1 : 0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Baris atas: Label metrik & Icon berlatar belakang lembut
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: isDark ? AppColors.darkMutedText : AppColors.lightSubtleText,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Nilai metrik (angka statistik besar)
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
              fontSize: 21,
            ),
          ),
          const SizedBox(height: 8),
          // Baris bawah: Indikator tren
          Row(
            children: [
              Icon(
                isPositiveTrend ? Icons.trending_up_rounded : Icons.trending_flat_rounded,
                size: 14,
                color: effectiveTrendColor,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  trendText,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: effectiveTrendColor,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
