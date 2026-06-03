import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../../../core/theme/app_theme.dart';

class PaymentInfoSection extends StatelessWidget {
  final Order order;

  const PaymentInfoSection({
    super.key,
    required this.order,
  });

  // Rupiah formatting helper
  String _formatRupiah(double value) {
    String money = value.toInt().toString();
    String result = '';
    int count = 0;
    for (int i = money.length - 1; i >= 0; i--) {
      result = money[i] + result;
      count++;
      if (count % 3 == 0 && i != 0) {
        result = '.$result';
      }
    }
    return 'Rp $result';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Calculate breakdown values
    final printingSubtotal = order.items.fold<double>(0, (sum, item) => sum + item.subtotal);
    const serviceFee = 2000.0;
    
    final isDelivery = order.deliveryType.toLowerCase().contains('kirim') || 
                        order.deliveryType.toLowerCase().contains('delivery');
    final deliveryFee = isDelivery ? 10000.0 : 0.0;
    
    // Calculate promo discount if total mock price differs from printingSubtotal + serviceFee + deliveryFee
    final expectedTotal = printingSubtotal + serviceFee + deliveryFee;
    final double discount = expectedTotal > order.totalPrice ? expectedTotal - order.totalPrice : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Text(
            'Informasi Pembayaran',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Payment Method Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Metode Pembayaran',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                ),
              ),
              Text(
                order.paymentMethod,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Verification Status Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Status Verifikasi',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                ),
              ),
              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: order.isPaymentVerified
                      ? AppColors.statusCompleted.withOpacity(0.1)
                      : AppColors.statusPending.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: order.isPaymentVerified
                        ? AppColors.statusCompleted.withOpacity(0.2)
                        : AppColors.statusPending.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      order.isPaymentVerified
                          ? Icons.check_circle_outline_rounded
                          : Icons.pending_actions_rounded,
                      color: order.isPaymentVerified
                          ? AppColors.statusCompleted
                          : AppColors.statusPending,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      order.isPaymentVerified ? 'Terverifikasi' : 'Menunggu Verifikasi',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: order.isPaymentVerified
                            ? AppColors.statusCompleted
                            : AppColors.statusPending,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14.0),
            child: Divider(
              height: 1,
              thickness: 1,
              color: AppColors.border,
            ),
          ),
          
          // Price Summary Breakdown
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Subtotal Cetak',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                ),
              ),
              Text(
                _formatRupiah(printingSubtotal),
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Biaya Layanan',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                ),
              ),
              Text(
                _formatRupiah(serviceFee),
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          if (isDelivery) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Ongkos Kirim',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                  ),
                ),
                Text(
                  _formatRupiah(deliveryFee),
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          
          if (discount > 0) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Promo Diskon',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.statusCompleted,
                  ),
                ),
                Text(
                  '-${_formatRupiah(discount)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.statusCompleted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Pembayaran',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                _formatRupiah(order.totalPrice),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.primaryLight : AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
