// lib/domain/repositories/notification_repository.dart

import '../../data/models/notification_model.dart';

abstract class NotificationRepository {
  /// Fetch all notifications for a specific user
  Future<List<NotificationModel>> getUserNotifications(String userId);

  /// Mark a single notification as read
  Future<void> markAsRead(String notificationId);

  /// Mark all notifications as read for a specific user
  Future<void> markAllAsRead(String userId);

  /// Create a new notification
  Future<void> createNotification(NotificationModel notification);
}
