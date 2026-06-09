import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/supabase/supabase_service.dart';
import '../../../../data/repositories/auth_repository_impl.dart';
import '../../data/order_model.dart' as ui;
import '../../data/order_flow_manager.dart' as ui;
import '../../../shop/data/mock_shops.dart' as ui;

final activeOrderProvider = FutureProvider.autoDispose<Map<String, dynamic>?>((ref) async {
  final user = await ref.read(authRepositoryProvider).getCurrentUser();
  if (user == null) return null;

  final client = ref.read(supabaseClientProvider);
  
  // Ambil pesanan teranyar yang statusnya masih aktif (belum selesai/batal)
  final List data = await client
      .from('orders')
      .select('id, status, created_at, shops(name)')
      .eq('user_id', user.id)
      .inFilter('status', ['pending', 'confirmed', 'processing', 'ready'])
      .order('created_at', ascending: false)
      .limit(1);

  if (data.isEmpty) return null;
  return data.first as Map<String, dynamic>;
});

final userOrdersProvider = FutureProvider.autoDispose<List<ui.OrderModel>>((ref) async {
  final user = await ref.read(authRepositoryProvider).getCurrentUser();
  if (user == null) return [];

  final client = ref.read(supabaseClientProvider);
  
  final List data = await client
      .from('orders')
      .select('*, order_items(*), shops(*)')
      .eq('user_id', user.id)
      .order('created_at', ascending: false);

  final List<ui.OrderModel> list = [];
  for (final json in data) {
    final orderId = json['id'] as String;
    final orderNumber = 'GP-${orderId.substring(0, 8).toUpperCase()}';
    final shopJson = json['shops'] as Map?;
    final shop = ui.Shop(
      id: shopJson?['id'] ?? '1',
      name: shopJson?['name'] ?? 'Fotokopi Surya Gemilang',
      imageUrl: shopJson?['photo_urls'] != null && (shopJson?['photo_urls'] as List).isNotEmpty 
          ? (shopJson?['photo_urls'] as List).first 
          : 'https://images.unsplash.com/photo-1585776245991-cf89dd7fc73a?q=80&w=600&auto=format&fit=crop',
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
    final List<ui.UploadedFile> uploadedFiles = itemsList.map((item) {
      final isColor = item['color_mode'] == 'color';
      return ui.UploadedFile(
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
      );
    }).toList();

    ui.OrderStatus status = ui.OrderStatus.pending;
    switch (json['status']) {
      case 'pending':
        status = ui.OrderStatus.pending;
        break;
      case 'confirmed':
        status = ui.OrderStatus.confirmed;
        break;
      case 'processing':
        status = ui.OrderStatus.processing;
        break;
      case 'ready':
        status = ui.OrderStatus.ready;
        break;
      case 'completed':
        status = ui.OrderStatus.completed;
        break;
      case 'cancelled':
        status = ui.OrderStatus.cancelled;
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

    list.add(ui.OrderModel(
      orderNumber: orderNumber,
      shop: shop,
      uploadedFiles: uploadedFiles,
      deliveryType: json['delivery_type'] ?? 'pickup',
      deliveryFee: (json['delivery_fee'] as num?)?.toInt() ?? 0,
      paymentMethod: json['payment_method'] ?? 'QRIS',
      paymentProofPath: json['payment_proof_url'],
      paymentStatus: paymentStatus,
      status: status,
      date: DateTime.parse(json['created_at'] as String),
      totalFee: (json['total_price'] as num?)?.toInt() ?? 0,
    ));
  }
  return list;
});

final adminShopProvider = FutureProvider.autoDispose<Map<String, dynamic>?>((ref) async {
  final user = await ref.read(authRepositoryProvider).getCurrentUser();
  if (user == null) return null;

  final client = ref.read(supabaseClientProvider);
  final List data = await client.from('shops').select().eq('owner_id', user.id).limit(1);
  if (data.isEmpty) return null;
  return data.first as Map<String, dynamic>;
});

final adminOrdersProvider = FutureProvider.autoDispose<List<ui.OrderModel>>((ref) async {
  final shop = await ref.watch(adminShopProvider.future);
  if (shop == null) return [];

  final client = ref.read(supabaseClientProvider);
  final List data = await client
      .from('orders')
      .select('*, order_items(*), profiles(*)')
      .eq('shop_id', shop['id'])
      .order('created_at', ascending: false);

  final List<ui.OrderModel> list = [];
  for (final json in data) {
    final orderId = json['id'] as String;
    final orderNumber = 'GP-${orderId.substring(0, 8).toUpperCase()}';
    final profile = json['profiles'] as Map?;

    final List itemsList = json['order_items'] as List? ?? [];
    final List<ui.UploadedFile> uploadedFiles = itemsList.map((item) {
      final isColor = item['color_mode'] == 'color';
      return ui.UploadedFile(
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
      );
    }).toList();

    ui.OrderStatus status = ui.OrderStatus.pending;
    switch (json['status']) {
      case 'pending':
        status = ui.OrderStatus.pending;
        break;
      case 'confirmed':
        status = ui.OrderStatus.confirmed;
        break;
      case 'processing':
        status = ui.OrderStatus.processing;
        break;
      case 'ready':
        status = ui.OrderStatus.ready;
        break;
      case 'completed':
        status = ui.OrderStatus.completed;
        break;
      case 'cancelled':
        status = ui.OrderStatus.cancelled;
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

    final dummyShop = ui.Shop(
      id: shop['id'] as String,
      name: shop['name'] as String,
      imageUrl: '',
      rating: 4.8,
      distance: '0.0 km',
      isOpen: true,
      description: '',
      address: '',
      phone: '',
      services: [],
      reviews: [],
      operatingHours: [],
    );

    list.add(ui.OrderModel(
      orderNumber: orderNumber,
      shop: dummyShop,
      uploadedFiles: uploadedFiles,
      deliveryType: json['delivery_type'] ?? 'pickup',
      deliveryFee: (json['delivery_fee'] as num?)?.toInt() ?? 0,
      paymentMethod: json['payment_method'] ?? 'QRIS',
      paymentProofPath: json['payment_proof_url'],
      paymentStatus: paymentStatus,
      status: status,
      date: DateTime.parse(json['created_at'] as String),
      totalFee: (json['total_price'] as num?)?.toInt() ?? 0,
      customerName: profile?['name'] ?? 'Pelanggan',
      customerPhone: profile?['phone'] ?? '+6281234567890',
    ));
  }
  return list;
});
