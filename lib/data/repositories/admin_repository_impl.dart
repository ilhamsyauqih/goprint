// lib/data/repositories/admin_repository_impl.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/supabase/supabase_service.dart';
import '../../domain/repositories/admin_repository.dart';
import '../models/order_model.dart';

class AdminRepositoryImpl implements AdminRepository {
  final SupabaseClient _client;

  AdminRepositoryImpl(this._client);

  @override
  Future<List<OrderModel>> getShopOrders(String shopId, {String? status}) async {
    var builder = _client
        .from('orders')
        .select('*, order_items(*)')
        .eq('shop_id', shopId);

    if (status != null && status.isNotEmpty) {
      builder = builder.eq('status', status);
    }

    final List data = await builder.order('created_at', ascending: false);
    return data.map((json) => OrderModel.fromJson(json)).toList();
  }

  @override
  Future<void> verifyPayment(String orderId, String paymentStatus) async {
    // If verified, we can also progress the order status to confirmed
    final updateData = {
      'payment_status': paymentStatus,
    };
    if (paymentStatus == 'verified') {
      updateData['status'] = 'confirmed';
    } else if (paymentStatus == 'rejected') {
      updateData['status'] = 'cancelled';
    }

    await _client
        .from('orders')
        .update(updateData)
        .eq('id', orderId);
  }

  @override
  Future<Map<String, dynamic>> getShopStats(String shopId) async {
    final List allOrders = await _client
        .from('orders')
        .select('status, total_price, created_at')
        .eq('shop_id', shopId);

    int totalOrdersToday = 0;
    int pendingCount = 0;
    int processingCount = 0;
    double totalRevenueToday = 0.0;

    final today = DateTime.now();
    final todayDateOnly = DateTime(today.year, today.month, today.day);

    for (final order in allOrders) {
      final status = order['status'] as String;
      final totalPrice = (order['total_price'] as num).toDouble();
      final createdAt = DateTime.parse(order['created_at'] as String);
      final orderDateOnly = DateTime(createdAt.year, createdAt.month, createdAt.day);

      if (orderDateOnly == todayDateOnly) {
        totalOrdersToday++;
        if (status != 'cancelled') {
          totalRevenueToday += totalPrice;
        }
      }

      if (status == 'pending') {
        pendingCount++;
      } else if (status == 'processing') {
        processingCount++;
      }
    }

    return {
      'total_orders_today': totalOrdersToday,
      'pending_confirmation_count': pendingCount,
      'total_revenue_today': totalRevenueToday,
      'processing_count': processingCount,
    };
  }

  @override
  Future<List<Map<String, dynamic>>> getRevenueByDay(
    String shopId, {
    int days = 7,
  }) async {
    final List allOrders = await _client
        .from('orders')
        .select('total_price, created_at')
        .eq('shop_id', shopId)
        .neq('status', 'cancelled');

    final Map<String, double> dailyRevenue = {};
    final today = DateTime.now();

    // Initialize map with 0.0 for the past X days
    for (int i = 0; i < days; i++) {
      final date = today.subtract(Duration(days: i));
      final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      dailyRevenue[dateKey] = 0.0;
    }

    for (final order in allOrders) {
      final totalPrice = (order['total_price'] as num).toDouble();
      final createdAt = DateTime.parse(order['created_at'] as String);
      final dateKey = '${createdAt.year}-${createdAt.month.toString().padLeft(2, '0')}-${createdAt.day.toString().padLeft(2, '0')}';

      if (dailyRevenue.containsKey(dateKey)) {
        dailyRevenue[dateKey] = dailyRevenue[dateKey]! + totalPrice;
      }
    }

    // Convert map to sorted list of daily records
    final List<Map<String, dynamic>> results = [];
    final sortedKeys = dailyRevenue.keys.toList()..sort();
    for (final key in sortedKeys) {
      results.add({
        'date': key,
        'revenue': dailyRevenue[key],
      });
    }

    return results;
  }
}

/// Riverpod provider for AdminRepository
final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return AdminRepositoryImpl(client);
});
