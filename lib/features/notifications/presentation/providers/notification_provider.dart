// lib/features/notifications/presentation/providers/notification_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/models/notification_model.dart';
import '../../../../data/repositories/notification_repository_impl.dart';
import '../../../../data/repositories/auth_repository_impl.dart';

class NotificationState {
  final List<NotificationModel> notifications;
  final bool isLoading;
  final String? errorMessage;

  NotificationState({
    this.notifications = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  NotificationState copyWith({
    List<NotificationModel>? notifications,
    bool? isLoading,
    String? errorMessage,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class NotificationNotifier extends StateNotifier<NotificationState> {
  final Ref _ref;

  NotificationNotifier(this._ref) : super(NotificationState()) {
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    state = state.copyWith(isLoading: true);
    try {
      final user = await _ref.read(authRepositoryProvider).getCurrentUser();
      if (user == null) {
        state = state.copyWith(isLoading: false, errorMessage: 'User not logged in');
        return;
      }

      final repo = _ref.read(notificationRepositoryProvider);
      final list = await repo.getUserNotifications(user.id);
      state = state.copyWith(notifications: list, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      final repo = _ref.read(notificationRepositoryProvider);
      await repo.markAsRead(notificationId);
      
      // Update local state directly to be responsive
      state = state.copyWith(
        notifications: state.notifications.map((n) {
          if (n.id == notificationId) {
            return n.copyWith(isRead: true);
          }
          return n;
        }).toList(),
      );
    } catch (e) {
      // Refresh to ensure correctness if update fails
      await loadNotifications();
    }
  }

  Future<void> markAllAsRead() async {
    try {
      final user = await _ref.read(authRepositoryProvider).getCurrentUser();
      if (user == null) return;

      final repo = _ref.read(notificationRepositoryProvider);
      await repo.markAllAsRead(user.id);

      state = state.copyWith(
        notifications: state.notifications.map((n) => n.copyWith(isRead: true)).toList(),
      );
    } catch (e) {
      await loadNotifications();
    }
  }
}

final notificationNotifierProvider = StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
  return NotificationNotifier(ref);
});

// Helper provider for unread notifications count
final unreadNotificationsCountProvider = Provider<int>((ref) {
  final state = ref.watch(notificationNotifierProvider);
  return state.notifications.where((n) => !n.isRead).length;
});
