import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../../../core/theme/app_theme.dart';

class OrderTimeline extends StatelessWidget {
  final Order order;

  const OrderTimeline({
    super.key,
    required this.order,
  });

  // Helper to format time
  String _formatTime(DateTime? date) {
    if (date == null) return '';
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  // Helper to format date
  String _formatDate(DateTime? date) {
    if (date == null) return '';
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Define standard milestones for the order tracking process
    final isDelivery = order.deliveryType.toLowerCase().contains('kirim') || 
                        order.deliveryType.toLowerCase().contains('delivery');
    
    final List<Map<String, dynamic>> milestones = [
      {
        'status': 'pending',
        'title': 'Pesanan Dibuat',
        'desc': 'Pesanan berhasil dibuat, menunggu konfirmasi.',
      },
      {
        'status': 'confirmed',
        'title': 'Pembayaran Berhasil',
        'desc': 'Pembayaran terverifikasi dan masuk antrean cetak.',
      },
      {
        'status': 'processing',
        'title': 'Sedang Dicetak',
        'desc': 'Dokumen Anda sedang diproses oleh operator.',
      },
      {
        'status': 'ready',
        'title': isDelivery ? 'Dalam Pengiriman' : 'Siap Diambil',
        'desc': isDelivery 
            ? 'Kurir sedang mengantarkan dokumen ke alamat Anda.' 
            : 'Cetakan selesai. Silakan ambil di toko.',
      },
      {
        'status': 'completed',
        'title': 'Pesanan Selesai',
        'desc': 'Dokumen telah diterima dengan baik.',
      },
    ];

    // If order is cancelled, replace the completed step or insert a cancelled step
    final isCancelled = order.status == 'cancelled';
    if (isCancelled) {
      // Find where cancellation fits: usually right after the latest completed step.
      // For simplicity, we keep standard flow and replace the last step, or show pending -> cancelled.
    }

    // Determine status index helper
    int getStatusWeight(String status) {
      switch (status.toLowerCase()) {
        case 'pending': return 0;
        case 'confirmed': return 1;
        case 'processing': return 2;
        case 'ready': return 3;
        case 'completed': return 4;
        case 'cancelled': return 99; // Special handling
        default: return -1;
      }
    }

    final currentWeight = getStatusWeight(order.status);

    return Container(
      padding: const EdgeInsets.all(20),
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
          Text(
            'Status Pengiriman & Cetak',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          
          if (isCancelled) ...[
            // Simplified timeline for cancelled orders
            _buildTimelineItem(
              context: context,
              title: 'Pesanan Dibuat',
              description: 'Pesanan Anda telah berhasil dibuat.',
              time: _formatTime(order.date),
              date: _formatDate(order.date),
              isCompleted: true,
              isActive: false,
              isFirst: true,
              isLast: false,
            ),
            _buildTimelineItem(
              context: context,
              title: 'Pesanan Dibatalkan',
              description: order.timeline.firstWhere(
                (e) => e.status == 'cancelled',
                orElse: () => OrderTimelineEvent(status: 'cancelled', title: 'Dibatalkan', description: 'Pesanan dibatalkan.'),
              ).description,
              time: _formatTime(order.timeline.firstWhere((e) => e.status == 'cancelled', orElse: () => order.timeline.last).timestamp ?? order.date),
              date: _formatDate(order.timeline.firstWhere((e) => e.status == 'cancelled', orElse: () => order.timeline.last).timestamp ?? order.date),
              isCompleted: true,
              isActive: true,
              isCancelled: true,
              isFirst: false,
              isLast: true,
            ),
          ] else ...[
            // Standard tracking flow
            for (int i = 0; i < milestones.length; i++) ...[
              (() {
                final milestone = milestones[i];
                final mStatus = milestone['status'] as String;
                final mWeight = getStatusWeight(mStatus);
                
                final isCompleted = mWeight <= currentWeight;
                final isActive = mWeight == currentWeight;
                
                // Try to find actual event matching this status to get real timestamp & custom desc
                final actualEventIndex = order.timeline.indexWhere((e) => e.status == mStatus);
                final actualEvent = actualEventIndex != -1 ? order.timeline[actualEventIndex] : null;
                
                final String title = actualEvent?.title ?? milestone['title'];
                final String desc = actualEvent?.description ?? milestone['desc'];
                final String time = actualEvent != null ? _formatTime(actualEvent.timestamp) : '';
                final String date = actualEvent != null ? _formatDate(actualEvent.timestamp) : '';

                return _buildTimelineItem(
                  context: context,
                  title: title,
                  description: desc,
                  time: time,
                  date: date,
                  isCompleted: isCompleted,
                  isActive: isActive,
                  isFirst: i == 0,
                  isLast: i == milestones.length - 1,
                );
              }()),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildTimelineItem({
    required BuildContext context,
    required String title,
    required String description,
    required String time,
    required String date,
    required bool isCompleted,
    required bool isActive,
    bool isCancelled = false,
    required bool isFirst,
    required bool isLast,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Choose bullet color/style
    Color bulletColor;
    if (isCancelled) {
      bulletColor = AppColors.statusCancelled;
    } else if (isActive) {
      bulletColor = AppColors.primary;
    } else if (isCompleted) {
      bulletColor = AppColors.primary;
    } else {
      bulletColor = isDark ? AppColors.borderDark : AppColors.border;
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time details column (Left)
          SizedBox(
            width: 48,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (isCompleted && time.isNotEmpty) ...[
                  Text(
                    time,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    date,
                    style: TextStyle(
                      fontSize: 10,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          
          // Stepper line and bullet column (Center)
          Column(
            children: [
              // Point Indicator
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: isActive ? 20 : 12,
                height: isActive ? 20 : 12,
                decoration: BoxDecoration(
                  color: isActive 
                      ? (isCancelled ? AppColors.statusCancelled.withOpacity(0.2) : AppColors.primary.withOpacity(0.2)) 
                      : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Container(
                    width: isActive ? 10 : 8,
                    height: isActive ? 10 : 8,
                    decoration: BoxDecoration(
                      color: bulletColor,
                      shape: BoxShape.circle,
                      boxShadow: isActive ? [
                        BoxShadow(
                          color: bulletColor.withOpacity(0.4),
                          blurRadius: 6,
                          spreadRadius: 2,
                        )
                      ] : null,
                    ),
                  ),
                ),
              ),
              
              // Vertical Connector Line
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          bulletColor,
                          // If next milestone is completed, paint it teal, otherwise fade to grey
                          isCompleted && !isActive 
                              ? AppColors.primary 
                              : (isDark ? AppColors.borderDark : AppColors.border)
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          
          // Details column (Right)
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: isLast ? 0 : 20.0,
                top: isActive ? 0 : 2.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isActive || isCompleted ? FontWeight.bold : FontWeight.w500,
                      color: isActive 
                          ? (isCancelled ? AppColors.statusCancelled : AppColors.primary)
                          : (isCompleted 
                              ? (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)
                              : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary)),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.4,
                      color: isCompleted 
                          ? (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary)
                          : (isDark ? AppColors.borderDark : AppColors.textSecondary.withOpacity(0.7)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
