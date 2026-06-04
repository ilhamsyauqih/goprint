import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Chip filter pemilihan periode statistik dasbor admin (PeriodFilterChip).
class PeriodFilterChip extends StatelessWidget {
  final String selectedPeriod;
  final ValueChanged<String> onPeriodSelected;

  const PeriodFilterChip({
    required this.selectedPeriod,
    required this.onPeriodSelected,
    super.key,
  });

  static const List<String> _periods = ['Hari Ini', '7 Hari', '30 Hari', 'Kustom'];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _periods.map((period) {
          final isSelected = selectedPeriod == period;
          final activeColor = isDark ? AppColors.teal300 : AppColors.teal700;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(
                period,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: isSelected
                      ? (isDark ? AppColors.teal900 : Colors.white)
                      : (isDark ? AppColors.darkPrimaryText : Colors.grey.shade700),
                ),
              ),
              selected: isSelected,
              selectedColor: activeColor,
              backgroundColor: isDark ? AppColors.darkElevated : Colors.grey.shade200,
              checkmarkColor: isDark ? AppColors.teal900 : Colors.white,
              onSelected: (selected) {
                if (selected) {
                  onPeriodSelected(period);
                }
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected
                      ? activeColor
                      : (isDark ? AppColors.darkBorder : Colors.transparent),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
