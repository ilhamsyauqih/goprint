import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../orders/data/order_model.dart';
import 'reject_reason_dialog.dart';

class PaymentVerificationSection extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onUpdate;

  const PaymentVerificationSection({
    required this.order,
    required this.onUpdate,
    super.key,
  });

  void _showFullscreenProof(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(10),
        child: Stack(
          alignment: Alignment.center,
          children: [
            InteractiveViewer(
              panEnabled: true,
              minScale: 0.5,
              maxScale: 4,
              child: _buildProofImage(context, fit: BoxFit.contain),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: CircleAvatar(
                backgroundColor: Colors.black.withValues(alpha: 0.5),
                child: IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProofImage(BuildContext context, {BoxFit fit = BoxFit.cover}) {
    final path = order.paymentProofPath;
    if (path == null || path.isEmpty) {
      return Container(
        color: Theme.of(context).brightness == Brightness.dark 
            ? AppColors.darkElevated 
            : Colors.grey.shade200,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_not_supported_rounded,
              size: 40,
              color: Theme.of(context).brightness == Brightness.dark 
                  ? AppColors.darkMutedText 
                  : Colors.grey.shade400,
            ),
            const SizedBox(height: 8),
            Text(
              'Bukti Transfer Belum Diunggah',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).brightness == Brightness.dark 
                    ? AppColors.darkMutedText 
                    : Colors.grey.shade500,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    if (path.startsWith('assets/')) {
      // asset mock image
      return Image.asset(
        path,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => const Center(
          child: Icon(Icons.broken_image_rounded, size: 40, color: Colors.red),
        ),
      );
    } else {
      // network mock or external image
      return Image.network(
        path,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => const Center(
          child: Icon(Icons.broken_image_rounded, size: 40, color: Colors.red),
        ),
      );
    }
  }

  void _approvePayment(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve Pembayaran'),
        content: Text('Apakah Anda yakin ingin memverifikasi pembayaran untuk pesanan ${order.orderNumber}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              order.paymentStatus = 'Terverifikasi';
              order.status = OrderStatus.confirmed; // Update to confirmed
              onUpdate();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Pembayaran pesanan ${order.orderNumber} berhasil terverifikasi!'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).brightness == Brightness.dark 
                  ? AppColors.successDark 
                  : AppColors.success,
            ),
            child: const Text('Ya, Approve'),
          ),
        ],
      ),
    );
  }

  void _rejectPayment(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => RejectReasonDialog(
        orderNumber: order.orderNumber,
        onSubmitted: (reason) {
          order.paymentStatus = 'Gagal';
          order.status = OrderStatus.cancelled;
          order.rejectReason = reason;
          onUpdate();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Pembayaran pesanan ${order.orderNumber} ditolak.'),
              backgroundColor: AppColors.error,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final hasProof = order.paymentProofPath != null && order.paymentProofPath!.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Verifikasi Pembayaran (${order.paymentMethod})',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          // Detail Status Pembayaran
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Status Pembayaran:',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark ? AppColors.darkMutedText : AppColors.lightSubtleText,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: order.paymentStatus == 'Terverifikasi'
                      ? AppColors.success.withValues(alpha: isDark ? 0.15 : 0.08)
                      : (order.paymentStatus == 'Menunggu Verifikasi'
                          ? AppColors.warning.withValues(alpha: isDark ? 0.15 : 0.08)
                          : AppColors.error.withValues(alpha: isDark ? 0.15 : 0.08)),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  order.paymentStatus,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: order.paymentStatus == 'Terverifikasi'
                        ? (isDark ? AppColors.successDark : AppColors.success)
                        : (order.paymentStatus == 'Menunggu Verifikasi'
                            ? (isDark ? AppColors.warningDark : AppColors.warning)
                            : (isDark ? AppColors.errorDark : AppColors.error)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Preview Bukti Transfer
          if (order.paymentMethod == 'Transfer') ...[
            Text(
              'Bukti Transfer:',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: hasProof ? () => _showFullscreenProof(context) : null,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: _buildProofImage(context),
                      ),
                      if (hasProof)
                        Positioned(
                          right: 8,
                          bottom: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.zoom_in_rounded, color: Colors.white, size: 14),
                                SizedBox(width: 4),
                                Text(
                                  'Perbesar',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Tombol Approve / Reject (Hanya jika status 'Menunggu Verifikasi')
          if (order.paymentStatus == 'Menunggu Verifikasi')
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _rejectPayment(context),
                    icon: const Icon(Icons.close_rounded, size: 16),
                    label: const Text('Reject'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error, width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _approvePayment(context),
                    icon: const Icon(Icons.check_rounded, size: 16),
                    label: const Text('Approve'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? AppColors.teal300 : AppColors.teal700,
                      foregroundColor: isDark ? AppColors.teal900 : Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
