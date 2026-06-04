import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/order_model.dart';

/// Badge status pesanan dengan skema warna spesifik.
class StatusBadge extends StatelessWidget {
  final OrderStatus status;

  const StatusBadge({required this.status, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color bgColor;
    Color textColor;
    String label;

    switch (status) {
      case OrderStatus.pending:
        label = 'Menunggu Konfirmasi';
        bgColor = isDark ? Colors.grey.shade800 : Colors.grey.shade200;
        textColor = isDark ? Colors.grey.shade300 : Colors.grey.shade700;
        break;
      case OrderStatus.confirmed:
        label = 'Dikonfirmasi';
        bgColor = isDark ? AppColors.infoDark.withValues(alpha: 0.15) : const Color(0xFFE3F2FD);
        textColor = isDark ? AppColors.infoDark : AppColors.info;
        break;
      case OrderStatus.processing:
        label = 'Diproses';
        bgColor = isDark ? AppColors.warningDark.withValues(alpha: 0.15) : const Color(0xFFFFFDE7);
        textColor = isDark ? AppColors.warningDark : AppColors.warning;
        break;
      case OrderStatus.ready:
        label = 'Siap Diambil';
        bgColor = isDark ? AppColors.teal200.withValues(alpha: 0.15) : const Color(0xFFE0F2F1);
        textColor = isDark ? AppColors.teal200 : AppColors.teal700;
        break;
      case OrderStatus.completed:
        label = 'Selesai';
        bgColor = isDark ? AppColors.successDark.withValues(alpha: 0.15) : const Color(0xFFE8F5E9);
        textColor = isDark ? AppColors.successDark : AppColors.success;
        break;
      case OrderStatus.cancelled:
        label = 'Dibatalkan';
        bgColor = isDark ? AppColors.errorDark.withValues(alpha: 0.15) : const Color(0xFFFFEBEE);
        textColor = isDark ? AppColors.errorDark : AppColors.error;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: textColor.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
