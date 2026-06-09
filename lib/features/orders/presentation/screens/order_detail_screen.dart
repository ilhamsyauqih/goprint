import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../data/order_model.dart';
import '../../data/order_flow_manager.dart';
import '../widgets/order_timeline.dart';
import '../widgets/order_item_detail_card.dart';
import '../widgets/payment_info_section.dart';
import '../providers/order_provider.dart';
import '../../../shop/data/mock_shops.dart';

/// Layar Detail & Tracking Pesanan Lengkap (OrderDetailScreen).
class OrderDetailScreen extends ConsumerStatefulWidget {
  final String orderId;

  const OrderDetailScreen({required this.orderId, super.key});

  @override
  ConsumerState<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends ConsumerState<OrderDetailScreen> {
  late OrderModel? _order;
  String? _dbOrderId;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadOrder();
  }

  Future<void> _loadOrder() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final client = Supabase.instance.client;
      final cleanId = widget.orderId.replaceAll('GP-', '').toLowerCase();
      
      final List data = await client
          .from('orders')
          .select('*, order_items(*), shops(*)');

      Map<String, dynamic>? match;
      for (final item in data) {
        final idStr = (item['id'] as String).replaceAll('-', '').toLowerCase();
        if (idStr.startsWith(cleanId)) {
          match = item as Map<String, dynamic>;
          break;
        }
      }

      if (match == null) {
        setState(() {
          _order = null;
          _isLoading = false;
        });
        return;
      }

      final json = match;
      final orderId = json['id'] as String;
      _dbOrderId = orderId;
      final shopJson = json['shops'] as Map?;

      final shop = Shop(
        id: shopJson?['id'] ?? '1',
        name: shopJson?['name'] ?? 'Fotokopi Surya Gemilang',
        imageUrl: shopJson?['photo_urls'] != null && (shopJson?['photo_urls'] as List).isNotEmpty 
            ? (shopJson?['photo_urls'] as List).first 
            : '',
        rating: (shopJson?['rating'] as num?)?.toDouble() ?? 4.8,
        distance: '0.5 km',
        isOpen: shopJson?['is_open'] ?? true,
        description: shopJson?['description'] ?? '',
        address: shopJson?['address'] ?? '',
        phone: '',
        services: [],
        reviews: [],
        operatingHours: [],
      );

      final List itemsList = json['order_items'] as List? ?? [];
      final List<UploadedFile> uploadedFiles = [];
      for (final item in itemsList) {
        final isColor = item['color_mode'] == 'color';
        uploadedFiles.add(UploadedFile(
          id: item['id'] as String,
          name: item['file_name'] as String,
          size: '1.2 MB',
          pageCount: item['pages'] as int? ?? 1,
          copies: item['copies'] as int? ?? 1,
          colorMode: isColor ? 'Warna' : 'Hitam Putih',
          paperSize: item['paper_size'] as String? ?? 'A4',
          paperType: 'HVS 70g',
          doubleSide: item['is_double_sided'] as bool? ?? false,
          finishing: item['finishing'] as String? ?? 'Tanpa Jilid',
          filePath: item['file_url'] as String,
        ));
      }

      OrderStatus status = OrderStatus.pending;
      switch (json['status']) {
        case 'pending':
          status = OrderStatus.pending;
          break;
        case 'confirmed':
          status = OrderStatus.confirmed;
          break;
        case 'processing':
          status = OrderStatus.processing;
          break;
        case 'ready':
          status = OrderStatus.ready;
          break;
        case 'completed':
          status = OrderStatus.completed;
          break;
        case 'cancelled':
          status = OrderStatus.cancelled;
          break;
      }

      String paymentStatus = 'Menunggu Verifikasi';
      switch (json['payment_status']) {
        case 'pending':
          paymentStatus = 'Menunggu Verifikasi';
          break;
        case 'verified':
          paymentStatus = 'Terverifikasi';
          break;
        case 'rejected':
          paymentStatus = 'Gagal';
          break;
      }

      setState(() {
        _order = OrderModel(
          orderNumber: widget.orderId.startsWith('GP-') ? widget.orderId : 'GP-${orderId.substring(0, 8).toUpperCase()}',
          shop: shop,
          uploadedFiles: uploadedFiles,
          deliveryType: json['delivery_type'] ?? 'pickup',
          deliveryAddress: json['note'],
          deliveryFee: (json['delivery_fee'] as num?)?.toInt() ?? 0,
          paymentMethod: json['payment_method'] ?? 'QRIS',
          paymentProofPath: json['payment_proof_url'],
          paymentStatus: paymentStatus,
          status: status,
          date: DateTime.parse(json['created_at'] as String),
          totalFee: (json['total_price'] as num?)?.toInt() ?? 0,
        );
        _dbOrderId = orderId;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _cancelOrderInDb() async {
    try {
      final client = Supabase.instance.client;
      await client.from('orders').update({
        'status': 'cancelled',
        'payment_status': 'rejected',
      }).eq('id', _dbOrderId!);

      await _loadOrder();
      ref.invalidate(userOrdersProvider);
      ref.invalidate(activeOrderProvider);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pesanan ${_order!.orderNumber} berhasil dibatalkan'),
          backgroundColor: AppColors.error,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal membatalkan pesanan: $e'),
          backgroundColor: AppColors.error,
        ),
      );
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
              _cancelOrderInDb();
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

    if (_isLoading) {
      return Scaffold(
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
        appBar: CustomAppBar(
          title: 'Detail ${widget.orderId}',
          showBackButton: true,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
        appBar: CustomAppBar(
          title: 'Detail ${widget.orderId}',
          showBackButton: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, size: 64, color: AppColors.error),
              const SizedBox(height: 16),
              Text(
                'Terjadi Kesalahan',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark ? AppColors.darkMutedText : AppColors.lightSubtleText,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadOrder,
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

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
