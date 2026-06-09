// lib/data/services/order_realtime_service.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/supabase/supabase_service.dart';
import '../models/order_model.dart';
import '../models/notification_model.dart';

class OrderRealtimeService {
  final SupabaseClient _client;

  OrderRealtimeService(this._client);

  /// Stream updates for a specific order status
  Stream<OrderModel> subscribeToOrderStatus(String orderId) {
    return _client
        .from('orders')
        .stream(primaryKey: ['id'])
        .eq('id', orderId)
        .map((data) {
          if (data.isEmpty) {
            throw StateError('Order not found');
          }
          return OrderModel.fromJson(data.first);
        });
  }

  /// Stream all orders for a specific shop
  Stream<List<OrderModel>> subscribeToShopOrders(String shopId) {
    return _client
        .from('orders')
        .stream(primaryKey: ['id'])
        .eq('shop_id', shopId)
        .map((data) {
          return data.map((json) => OrderModel.fromJson(json)).toList();
        });
  }

  /// Stream notifications for a specific user
  Stream<List<NotificationModel>> subscribeToNotifications(String userId) {
    return _client
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .map((data) {
          return data.map((json) => NotificationModel.fromJson(json)).toList();
        });
  }
}

/// Riverpod provider for OrderRealtimeService
final orderRealtimeServiceProvider = Provider<OrderRealtimeService>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return OrderRealtimeService(client);
});

/// Riverpod stream provider for tracking status of a single order
final orderStatusStreamProvider = StreamProvider.family<OrderModel, String>((ref, orderId) {
  final service = ref.watch(orderRealtimeServiceProvider);
  return service.subscribeToOrderStatus(orderId);
});

/// Riverpod stream provider for tracking orders of a specific shop
final shopOrdersStreamProvider = StreamProvider.family<List<OrderModel>, String>((ref, shopId) {
  final service = ref.watch(orderRealtimeServiceProvider);
  return service.subscribeToShopOrders(shopId);
});

/// Riverpod stream provider for tracking notifications of a user
final userNotificationsStreamProvider = StreamProvider.family<List<NotificationModel>, String>((ref, userId) {
  final service = ref.watch(orderRealtimeServiceProvider);
  return service.subscribeToNotifications(userId);
});
