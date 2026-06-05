import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../orders/data/order_model.dart';
import '../../../orders/presentation/widgets/status_badge.dart';

class AdminOrderCard extends StatelessWidget {
  final OrderModel order;

  const AdminOrderCard({required this.order, super.key});

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
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
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
            context.push('/admin/orders/${order.orderNumber}');
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Order Number & Date
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
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24, thickness: 1),

                // Customer Info Row
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: isDark 
                          ? AppColors.teal800.withValues(alpha: 0.2)
                          : AppColors.teal700.withValues(alpha: 0.08),
                      child: Icon(
                        Icons.person_rounded,
                        color: isDark ? AppColors.teal300 : AppColors.teal700,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.customerName,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            order.customerPhone,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: isDark ? AppColors.darkMutedText : AppColors.lightSubtleText,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Delivery Type Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: order.deliveryType == 'delivery'
                            ? Colors.orange.shade50.withValues(alpha: isDark ? 0.15 : 0.8)
                            : Colors.blue.shade50.withValues(alpha: isDark ? 0.15 : 0.8),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: order.deliveryType == 'delivery'
                              ? Colors.orange.shade300.withValues(alpha: 0.3)
                              : Colors.blue.shade300.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            order.deliveryType == 'delivery'
                                ? Icons.local_shipping_rounded
                                : Icons.directions_walk_rounded,
                            size: 12,
                            color: order.deliveryType == 'delivery'
                                ? (isDark ? Colors.orange.shade300 : Colors.orange.shade800)
                                : (isDark ? Colors.blue.shade300 : Colors.blue.shade800),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            order.deliveryType == 'delivery' ? 'Antar' : 'Ambil',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: order.deliveryType == 'delivery'
                                  ? (isDark ? Colors.orange.shade300 : Colors.orange.shade800)
                                  : (isDark ? Colors.blue.shade300 : Colors.blue.shade800),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Order Content Brief
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.description_rounded,
                      color: isDark ? AppColors.darkMutedText : Colors.grey.shade400,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        order.uploadedFiles.isNotEmpty
                            ? order.uploadedFiles.map((f) => '${f.name} (${f.copies}x)').join(', ')
                            : 'Tidak ada berkas',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 13,
                          color: isDark ? AppColors.darkMutedText : Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Payment Method Brief
                Row(
                  children: [
                    Icon(
                      Icons.payment_rounded,
                      color: isDark ? AppColors.darkMutedText : Colors.grey.shade400,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${order.paymentMethod} · ${order.paymentStatus}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: order.paymentStatus == 'Terverifikasi'
                            ? (isDark ? AppColors.successDark : AppColors.success)
                            : (order.paymentStatus == 'Menunggu Verifikasi'
                                ? (isDark ? AppColors.warningDark : AppColors.warning)
                                : (isDark ? AppColors.errorDark : AppColors.error)),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24, thickness: 1),

                // Footer: StatusBadge & Total Fee
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    StatusBadge(status: order.status),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Total Pendapatan',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: isDark ? AppColors.darkMutedText : AppColors.lightSubtleText,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatCurrency(order.totalFee),
                          style: theme.textTheme.titleMedium?.copyWith(
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
