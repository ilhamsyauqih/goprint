import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../data/order_flow_manager.dart';
import '../../data/order_model.dart';
import '../widgets/order_timeline.dart';
import '../widgets/order_item_detail_card.dart';
import '../widgets/payment_info_section.dart';

/// Layar Detail & Tracking Pesanan Lengkap (OrderDetailScreen).
class OrderDetailScreen extends StatefulWidget {
  final String orderId;

  const OrderDetailScreen({required this.orderId, super.key});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final OrderFlowManager _orderFlow = OrderFlowManager.instance;
  late OrderModel? _order;

  @override
  void initState() {
    super.initState();
    _loadOrder();
  }

  void _loadOrder() {
    // Navigasi dummy_active dari Home dipetakan ke GP-1092 yang berstatus 'processing' (Diproses)
    final id = widget.orderId == 'dummy_active' ? 'GP-1092' : widget.orderId;
    final found = _orderFlow.orders.where((o) => o.orderNumber == id).toList();
    if (found.isNotEmpty) {
      _order = found.first;
    } else {
      _order = null;
    }
  }

  void _confirmCancelOrder() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Batalkan Pesanan'),
        content: const Text('Apakah Anda yakin ingin membatalkan pesanan cetak dokumen ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Kembali'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (_order != null) {
                setState(() {
                  _orderFlow.cancelOrder(_order!.orderNumber);
                  _loadOrder(); // Muat ulang order untuk memperbarui tampilan status
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Pesanan ${_order!.orderNumber} berhasil dibatalkan'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Ya, Batalkan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_order == null) {
      return Scaffold(
        appBar: const CustomAppBar(title: 'Detail Pesanan', showBackButton: true),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.receipt_long_rounded, size: 64, color: AppColors.error),
              const SizedBox(height: 16),
              Text(
                'Pesanan Tidak Ditemukan',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Nomor pesanan "${widget.orderId}" tidak valid.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark ? AppColors.darkMutedText : AppColors.lightSubtleText,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final order = _order!;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: CustomAppBar(
        title: 'Detail ${order.orderNumber}',
        showBackButton: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Informasi Mitra Toko Cetak
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            order.shop.imageUrl,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              width: 60,
                              height: 60,
                              color: isDark ? AppColors.darkElevated : AppColors.lightSurface,
                              child: const Icon(Icons.storefront_rounded, size: 30),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                order.shop.name,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.star_rounded, color: Colors.orange, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    order.shop.rating.toString(),
                                    style: theme.textTheme.labelMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text('•', style: TextStyle(color: isDark ? AppColors.darkMutedText : AppColors.lightSubtleText)),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.location_on_rounded, color: Colors.teal, size: 14),
                                  const SizedBox(width: 2),
                                  Text(
                                    order.shop.distance,
                                    style: theme.textTheme.labelMedium?.copyWith(
                                      color: isDark ? AppColors.darkMutedText : AppColors.lightSubtleText,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                order.shop.address,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontSize: 12,
                                  color: isDark ? AppColors.darkMutedText : AppColors.lightSubtleText,
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Stepper Vertikal Pelacakan Status
                  OrderTimeline(order: order),
                  const SizedBox(height: 20),

                  // Daftar Berkas Cetak Dokumen
                  Text(
                    'Dokumen Cetak (${order.uploadedFiles.length})',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...order.uploadedFiles.map((file) => OrderItemDetailCard(file: file)),
                  const SizedBox(height: 20),

                  // Rincian Biaya dan Info Metode Pembayaran
                  PaymentInfoSection(order: order),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          // Sticky Bottom Actions: Tombol Batalkan / Beri Ulasan
          if (order.status == OrderStatus.pending || order.status == OrderStatus.completed)
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                border: Border(
                  top: BorderSide(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    width: 1,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  width: double.infinity,
                  child: order.status == OrderStatus.pending
                      ? OutlinedButton.icon(
                          onPressed: _confirmCancelOrder,
                          icon: const Icon(Icons.cancel_outlined, size: 18),
                          label: const Text('Batalkan Pesanan'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.error,
                            side: const BorderSide(color: AppColors.error, width: 1.5),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        )
                      : ElevatedButton.icon(
                          onPressed: order.isReviewed
                              ? null
                              : () async {
                                  // Navigasi ke halaman tulis ulasan (R2) dan tunggu hasilnya
                                  final reviewed = await context.push<bool>(
                                    '/orders/review/${order.orderNumber}',
                                  );
                                  if (reviewed == true) {
                                    setState(() {
                                      _loadOrder();
                                    });
                                  }
                                },
                          icon: Icon(
                            order.isReviewed
                                ? Icons.check_circle_rounded
                                : Icons.rate_review_rounded,
                            size: 18,
                          ),
                          label: Text(
                            order.isReviewed ? 'Ulasan Telah Dikirim' : 'Beri Ulasan',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: order.isReviewed
                                ? (isDark ? Colors.grey.shade800 : Colors.grey.shade300)
                                : (isDark ? AppColors.teal300 : AppColors.teal700),
                            foregroundColor: order.isReviewed
                                ? (isDark ? Colors.grey.shade500 : Colors.grey.shade600)
                                : (isDark ? AppColors.teal900 : Colors.white),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
