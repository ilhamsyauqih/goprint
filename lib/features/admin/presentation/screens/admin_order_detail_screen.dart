import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../orders/data/order_model.dart';
import '../../../orders/data/order_flow_manager.dart';
import '../../../orders/presentation/widgets/order_item_detail_card.dart';
import '../../../orders/presentation/widgets/payment_info_section.dart';
import '../widgets/customer_info_section.dart';
import '../widgets/payment_verification_section.dart';
import '../widgets/admin_action_buttons.dart';
import '../widgets/internal_note_field.dart';
import '../../../orders/presentation/providers/order_provider.dart';
import '../../../shop/data/mock_shops.dart';

class AdminOrderDetailScreen extends ConsumerStatefulWidget {
  final String orderId;

  const AdminOrderDetailScreen({required this.orderId, super.key});

  @override
  ConsumerState<AdminOrderDetailScreen> createState() => _AdminOrderDetailScreenState();
}

class _AdminOrderDetailScreenState extends ConsumerState<AdminOrderDetailScreen> {
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
          .select('*, order_items(*), profiles(*), shops(*)');

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
      final profile = json['profiles'] as Map?;
      
      final shop = Shop(
        id: shopJson?['id'] ?? '1',
        name: shopJson?['name'] ?? 'Fotokopi Surya Gemilang',
        imageUrl: shopJson?['photo_urls'] != null && (shopJson?['photo_urls'] as List).isNotEmpty 
            ? (shopJson?['photo_urls'] as List).first 
            : '',
        rating: (shopJson?['rating'] as num?)?.toDouble() ?? 4.8,
        distance: '0.0 km',
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

      // Generate signed URL untuk payment proof jika ada
      String? signedProofUrl = json['payment_proof_url'] as String?;
      if (signedProofUrl != null && signedProofUrl.isNotEmpty && !signedProofUrl.startsWith('http')) {
        try {
          signedProofUrl = await client.storage
              .from('payment-proofs')
              .createSignedUrl(signedProofUrl, 3600);
        } catch (_) {}
      }

      setState(() {
        _order = OrderModel(
          orderNumber: widget.orderId,
          shop: shop,
          uploadedFiles: uploadedFiles,
          deliveryType: json['delivery_type'] ?? 'pickup',
          deliveryAddress: json['note'],
          deliveryFee: (json['delivery_fee'] as num?)?.toInt() ?? 0,
          paymentMethod: json['payment_method'] ?? 'QRIS',
          paymentProofPath: signedProofUrl,
          paymentStatus: paymentStatus,
          status: status,
          date: DateTime.parse(json['created_at'] as String),
          totalFee: (json['total_price'] as num?)?.toInt() ?? 0,
          customerName: profile?['name'] ?? 'Pelanggan',
          customerPhone: profile?['phone'] ?? '+6281234567890',
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
        appBar: CustomAppBar(
          title: 'Kelola ${widget.orderId}',
          showBackButton: true,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
        appBar: CustomAppBar(
          title: 'Kelola ${widget.orderId}',
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
        title: 'Kelola ${order.orderNumber}',
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
                  // Customer Information Section
                  CustomerInfoSection(order: order),
                  const SizedBox(height: 20),

                  // Estimate completion time banner (if exists and processing/ready)
                  if (order.estimatedCompletionTime != null && 
                      (order.status == OrderStatus.processing || order.status == OrderStatus.ready)) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark 
                            ? AppColors.teal900.withValues(alpha: 0.2) 
                            : AppColors.teal700.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: (isDark ? AppColors.teal300 : AppColors.teal700).withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.timer_outlined,
                            color: isDark ? AppColors.teal300 : AppColors.teal700,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Estimasi Pengerjaan: ',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          Text(
                            order.estimatedCompletionTime!,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Payment Verification Section (Approve / Reject verification)
                  PaymentVerificationSection(
                    order: order,
                    onUpdate: () async {
                      final client = Supabase.instance.client;
                      String dbPaymentStatus = 'pending';
                      if (order.paymentStatus == 'Terverifikasi') dbPaymentStatus = 'verified';
                      if (order.paymentStatus == 'Gagal') dbPaymentStatus = 'rejected';

                      String dbStatus = 'pending';
                      switch (order.status) {
                        case OrderStatus.pending: dbStatus = 'pending'; break;
                        case OrderStatus.confirmed: dbStatus = 'confirmed'; break;
                        case OrderStatus.processing: dbStatus = 'processing'; break;
                        case OrderStatus.ready: dbStatus = 'ready'; break;
                        case OrderStatus.completed: dbStatus = 'completed'; break;
                        case OrderStatus.cancelled: dbStatus = 'cancelled'; break;
                      }

                      await client.from('orders').update({
                        'payment_status': dbPaymentStatus,
                        'status': dbStatus,
                      }).eq('id', _dbOrderId!);

                      await _loadOrder();
                      ref.invalidate(adminOrdersProvider);
                      ref.invalidate(activeOrderProvider);
                      ref.invalidate(userOrdersProvider);
                    },
                  ),

                  // Internal Notes Field Section
                  InternalNoteField(
                    order: order,
                    onSaved: () async {
                      if (order.internalNote != null) {
                        final client = Supabase.instance.client;
                        await client.from('orders').update({
                          'note': order.internalNote,
                        }).eq('id', _dbOrderId!);
                      }
                      await _loadOrder();
                    },
                  ),

                  // Document List Section
                  Text(
                    'Dokumen Cetak (${order.uploadedFiles.length})',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...order.uploadedFiles.map((file) => OrderItemDetailCard(file: file)),
                  const SizedBox(height: 20),

                  // Pricing Details Section
                  PaymentInfoSection(order: order),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Sticky Bottom Section for Actions
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
              child: AdminActionButtons(
                order: order,
                onUpdate: () async {
                  final client = Supabase.instance.client;

                  String dbStatus = 'pending';
                  switch (order.status) {
                    case OrderStatus.pending: dbStatus = 'pending'; break;
                    case OrderStatus.confirmed: dbStatus = 'confirmed'; break;
                    case OrderStatus.processing: dbStatus = 'processing'; break;
                    case OrderStatus.ready: dbStatus = 'ready'; break;
                    case OrderStatus.completed: dbStatus = 'completed'; break;
                    case OrderStatus.cancelled: dbStatus = 'cancelled'; break;
                  }

                  String dbPaymentStatus = 'pending';
                  if (order.paymentStatus == 'Terverifikasi') dbPaymentStatus = 'verified';
                  if (order.paymentStatus == 'Gagal') dbPaymentStatus = 'rejected';

                  await client.from('orders').update({
                    'status': dbStatus,
                    'payment_status': dbPaymentStatus,
                  }).eq('id', _dbOrderId!);

                  await _loadOrder();
                  ref.invalidate(adminOrdersProvider);
                  ref.invalidate(activeOrderProvider);
                  ref.invalidate(userOrdersProvider);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
