import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../orders/data/order_model.dart';
import 'reject_reason_dialog.dart';
import 'set_estimate_dialog.dart';

class AdminActionButtons extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onUpdate;

  const AdminActionButtons({
    required this.order,
    required this.onUpdate,
    super.key,
  });

  void _processOrder(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => SetEstimateDialog(
        orderNumber: order.orderNumber,
        onSubmitted: (estimate) {
          order.status = OrderStatus.processing;
          order.estimatedCompletionTime = estimate;
          // Auto verifikasi pembayaran jika belum
          if (order.paymentStatus == 'Menunggu Verifikasi') {
            order.paymentStatus = 'Terverifikasi';
          }
          onUpdate();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Pesanan ${order.orderNumber} mulai diproses dengan estimasi $estimate.'),
              backgroundColor: AppColors.success,
            ),
          );
        },
      ),
    );
  }

  void _rejectOrder(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => RejectReasonDialog(
        orderNumber: order.orderNumber,
        onSubmitted: (reason) {
          order.status = OrderStatus.cancelled;
          order.paymentStatus = 'Gagal';
          order.rejectReason = reason;
          onUpdate();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Pesanan ${order.orderNumber} berhasil ditolak.'),
              backgroundColor: AppColors.error,
            ),
          );
        },
      ),
    );
  }

  void _markAsReady(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tandai Siap Diambil'),
        content: Text(
          order.deliveryType == 'delivery'
              ? 'Tandai bahwa pesanan sudah selesai dicetak dan siap dikirim ke alamat pelanggan?'
              : 'Tandai bahwa pesanan sudah selesai dicetak dan siap diambil oleh pelanggan?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              order.status = OrderStatus.ready;
              onUpdate();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    order.deliveryType == 'delivery'
                        ? 'Pesanan ${order.orderNumber} siap dikirim!'
                        : 'Pesanan ${order.orderNumber} siap diambil!',
                  ),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).brightness == Brightness.dark 
                  ? AppColors.teal300 
                  : AppColors.teal700,
            ),
            child: const Text('Ya, Siap'),
          ),
        ],
      ),
    );
  }

  void _markAsCompleted(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tandai Selesai'),
        content: const Text('Tandai bahwa pesanan ini telah selesai diterima oleh pelanggan?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              order.status = OrderStatus.completed;
              order.paymentStatus = 'Terverifikasi'; // Set payment to success if cash/etc.
              onUpdate();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Pesanan ${order.orderNumber} dinyatakan selesai.'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).brightness == Brightness.dark 
                  ? AppColors.successDark 
                  : AppColors.success,
            ),
            child: const Text('Ya, Selesai'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    switch (order.status) {
      case OrderStatus.pending:
      case OrderStatus.confirmed:
        return Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _rejectOrder(context),
                icon: const Icon(Icons.cancel_outlined, size: 18),
                label: const Text('Tolak Pesanan'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error, width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _processOrder(context),
                icon: const Icon(Icons.print_rounded, size: 18),
                label: const Text('Proses Pesanan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? AppColors.teal300 : AppColors.teal700,
                  foregroundColor: isDark ? AppColors.teal900 : Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        );
      case OrderStatus.processing:
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _markAsReady(context),
            icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
            label: Text(
              order.deliveryType == 'delivery'
                  ? 'Siap Dikirim'
                  : 'Siap Diambil',
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? AppColors.teal300 : AppColors.teal700,
              foregroundColor: isDark ? AppColors.teal900 : Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
          ),
        );
      case OrderStatus.ready:
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _markAsCompleted(context),
            icon: const Icon(Icons.assignment_turned_in_rounded, size: 18),
            label: const Text('Selesaikan Pesanan'),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? AppColors.successDark : AppColors.success,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
          ),
        );
      case OrderStatus.completed:
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark 
                ? AppColors.successDark.withValues(alpha: 0.1)
                : AppColors.success.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: (isDark ? AppColors.successDark : AppColors.success).withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.check_circle_rounded,
                color: isDark ? AppColors.successDark : AppColors.success,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Pesanan selesai dikerjakan dan diterima pelanggan.',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.successDark : AppColors.success,
                  ),
                ),
              ),
            ],
          ),
        );
      case OrderStatus.cancelled:
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark 
                ? AppColors.errorDark.withValues(alpha: 0.1)
                : AppColors.error.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: (isDark ? AppColors.errorDark : AppColors.error).withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.cancel_rounded,
                    color: isDark ? AppColors.errorDark : AppColors.error,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Pesanan Dibatalkan/Ditolak',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.errorDark : AppColors.error,
                    ),
                  ),
                ],
              ),
              if (order.rejectReason != null && order.rejectReason!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'Alasan: ${order.rejectReason}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppColors.darkMutedText : Colors.grey.shade700,
                  ),
                ),
              ],
            ],
          ),
        );
    }
  }
}
