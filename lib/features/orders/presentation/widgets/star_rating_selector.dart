import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Komponen pemilihan rating bintang interaktif (StarRatingSelector).
class StarRatingSelector extends StatelessWidget {
  final int rating;
  final ValueChanged<int> onRatingChanged;

  const StarRatingSelector({
    required this.rating,
    required this.onRatingChanged,
    super.key,
  });

  String _getRatingText(int rating) {
    switch (rating) {
      case 1:
        return 'Sangat Buruk';
      case 2:
        return 'Buruk';
      case 3:
        return 'Cukup';
      case 4:
        return 'Baik';
      case 5:
        return 'Sangat Baik';
      default:
        return 'Sentuh bintang untuk memberikan nilai';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            final starNumber = index + 1;
            final isSelected = starNumber <= rating;
            return GestureDetector(
              onTap: () => onRatingChanged(starNumber),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Icon(
                  isSelected ? Icons.star_rounded : Icons.star_outline_rounded,
                  size: 44,
                  color: isSelected
                      ? Colors.amber.shade600
                      : (isDark ? AppColors.darkBorder : Colors.grey.shade400),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 12),
        Text(
          _getRatingText(rating),
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: rating > 0 ? FontWeight.bold : FontWeight.w500,
            color: rating > 0 
                ? (isDark ? AppColors.teal300 : AppColors.teal700)
                : (isDark ? AppColors.darkMutedText : AppColors.lightSubtleText),
          ),
        ),
      ],
    );
  }
}
