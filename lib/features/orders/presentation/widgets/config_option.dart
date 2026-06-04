import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

/// Komponen: [ConfigOption] — row pilihan dengan label + control (dropdown/toggle/stepper)
class ConfigOption extends StatelessWidget {
  const ConfigOption({
    required this.label,
    required this.control,
    this.description,
    this.icon,
    super.key,
  });

  final String label;
  final String? description;
  final Widget control;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      child: Row(
        children: [
          // ─── Icon (Optional) ─────────────────────────────────────────
          if (icon != null) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.teal800.withValues(alpha: 0.15)
                    : const Color(0xFFE0F2F1).withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isDark ? AppColors.teal300 : AppColors.teal700,
                size: 18,
              ),
            ),
            const SizedBox(width: 14),
          ],

          // ─── Teks Label & Deskripsi ──────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                if (description != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    description!,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: isDark ? AppColors.darkMutedText : AppColors.lightSubtleText,
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 16),

          // ─── Widget Kontrol (Dropdown / Toggle / Stepper) ─────────────
          control,
        ],
      ),
    );
  }
}
