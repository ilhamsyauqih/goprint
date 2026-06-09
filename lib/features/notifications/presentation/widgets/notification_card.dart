import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/notification_model.dart';

class NotificationCard extends StatelessWidget {
  const NotificationCard({
    required this.notification,
    required this.onMarkRead,
    super.key,
  });

  final NotificationModel notification;
  final VoidCallback onMarkRead;

  Color _typeColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    switch (notification.type) {
      case 'order_new':
      case 'order_update':
      case 'order_confirmed':
      case 'order_processing':
      case 'order_ready':
      case 'order_completed':
      case 'order_cancelled':
      case 'order':
        return isDark ? AppColors.teal300 : AppColors.teal700;
      case 'payment':
      case 'payment_proof_uploaded':
      case 'payment_verified':
      case 'payment_rejected':
        return isDark ? AppColors.successDark : AppColors.success;
      case 'promo':
        return isDark ? AppColors.warningDark : AppColors.warning;
      case 'system':
      default:
        return isDark ? AppColors.infoDark : AppColors.info;
    }
  }

  IconData get _typeIcon {
    switch (notification.type) {
      case 'order_new':
      case 'order_update':
      case 'order_confirmed':
      case 'order_processing':
      case 'order_ready':
      case 'order_completed':
      case 'order_cancelled':
      case 'order':
        return Icons.receipt_long_rounded;
      case 'payment':
      case 'payment_proof_uploaded':
      case 'payment_verified':
      case 'payment_rejected':
        return Icons.payments_outlined;
      case 'promo':
        return Icons.local_offer_outlined;
      case 'system':
      default:
        return Icons.settings_suggest_outlined;
    }
  }

  String get _typeLabel {
    switch (notification.type) {
      case 'order_new':
        return 'Pesanan Baru';
      case 'order_update':
      case 'order_confirmed':
      case 'order_processing':
      case 'order_ready':
      case 'order_completed':
      case 'order_cancelled':
      case 'order':
        return 'Pesanan';
      case 'payment':
      case 'payment_proof_uploaded':
      case 'payment_verified':
      case 'payment_rejected':
        return 'Pembayaran';
      case 'promo':
        return 'Promo';
      case 'system':
      default:
        return 'Sistem';
    }
  }

  String get _timeLabel {
    final difference = DateTime.now().difference(notification.createdAt);
    if (difference.inMinutes < 1) {
      return 'Baru saja';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} menit lalu';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} jam lalu';
    } else if (difference.inDays == 1) {
      return 'Kemarin';
    } else {
      return '${notification.createdAt.day}/${notification.createdAt.month}/${notification.createdAt.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final typeColor = _typeColor(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mutedColor = isDark
        ? AppColors.darkMutedText
        : AppColors.lightSubtleText;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: notification.isRead ? null : onMarkRead,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 5,
                decoration: BoxDecoration(
                  color: typeColor,
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(12),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: typeColor.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(_typeIcon, color: typeColor, size: 21),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        notification.title,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              fontWeight: notification.isRead
                                                  ? FontWeight.w600
                                                  : FontWeight.w800,
                                            ),
                                      ),
                                    ),
                                    if (!notification.isRead)
                                      Container(
                                        width: 9,
                                        height: 9,
                                        decoration: const BoxDecoration(
                                          color: AppColors.error,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  notification.body,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: mutedColor,
                                        height: 1.35,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: typeColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              _typeLabel,
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    color: typeColor,
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            _timeLabel,
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(color: mutedColor),
                          ),
                        ],
                      ),
                      if (!notification.isRead) ...[
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: onMarkRead,
                            child: const Text('Tandai Dibaca'),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
