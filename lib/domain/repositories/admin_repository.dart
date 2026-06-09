// lib/domain/repositories/admin_repository.dart

import '../../data/models/order_model.dart';

abstract class AdminRepository {
  /// Fetch all orders placed at a specific shop, optionally filtered by status
  Future<List<OrderModel>> getShopOrders(String shopId, {String? status});

  /// Verify a customer payment, updating payment status to verified or rejected
  Future<void> verifyPayment(String orderId, String paymentStatus);

  /// Retrieve high-level daily statistics for a specific shop
  Future<Map<String, dynamic>> getShopStats(String shopId);

  /// Fetch daily revenue data for a given number of past days (e.g. 7 or 30 days)
  Future<List<Map<String, dynamic>>> getRevenueByDay(
    String shopId, {
    int days = 7,
  });
}
