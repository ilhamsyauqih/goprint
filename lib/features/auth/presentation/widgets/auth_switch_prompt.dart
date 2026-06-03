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
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.lightSubtleText,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        TextButton(
          onPressed: onPressed,
          child: Text(
            actionText,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }
}
