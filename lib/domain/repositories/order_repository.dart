// lib/domain/repositories/order_repository.dart

import '../../data/models/order_model.dart';

abstract class OrderRepository {
  /// Create a new order with its items, returning the created order ID
  Future<String> createOrder(OrderModel order, List<OrderItemModel> items);

  /// Fetch all orders placed by a specific user
  Future<List<OrderModel>> getUserOrders(String userId);

  /// Fetch details of a specific order by ID, including items
  Future<OrderModel> getOrderById(String orderId);

  /// Cancel a pending order
  Future<void> cancelOrder(String orderId);

  /// Update the status of an order (e.g. pending -> confirmed -> processing -> etc)
  Future<void> updateOrderStatus(String orderId, String status);
}
