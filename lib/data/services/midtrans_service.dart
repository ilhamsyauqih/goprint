// lib/data/services/midtrans_service.dart
// Calls Midtrans via a Supabase Edge Function so the server key stays
// server-side and CORS / network issues are avoided entirely.

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MidtransService {
  // The edge function deployed at: supabase/functions/create-payment/index.ts
  static const String _functionName = 'create-payment';

  SupabaseClient get _client => Supabase.instance.client;

  /// Create a Snap transaction via the server-side edge function.
  /// Returns { 'success': true, 'token': ..., 'redirect_url': ... } on success.
  Future<Map<String, dynamic>> createTransaction({
    required String orderId,
    required int grossAmount,
    required String name,
    required String email,
    required String phone,
  }) async {
    try {
      final payload = {
        'transaction_details': {
          'order_id': orderId,
          'gross_amount': grossAmount,
        },
        'credit_card': {'secure': true},
        'customer_details': {
          'first_name': name,
          'email': email,
          'phone': phone,
        },
      };

      final response = await _client.functions.invoke(
        _functionName,
        body: {'action': 'create', 'payload': payload},
      );

      final data = response.data as Map<String, dynamic>;
      debugPrint('[MidtransService] createTransaction response: $data');
      return data;
    } catch (e, st) {
      debugPrint('[MidtransService] createTransaction error: $e\n$st');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Check transaction status via the server-side edge function.
  /// Returns true if payment is settled / captured.
  Future<bool> checkTransactionStatus(String orderId) async {
    try {
      final response = await _client.functions.invoke(
        _functionName,
        body: {'action': 'status', 'orderId': orderId},
      );

      final data = response.data as Map<String, dynamic>;
      final status = data['status'] as String?;
      debugPrint('[MidtransService] status for $orderId: $status');

      return status == 'settlement' || status == 'capture';
    } catch (e) {
      debugPrint('[MidtransService] checkTransactionStatus error: $e');
      return false;
    }
  }
}

/// Riverpod provider for MidtransService
final midtransServiceProvider = Provider<MidtransService>((ref) {
  return MidtransService();
});
