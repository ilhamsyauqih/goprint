import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/order_model.dart';
import 'status_badge.dart';

/// Kartu item pesanan (Order Card) untuk daftar pesanan.
class OrderCard extends StatelessWidget {
  final OrderModel order;

  const OrderCard({required this.order, super.key});

  String _formatCurrency(int value) {
    return 'Rp ${value.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => "${m[1]}.")}';
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agt', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    final day = date.day.toString().padLeft(2, '0');
    final month = months[date.month - 1];
    final year = date.year;
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day $month $year, $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.1 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () {
            // Navigasi ke detail pesanan dengan GoRouter
            context.push('/orders/${order.orderNumber}');
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Nomor Pesanan & Tanggal
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      order.orderNumber,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: isDark ? AppColors.teal300 : AppColors.teal700,
                      ),
                    ),
                    Text(
                      _formatDate(order.date),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: isDark ? AppColors.darkMutedText : AppColors.lightSubtleText,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24, thickness: 1),
                // Body: Nama Toko, Gambar, & Detail Ringkas
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Gambar Toko
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        order.shop.imageUrl,
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 48,
                          height: 48,
                          color: isDark ? AppColors.darkElevated : AppColors.lightSurface,
                          child: const Icon(Icons.storefront_rounded, size: 24),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.shop.name,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            order.uploadedFiles.isNotEmpty
                                ? '${order.uploadedFiles.length} Berkas · ${order.uploadedFiles.fold(0, (sum, f) => sum + f.copies)} Total Cetak'
                                : '0 Berkas',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: isDark ? AppColors.darkMutedText : AppColors.lightSubtleText,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Footer: Status Badge & Total Biaya
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    StatusBadge(status: order.status),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Total Pembayaran',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: isDark ? AppColors.darkMutedText : AppColors.lightSubtleText,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatCurrency(order.totalFee),
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: isDark ? AppColors.teal300 : AppColors.teal700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
