import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../widgets/status_badge.dart';
import '../widgets/order_timeline.dart';
import '../widgets/order_item_detail_card.dart';
import '../widgets/payment_info_section.dart';
import '../../../core/theme/app_theme.dart';

class OrderDetailScreen extends StatefulWidget {
  final Order order;

  const OrderDetailScreen({
    super.key,
    required this.order,
  });

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  late Order _currentOrder;
  bool _showDevTools = false;

  @override
  void initState() {
    super.initState();
    _currentOrder = widget.order;
  }

  // Helper to format date
  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    final day = date.day.toString().padLeft(2, '0');
    final month = months[date.month - 1];
    final year = date.year;
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    
    return '$day $month $year, $hour:$minute';
  }

  // Cancel order logic
  void _cancelOrder() {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Batalkan Pesanan?'),
          content: const Text(
            'Apakah Anda yakin ingin membatalkan pesanan ini? Tindakan ini tidak dapat dibatalkan.'
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Kembali', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx); // Close dialog
                
                setState(() {
                  // Add cancelled event to timeline
                  final updatedTimeline = List<OrderTimelineEvent>.from(_currentOrder.timeline);
                  updatedTimeline.add(
                    OrderTimelineEvent(
                      status: 'cancelled',
                      title: 'Dibatalkan',
                      description: 'Pesanan dibatalkan oleh pengguna.',
                      timestamp: DateTime.now(),
                    ),
                  );

                  _currentOrder = _currentOrder.copyWith(
                    status: 'cancelled',
                    timeline: updatedTimeline,
                  );
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Pesanan berhasil dibatalkan.'),
                    backgroundColor: AppColors.statusCancelled,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.statusCancelled,
                foregroundColor: Colors.white,
              ),
              child: const Text('Ya, Batalkan'),
            ),
          ],
        );
      },
    );
  }

  // Trigger Review logic
  void _giveReview() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Navigasi ke halaman tulis ulasan (R2 - Ulasan & Rating)'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Dev tools to change status dynamically
  void _simulateStatusChange(String newStatus) {
    setState(() {
      final updatedTimeline = List<OrderTimelineEvent>.from(_currentOrder.timeline);
      
      // Clean existing future milestone triggers if moving backwards
      if (newStatus == 'pending') {
        updatedTimeline.removeWhere((e) => e.status != 'pending');
      } else {
        // Simple mapping to append events sequentially
        final statuses = ['pending', 'confirmed', 'processing', 'ready', 'completed'];
        final targetIndex = statuses.indexOf(newStatus);
        
        // Remove existing events that weight higher than target status
        updatedTimeline.removeWhere((e) => e.status == 'cancelled' || statuses.indexOf(e.status) > targetIndex);

        // Add missing events
        for (int i = 1; i <= targetIndex; i++) {
          final s = statuses[i];
          if (!updatedTimeline.any((e) => e.status == s)) {
            String title = '';
            String desc = '';
            switch (s) {
              case 'confirmed':
                title = 'Pembayaran Berhasil';
                desc = 'Pembayaran terverifikasi, menunggu antrean.';
                break;
              case 'processing':
                title = 'Sedang Dicetak';
                desc = 'Dokumen sedang diproses oleh operator.';
                break;
              case 'ready':
                title = _currentOrder.deliveryType.toLowerCase().contains('kirim') ? 'Dalam Pengiriman' : 'Siap Diambil';
                desc = _currentOrder.deliveryType.toLowerCase().contains('kirim')
                    ? 'Kurir sedang mengantarkan dokumen Anda.'
                    : 'Dokumen siap diambil di toko.';
                break;
              case 'completed':
                title = 'Pesanan Selesai';
                desc = 'Dokumen telah diterima dengan baik.';
                break;
            }
            updatedTimeline.add(
              OrderTimelineEvent(
                status: s,
                title: title,
                description: desc,
                timestamp: DateTime.now().subtract(Duration(minutes: (targetIndex - i) * 5)),
              ),
            );
          }
        }
      }

      _currentOrder = _currentOrder.copyWith(
        status: newStatus,
        timeline: updatedTimeline,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final status = _currentOrder.status.toLowerCase();
    final showCancelButton = status == 'pending';
    final showReviewButton = status == 'completed';

    return WillPopScope(
      onWillPop: () async {
        // Return updated order back to the list screen
        Navigator.pop(context, _currentOrder);
        return false;
      },
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Container(
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
            ),
            child: AppBar(
              title: Text(
                _currentOrder.shopName,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                onPressed: () => Navigator.pop(context, _currentOrder),
              ),
              actions: [
                IconButton(
                  tooltip: 'Simulasi Status (Dev)',
                  icon: Icon(
                    _showDevTools ? Icons.developer_mode_rounded : Icons.construction_rounded,
                    color: _showDevTools ? Colors.amber : Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      _showDevTools = !_showDevTools;
                    });
                  },
                )
              ],
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Developer Simulation Control Panel
              if (_showDevTools) _buildDevControlPanel(),
              
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Order Summary Header
                    _buildOrderHeader(isDark),
                    const SizedBox(height: 16),
                    
                    // Stepper Timeline
                    OrderTimeline(order: _currentOrder),
                    const SizedBox(height: 16),
                    
                    // Delivery / Pickup Address Section
                    _buildAddressSection(isDark),
                    const SizedBox(height: 16),
                    
                    // Document Items List Header
                    Padding(
                      padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
                      child: Text(
                        'Rincian Dokumen',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    
                    // Document Cards
                    ..._currentOrder.items.map((item) => OrderItemDetailCard(item: item)),
                    const SizedBox(height: 16),
                    
                    // Payment Details
                    PaymentInfoSection(order: _currentOrder),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        // Floating Bottom Navigation for Actions
        bottomNavigationBar: (showCancelButton || showReviewButton)
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : AppColors.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -4),
                    )
                  ],
                  border: Border(
                    top: BorderSide(
                      color: isDark ? AppColors.borderDark : AppColors.border,
                      width: 1,
                    ),
                  ),
                ),
                child: SafeArea(
                  child: Row(
                    children: [
                      if (showCancelButton)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _cancelOrder,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.statusCancelled,
                              side: const BorderSide(color: AppColors.statusCancelled, width: 1.5),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Batalkan Pesanan',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ),
                        ),
                      if (showReviewButton)
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                )
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: _giveReview,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Beri Ulasan',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildDevControlPanel() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.12),
        border: Border(
          bottom: BorderSide(color: Colors.amber.withOpacity(0.4), width: 1.5),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.construction_rounded, color: Colors.amber, size: 16),
              const SizedBox(width: 8),
              Text(
                'SIMULATOR STATUS PESANAN (DEV)',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber.shade900,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildDevButton('pending', 'Pending'),
                _buildDevButton('confirmed', 'Confirm'),
                _buildDevButton('processing', 'Process'),
                _buildDevButton('ready', 'Ready'),
                _buildDevButton('completed', 'Complete'),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDevButton(String code, String label) {
    final isActive = _currentOrder.status == code;
    return Padding(
      padding: const EdgeInsets.only(right: 6.0),
      child: ChoiceChip(
        label: Text(label, style: const TextStyle(fontSize: 11)),
        selected: isActive,
        onSelected: (selected) {
          if (selected) _simulateStatusChange(code);
        },
        selectedColor: Colors.amber,
        labelStyle: TextStyle(
          color: isActive ? Colors.black : Colors.amber.shade900,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildOrderHeader(bool isDark) {
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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nomor Pesanan',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _currentOrder.orderNumber,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
              StatusBadge(status: _currentOrder.status),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12.0),
            child: Divider(height: 1, thickness: 0.5, color: AppColors.border),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tanggal Transaksi',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(_currentOrder.date),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Tipe Pesanan',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _currentOrder.deliveryType.split('(').first.trim(),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddressSection(bool isDark) {
    final isDelivery = _currentOrder.deliveryType.toLowerCase().contains('kirim') || 
                        _currentOrder.deliveryType.toLowerCase().contains('delivery');
    
    final sectionTitle = isDelivery ? 'Alamat Pengiriman' : 'Lokasi Pengambilan Toko';
    final addressText = isDelivery ? (_currentOrder.deliveryAddress ?? '-') : _currentOrder.shopAddress;
    final icon = isDelivery ? Icons.local_shipping_rounded : Icons.store_mall_directory_rounded;

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
          Row(
            children: [
              Icon(
                icon,
                color: AppColors.primary,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                sectionTitle,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            isDelivery ? 'Penerima: User GoPrint' : _currentOrder.shopName,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            addressText,
            style: TextStyle(
              fontSize: 12,
              height: 1.4,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
