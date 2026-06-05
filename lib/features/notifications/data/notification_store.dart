import 'package:flutter/foundation.dart';

enum NotificationType { order, payment, promo, system }

class GoPrintNotification {
  const GoPrintNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.timeLabel,
    required this.type,
    required this.isRead,
  });

  final String id;
  final String title;
  final String body;
  final String timeLabel;
  final NotificationType type;
  final bool isRead;

  GoPrintNotification copyWith({bool? isRead}) {
    return GoPrintNotification(
      id: id,
      title: title,
      body: body,
      timeLabel: timeLabel,
      type: type,
      isRead: isRead ?? this.isRead,
    );
  }
}

class NotificationStore extends ValueNotifier<List<GoPrintNotification>> {
  NotificationStore() : super(_seedNotifications);

  int get unreadCount {
    return value.where((notification) => !notification.isRead).length;
  }

  void markAsRead(String id) {
    value = [
      for (final notification in value)
        notification.id == id
            ? notification.copyWith(isRead: true)
            : notification,
    ];
  }

  void markAllAsRead() {
    value = [
      for (final notification in value) notification.copyWith(isRead: true),
    ];
  }

  void clear() {
    value = const [];
  }

  void reset() {
    value = _seedNotifications;
  }
}

const List<GoPrintNotification> _seedNotifications = [
  GoPrintNotification(
    id: 'ready-001',
    title: 'Pesanan siap diantar',
    body: 'Dokumen Metodologi Penelitian sudah selesai dicetak.',
    timeLabel: '2 menit lalu',
    type: NotificationType.order,
    isRead: false,
  ),
  GoPrintNotification(
    id: 'payment-001',
    title: 'Pembayaran terverifikasi',
    body: 'Pembayaran Rp24.000 untuk pesanan GP-1024 sudah diterima.',
    timeLabel: '18 menit lalu',
    type: NotificationType.payment,
    isRead: false,
  ),
  GoPrintNotification(
    id: 'promo-001',
    title: 'Promo jilid hemat',
    body: 'Diskon 15% untuk jilid soft cover di Mitra Kampus Print.',
    timeLabel: 'Kemarin',
    type: NotificationType.promo,
    isRead: true,
  ),
  GoPrintNotification(
    id: 'system-001',
    title: 'Alamat default diperbarui',
    body: 'Alamat Kos Melati sekarang menjadi alamat pengantaran utama.',
    timeLabel: '2 hari lalu',
    type: NotificationType.system,
    isRead: true,
  ),
];

final NotificationStore notificationStore = NotificationStore();
