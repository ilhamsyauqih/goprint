import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/mock_shops.dart';

/// Komponen: [OperatingHoursWidget] — tampil jam buka per hari
class OperatingHoursWidget extends StatelessWidget {
  const OperatingHoursWidget({
    required this.operatingHours,
    super.key,
  });

  final List<OperatingHour> operatingHours;

  // Dapatkan indeks hari ini (0 = Senin, 6 = Minggu)
  int get _todayIndex {
    // DateTime.now().weekday: 1 (Senin) s.d. 7 (Minggu)
    return DateTime.now().weekday - 1;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Widget
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Icon(
                  Icons.access_time_filled_rounded,
                  color: isDark ? AppColors.teal300 : AppColors.teal700,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Jam Operasional',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const Divider(),

          // List jam per hari
          ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: operatingHours.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = operatingHours[index];
              final isToday = index == _todayIndex;

              return Container(
                color: isToday
                    ? (isDark
                        ? AppColors.teal900.withValues(alpha: 0.2)
                        : const Color(0xFFE0F2F1).withValues(alpha: 0.5))
                    : Colors.transparent,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Nama Hari
                    Row(
                      children: [
                        Text(
                          item.day,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                            color: isToday
                                ? (isDark ? AppColors.teal300 : AppColors.teal700)
                                : (isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText),
                          ),
                        ),
                        if (isToday) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.teal800 : AppColors.teal200,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Hari Ini',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: isDark ? Colors.white : AppColors.teal900,
                                fontWeight: FontWeight.w800,
                                fontSize: 9,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),

                    // Jam Buka / Status Tutup
                    Text(
                      item.hours,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
                        color: item.isClosed
                            ? (isDark ? AppColors.errorDark : AppColors.error)
                            : (isToday
                                ? (isDark ? AppColors.teal300 : AppColors.teal700)
                                : (isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText)),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
