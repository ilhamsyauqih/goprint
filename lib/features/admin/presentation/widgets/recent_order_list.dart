import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../orders/data/order_flow_manager.dart';
import '../../../orders/presentation/widgets/status_badge.dart';

/// Daftar pesanan terbaru dasbor admin (RecentOrderList) yang memuat status real-time.
class RecentOrderList extends StatelessWidget {
  const RecentOrderList({super.key});

  String _formatCurrency(int value) {
    return 'Rp ${value.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => "${m[1]}.")}';
  }

  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Mengambil data pesanan real-time dari singleton OrderFlowManager
    final orders = OrderFlowManager.instance.orders;
    final recentOrders = orders.take(5).toList();

    return Container(
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pesanan Terbaru',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '5 Teratas',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: isDark ? AppColors.teal300 : AppColors.teal700,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (recentOrders.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'Belum ada pesanan masuk',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark ? AppColors.darkMutedText : AppColors.lightSubtleText,
                  ),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recentOrders.length,
              separatorBuilder: (context, index) => const Divider(height: 20),
              itemBuilder: (context, index) {
                final order = recentOrders[index];
                return InkWell(
                  onTap: () {
                    context.push('/admin/orders/${order.orderNumber}');
                  },
                  child: Row(
                    children: [
                      // Indikator berkas cetakan di sebelah kiri
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkElevated : Colors.grey.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.description_rounded,
                          color: isDark ? AppColors.teal300 : AppColors.teal700,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  order.orderNumber,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  _formatTime(order.date),
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: isDark ? AppColors.darkMutedText : AppColors.lightSubtleText,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${order.customerName} · ${order.uploadedFiles.length} berkas',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: isDark ? AppColors.darkMutedText : AppColors.lightSubtleText,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  _formatCurrency(order.totalFee),
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? AppColors.teal300 : AppColors.teal700,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Badge status pesanan real-time
                            StatusBadge(status: order.status),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
