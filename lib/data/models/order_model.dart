// lib/data/models/order_model.dart

class OrderModel {
  final String id;
  final String? userId;
  final String? shopId;
  final String status; // 'pending' | 'confirmed' | 'processing' | 'ready' | 'completed' | 'cancelled'
  final String deliveryType; // 'pickup' | 'delivery'
  final String? addressId;
  final double totalPrice;
  final String paymentMethod;
  final String? paymentProofUrl;
  final String paymentStatus; // 'pending' | 'verified' | 'rejected'
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<OrderItemModel>? items;

  OrderModel({
    required this.id,
    this.userId,
    this.shopId,
    required this.status,
    required this.deliveryType,
    this.addressId,
    required this.totalPrice,
    required this.paymentMethod,
    this.paymentProofUrl,
    required this.paymentStatus,
    this.note,
    required this.createdAt,
    required this.updatedAt,
    this.items,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final itemsList = json['order_items'] as List?;
    final List<OrderItemModel>? parsedItems = itemsList?.map((item) => OrderItemModel.fromJson(item as Map<String, dynamic>)).toList();

    return OrderModel(
      id: json['id'] as String,
      userId: json['user_id'] as String?,
      shopId: json['shop_id'] as String?,
      status: json['status'] as String? ?? 'pending',
      deliveryType: json['delivery_type'] as String,
      addressId: json['address_id'] as String?,
      totalPrice: (json['total_price'] as num).toDouble(),
      paymentMethod: json['payment_method'] as String,
      paymentProofUrl: json['payment_proof_url'] as String?,
      paymentStatus: json['payment_status'] as String? ?? 'pending',
      note: json['note'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      items: parsedItems,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'id': id,
      'user_id': userId,
      'shop_id': shopId,
      'status': status,
      'delivery_type': deliveryType,
      'address_id': addressId,
      'total_price': totalPrice,
      'payment_method': paymentMethod,
      'payment_proof_url': paymentProofUrl,
      'payment_status': paymentStatus,
      'note': note,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
    if (items != null) {
      data['order_items'] = items!.map((item) => item.toJson()).toList();
    }
    return data;
  }

  OrderModel copyWith({
    String? id,
    String? userId,
    String? shopId,
    String? status,
    String? deliveryType,
    String? addressId,
    double? totalPrice,
    String? paymentMethod,
    String? paymentProofUrl,
    String? paymentStatus,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<OrderItemModel>? items,
  }) {
    return OrderModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      shopId: shopId ?? this.shopId,
      status: status ?? this.status,
      deliveryType: deliveryType ?? this.deliveryType,
      addressId: addressId ?? this.addressId,
      totalPrice: totalPrice ?? this.totalPrice,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentProofUrl: paymentProofUrl ?? this.paymentProofUrl,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      items: items ?? this.items,
    );
  }
}

class OrderItemModel {
  final String id;
  final String orderId;
  final String? serviceId;
  final String fileUrl;
  final String fileName;
  final int pages;
  final int copies;
  final String colorMode; // 'bw' | 'color'
  final String paperSize; // 'A4' | 'A3' | 'F4'
  final String? finishing;
  final bool isDoubleSided;
  final double subtotal;

  OrderItemModel({
    required this.id,
    required this.orderId,
    this.serviceId,
    required this.fileUrl,
    required this.fileName,
    required this.pages,
    required this.copies,
    required this.colorMode,
    required this.paperSize,
    this.finishing,
    required this.isDoubleSided,
    required this.subtotal,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'] as String,
      orderId: json['order_id'] as String,
      serviceId: json['service_id'] as String?,
      fileUrl: json['file_url'] as String,
      fileName: json['file_name'] as String,
      pages: json['pages'] as int,
      copies: json['copies'] as int? ?? 1,
      colorMode: json['color_mode'] as String,
      paperSize: json['paper_size'] as String,
      finishing: json['finishing'] as String?,
      isDoubleSided: json['is_double_sided'] as bool? ?? false,
      subtotal: (json['subtotal'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'service_id': serviceId,
      'file_url': fileUrl,
      'file_name': fileName,
      'pages': pages,
      'copies': copies,
      'color_mode': colorMode,
      'paper_size': paperSize,
      'finishing': finishing,
      'is_double_sided': isDoubleSided,
      'subtotal': subtotal,
    };
  }

  OrderItemModel copyWith({
    String? id,
    String? orderId,
    String? serviceId,
    String? fileUrl,
    String? fileName,
    int? pages,
    int? copies,
    String? colorMode,
    String? paperSize,
    String? finishing,
    bool? isDoubleSided,
    double? subtotal,
  }) {
    return OrderItemModel(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      serviceId: serviceId ?? this.serviceId,
      fileUrl: fileUrl ?? this.fileUrl,
      fileName: fileName ?? this.fileName,
      pages: pages ?? this.pages,
      copies: copies ?? this.copies,
      colorMode: colorMode ?? this.colorMode,
      paperSize: paperSize ?? this.paperSize,
      finishing: finishing ?? this.finishing,
      isDoubleSided: isDoubleSided ?? this.isDoubleSided,
      subtotal: subtotal ?? this.subtotal,
    );
  }
}

class PriceBreakdown {
  final double basePrice;
  final double colorSurcharge;
  final double finishingCost;
  final double doubleSidedDiscount;
  final double deliveryFee;
  final double subtotal;
  final double totalPrice;

  PriceBreakdown({
    required this.basePrice,
    required this.colorSurcharge,
    required this.finishingCost,
    required this.doubleSidedDiscount,
    required this.deliveryFee,
    required this.subtotal,
    required this.totalPrice,
  });

  factory PriceBreakdown.fromJson(Map<String, dynamic> json) {
    return PriceBreakdown(
      basePrice: (json['base_price'] as num).toDouble(),
      colorSurcharge: (json['color_surcharge'] as num).toDouble(),
      finishingCost: (json['finishing_cost'] as num).toDouble(),
      doubleSidedDiscount: (json['double_sided_discount'] as num).toDouble(),
      deliveryFee: (json['delivery_fee'] as num).toDouble(),
      subtotal: (json['subtotal'] as num).toDouble(),
      totalPrice: (json['total_price'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'base_price': basePrice,
      'color_surcharge': colorSurcharge,
      'finishing_cost': finishingCost,
      'double_sided_discount': doubleSidedDiscount,
      'delivery_fee': deliveryFee,
      'subtotal': subtotal,
      'total_price': totalPrice,
    };
  }
}
