import '../../shop/data/mock_shops.dart';
import 'order_flow_manager.dart';

/// Status pesanan untuk alur pelacakan pesanan (Order Tracking).
enum OrderStatus {
  pending,      // Menunggu Konfirmasi (Abu-abu)
  confirmed,    // Dikonfirmasi (Biru)
  processing,   // Diproses (Kuning)
  ready,        // Siap Diambil / Dikirim (Teal)
  completed,    // Selesai (Hijau)
  cancelled,    // Dibatalkan (Merah)
}

/// Model data representasi Pesanan Pengguna (Order).
class OrderModel {
  final String orderNumber;
  final Shop shop;
  final List<UploadedFile> uploadedFiles;
  final String deliveryType; // 'pickup' | 'delivery'
  final String? deliveryAddress;
  final int deliveryFee;
  final String paymentMethod;
  final String? paymentProofPath;
  String paymentStatus; // 'Menunggu Verifikasi' | 'Terverifikasi' | 'Gagal' | 'Dibatalkan'
  OrderStatus status;
  final DateTime date;
  final int totalFee;
  bool isReviewed;

  // R4 Admin fields
  final String customerName;
  final String customerPhone;
  String? rejectReason;
  String? estimatedCompletionTime;
  String? internalNote;

  OrderModel({
    required this.orderNumber,
    required this.shop,
    required this.uploadedFiles,
    required this.deliveryType,
    this.deliveryAddress,
    required this.deliveryFee,
    required this.paymentMethod,
    this.paymentProofPath,
    required this.paymentStatus,
    required this.status,
    required this.date,
    required this.totalFee,
    this.isReviewed = false,
    this.customerName = 'Pelanggan Umum',
    this.customerPhone = '+6281234567890',
    this.rejectReason,
    this.estimatedCompletionTime,
    this.internalNote,
  });

  OrderModel copyWith({
    String? orderNumber,
    Shop? shop,
    List<UploadedFile>? uploadedFiles,
    String? deliveryType,
    String? deliveryAddress,
    int? deliveryFee,
    String? paymentMethod,
    String? paymentProofPath,
    String? paymentStatus,
    OrderStatus? status,
    DateTime? date,
    int? totalFee,
    bool? isReviewed,
    String? customerName,
    String? customerPhone,
    String? rejectReason,
    String? estimatedCompletionTime,
    String? internalNote,
  }) {
    return OrderModel(
      orderNumber: orderNumber ?? this.orderNumber,
      shop: shop ?? this.shop,
      uploadedFiles: uploadedFiles ?? this.uploadedFiles,
      deliveryType: deliveryType ?? this.deliveryType,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentProofPath: paymentProofPath ?? this.paymentProofPath,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      status: status ?? this.status,
      date: date ?? this.date,
      totalFee: totalFee ?? this.totalFee,
      isReviewed: isReviewed ?? this.isReviewed,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      rejectReason: rejectReason ?? this.rejectReason,
      estimatedCompletionTime: estimatedCompletionTime ?? this.estimatedCompletionTime,
      internalNote: internalNote ?? this.internalNote,
    );
  }
}
