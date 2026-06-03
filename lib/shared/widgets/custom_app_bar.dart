import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

/// App Bar kustom GoPrint — gradasi teal, judul putih, back button putih.
///
/// Mengimplementasikan [PreferredSizeWidget] sehingga bisa dipakai langsung
/// pada properti `appBar` di [Scaffold].
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    required this.title,
    this.showBackButton = true,
    this.actions,
    this.leading,
    this.bottom,
    super.key,
  });

  final String title;
  final bool showBackButton;
  final List<Widget>? actions;
  final Widget? leading;
  final PreferredSizeWidget? bottom;

  @override
  Size get preferredSize => Size.fromHeight(
    kToolbarHeight + (bottom?.preferredSize.height ?? 0),
  );

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gradient = isDark
        ? AppColors.headerGradientDark
        : AppColors.headerGradient;

    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        boxShadow: [
          BoxShadow(
            color: AppColors.teal900.withValues(alpha: 0.18),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: AppBar(
        title: Text(
          title,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: showBackButton
            ? (leading ??
                IconButton(
                  icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                  onPressed: () => Navigator.of(context).maybePop(),
                ))
            : leading,
        actions: actions,
        bottom: bottom,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
    );
  }
}
