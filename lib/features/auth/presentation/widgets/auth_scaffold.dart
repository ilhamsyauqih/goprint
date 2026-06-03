import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

/// Scaffold wrapper untuk halaman autentikasi — logo, judul, subtitle.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    required this.title,
    required this.subtitle,
    required this.child,
    this.showBackButton = false,
    super.key,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 48,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: showBackButton
                      ? IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.arrow_back_rounded),
                        )
                      : const SizedBox.shrink(),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryButtonGradient,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.print_rounded,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(height: 28),
              Text(
                title,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.lightSubtleText,
                  height: 1.45,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 34),
              child,
            ],
          ),
        ),
      ),
    );
  }
}
