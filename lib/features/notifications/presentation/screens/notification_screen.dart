import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../data/notification_store.dart';
import '../widgets/notification_card.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<GoPrintNotification>>(
      valueListenable: notificationStore,
      builder: (context, notifications, _) {
        final unreadCount = notificationStore.unreadCount;

        return Scaffold(
          appBar: CustomAppBar(
            title: 'Notifikasi',
            showBackButton: false,
            actions: [
              if (unreadCount > 0)
                TextButton(
                  onPressed: notificationStore.markAllAsRead,
                  child: const Text(
                    'Tandai Semua Dibaca',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
            ],
          ),
          body: notifications.isEmpty
              ? const _EmptyNotificationState()
              : ListView(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                  children: [
                    _UnreadSummary(unreadCount: unreadCount),
                    const SizedBox(height: 14),
                    for (final notification in notifications)
                      NotificationCard(
                        key: ValueKey(notification.id),
                        notification: notification,
                        onMarkRead: () {
                          notificationStore.markAsRead(notification.id);
                        },
                      ),
                  ],
                ),
        );
      },
    );
  }
}

class _UnreadSummary extends StatelessWidget {
  const _UnreadSummary({required this.unreadCount});

  final int unreadCount;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkElevated : AppColors.lightCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: unreadCount > 0
                  ? AppColors.error.withValues(alpha: 0.12)
                  : AppColors.teal700.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              unreadCount > 0
                  ? Icons.notifications_active_rounded
                  : Icons.done_all_rounded,
              color: unreadCount > 0 ? AppColors.error : AppColors.teal700,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              unreadCount > 0
                  ? '$unreadCount notifikasi belum dibaca'
                  : 'Semua notifikasi sudah dibaca',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyNotificationState extends StatelessWidget {
  const _EmptyNotificationState();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mutedColor = isDark
        ? AppColors.darkMutedText
        : AppColors.lightSubtleText;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: (isDark ? AppColors.teal300 : AppColors.teal700)
                    .withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_off_outlined,
                size: 58,
                color: isDark ? AppColors.teal300 : AppColors.teal700,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Belum ada notifikasi',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              'Update pesanan, pembayaran, dan promo akan muncul di sini.',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: mutedColor, height: 1.45),
            ),
          ],
        ),
      ),
    );
  }
}
