import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/order_model.dart';

/// Seksi informasi pembayaran, status verifikasi, dan rincian biaya (Payment Info Section).
class PaymentInfoSection extends StatelessWidget {
  final OrderModel order;

  const PaymentInfoSection({required this.order, super.key});

  String _formatCurrency(int value) {
    return 'Rp ${value.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => "${m[1]}.")}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Hitung subtotal dokumen (total dikurangi biaya kirim)
    final itemSubtotal = order.totalFee - order.deliveryFee;

    // Tentukan warna teks status verifikasi
    Color verificationColor;
    if (order.paymentStatus == 'Terverifikasi') {
      verificationColor = isDark ? AppColors.successDark : AppColors.success;
    } else if (order.paymentStatus == 'Menunggu Verifikasi') {
      verificationColor = isDark ? AppColors.warningDark : AppColors.warning;
    } else {
      verificationColor = isDark ? AppColors.errorDark : AppColors.error;
    }

    return Container(
      padding: const EdgeInsets.all(18),
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
            'Informasi Pembayaran & Pengiriman',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          // Baris: Metode Pembayaran
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Metode Pembayaran',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark ? AppColors.darkMutedText : AppColors.lightSubtleText,
                ),
              ),
              Row(
                children: [
                  Icon(
                    order.paymentMethod == 'QRIS'
                        ? Icons.qr_code_2_rounded
                        : order.paymentMethod == 'Transfer'
                            ? Icons.account_balance_rounded
                            : Icons.payments_rounded,
                    size: 16,
                    color: isDark ? AppColors.teal300 : AppColors.teal700,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    order.paymentMethod,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Baris: Status Verifikasi Pembayaran
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Status Verifikasi',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark ? AppColors.darkMutedText : AppColors.lightSubtleText,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: verificationColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: verificationColor.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  order.paymentStatus,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: verificationColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 24, thickness: 1),
          // Baris: Metode Pengambilan & Alamat (jika Pengantaran)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Metode Pengambilan',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark ? AppColors.darkMutedText : AppColors.lightSubtleText,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    order.deliveryType == 'delivery' ? 'Antar Alamat (Delivery)' : 'Ambil Sendiri (Pickup)',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (order.deliveryType == 'delivery' && order.deliveryAddress != null) ...[
                    const SizedBox(height: 4),
                    SizedBox(
                      width: 180,
                      child: Text(
                        order.deliveryAddress!,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: isDark ? AppColors.darkMutedText : AppColors.lightSubtleText,
                          height: 1.3,
                        ),
                        textAlign: TextAlign.end,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          const Divider(height: 24, thickness: 1),
          // Rincian Biaya Cetak dan Pengiriman
          _buildPriceRow('Subtotal Dokumen', _formatCurrency(itemSubtotal), isDark, theme),
          if (order.deliveryType == 'delivery')
            _buildPriceRow('Ongkos Kirim', _formatCurrency(order.deliveryFee), isDark, theme),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Pembayaran',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                _formatCurrency(order.totalFee),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: isDark ? AppColors.teal300 : AppColors.teal700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, bool isDark, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? AppColors.darkMutedText : AppColors.lightSubtleText,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
