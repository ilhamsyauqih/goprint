import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

/// Prompt "Belum punya akun? Daftar" / "Sudah punya akun? Login".
class AuthSwitchPrompt extends StatelessWidget {
  const AuthSwitchPrompt({
    required this.text,
    required this.actionText,
    required this.onPressed,
    super.key,
  });

  final String text;
  final String actionText;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? AppColors.darkMutedText : AppColors.lightSubtleText,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            actionText,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.teal300 : AppColors.teal700,
            ),
          ),
        ),
      ],
    );
  }
}
