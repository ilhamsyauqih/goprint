// lib/data/repositories/order_repository_impl.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/supabase/supabase_service.dart';
import '../../domain/repositories/order_repository.dart';
import '../models/order_model.dart';

class OrderRepositoryImpl implements OrderRepository {
  final SupabaseClient _client;

  OrderRepositoryImpl(this._client);

  @override
  Future<String> createOrder(OrderModel order, List<OrderItemModel> items) async {
    // 1. Prepare order map (removing generated fields if necessary)
    final orderJson = order.toJson();
    // If the id is empty or default, let Postgres generate it
    if (order.id.isEmpty) {
      orderJson.remove('id');
    }
    orderJson.remove('order_items');
    orderJson.remove('created_at');
    orderJson.remove('updated_at');

    // 2. Insert order
    final orderData = await _client
        .from('orders')
        .insert(orderJson)
        .select('id')
        .single();
    
    final orderId = orderData['id'] as String;

    // 3. Prepare order items
    final itemsJsonList = items.map((item) {
      final itemJson = item.copyWith(orderId: orderId).toJson();
      if (item.id.isEmpty) {
        itemJson.remove('id');
      }
      return itemJson;
    }).toList();

    // 4. Insert order items
    await _client.from('order_items').insert(itemsJsonList);

    return orderId;
  }

  @override
  Future<List<OrderModel>> getUserOrders(String userId) async {
    final List data = await _client
        .from('orders')
        .select('*, order_items(*)')
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    
    return data.map((json) => OrderModel.fromJson(json)).toList();
  }

  @override
  Future<OrderModel> getOrderById(String orderId) async {
    final data = await _client
        .from('orders')
        .select('*, order_items(*)')
        .eq('id', orderId)
        .single();
    
    return OrderModel.fromJson(data);
  }

  @override
  Future<void> cancelOrder(String orderId) async {
    // A user can cancel only if the order status is 'pending'
    final response = await _client
        .from('orders')
        .update({'status': 'cancelled'})
        .eq('id', orderId)
        .eq('status', 'pending')
        .select();

    if (response.isEmpty) {
      throw Exception('Failed to cancel order: Order is not in pending state or does not exist.');
    }
  }

  @override
  Future<void> updateOrderStatus(String orderId, String status) async {
    await _client
        .from('orders')
        .update({'status': status})
        .eq('id', orderId);
  }
}

/// Riverpod provider for OrderRepository
final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return OrderRepositoryImpl(client);
});
