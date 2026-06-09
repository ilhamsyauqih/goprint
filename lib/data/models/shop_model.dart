// lib/data/models/shop_model.dart

class ShopModel {
  final String id;
  final String ownerId;
  final String name;
  final String? description;
  final String address;
  final double lat;
  final double lng;
  final List<String> photoUrls;
  final Map<String, dynamic> operatingHours;
  final bool isOpen;
  final double rating;
  final DateTime createdAt;
  final DateTime updatedAt;

  ShopModel({
    required this.id,
    required this.ownerId,
    required this.name,
    this.description,
    required this.address,
    required this.lat,
    required this.lng,
    required this.photoUrls,
    required this.operatingHours,
    required this.isOpen,
    required this.rating,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ShopModel.fromJson(Map<String, dynamic> json) {
    return ShopModel(
      id: json['id'] as String,
      ownerId: json['owner_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      address: json['address'] as String,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      photoUrls: List<String>.from(json['photo_urls'] as List? ?? []),
      operatingHours: Map<String, dynamic>.from(json['operating_hours'] as Map? ?? {}),
      isOpen: json['is_open'] as bool? ?? true,
      rating: (json['rating'] as num? ?? 0.0).toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owner_id': ownerId,
      'name': name,
      'description': description,
      'address': address,
      'lat': lat,
      'lng': lng,
      'photo_urls': photoUrls,
      'operating_hours': operatingHours,
      'is_open': isOpen,
      'rating': rating,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  ShopModel copyWith({
    String? id,
    String? ownerId,
    String? name,
    String? description,
    String? address,
    double? lat,
    double? lng,
    List<String>? photoUrls,
    Map<String, dynamic>? operatingHours,
    bool? isOpen,
    double? rating,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ShopModel(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      description: description ?? this.description,
      address: address ?? this.address,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      photoUrls: photoUrls ?? this.photoUrls,
      operatingHours: operatingHours ?? this.operatingHours,
      isOpen: isOpen ?? this.isOpen,
      rating: rating ?? this.rating,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class ServiceModel {
  final String id;
  final String shopId;
  final String name;
  final String type; // 'print' | 'binding' | 'laminating' | 'scan' | 'photocopy'
  final double basePrice;
  final bool isActive;
  final Map<String, dynamic> options;
  final DateTime createdAt;

  ServiceModel({
    required this.id,
    required this.shopId,
    required this.name,
    required this.type,
    required this.basePrice,
    required this.isActive,
    required this.options,
    required this.createdAt,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'] as String,
      shopId: json['shop_id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      basePrice: (json['base_price'] as num).toDouble(),
      isActive: json['is_active'] as bool? ?? true,
      options: Map<String, dynamic>.from(json['options'] as Map? ?? {}),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shop_id': shopId,
      'name': name,
      'type': type,
      'base_price': basePrice,
      'is_active': isActive,
      'options': options,
      'created_at': createdAt.toIso8601String(),
    };
  }

  ServiceModel copyWith({
    String? id,
    String? shopId,
    String? name,
    String? type,
    double? basePrice,
    bool? isActive,
    Map<String, dynamic>? options,
    DateTime? createdAt,
  }) {
    return ServiceModel(
      id: id ?? this.id,
      shopId: shopId ?? this.shopId,
      name: name ?? this.name,
      type: type ?? this.type,
      basePrice: basePrice ?? this.basePrice,
      isActive: isActive ?? this.isActive,
      options: options ?? this.options,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
