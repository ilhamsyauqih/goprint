// lib/data/models/review_model.dart

class ReviewModel {
  final String id;
  final String orderId;
  final String userId;
  final String shopId;
  final int rating; // 1 to 5
  final String? comment;
  final bool isAnonymous;
  final DateTime createdAt;

  ReviewModel({
    required this.id,
    required this.orderId,
    required this.userId,
    required this.shopId,
    required this.rating,
    this.comment,
    required this.isAnonymous,
    required this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] as String,
      orderId: json['order_id'] as String,
      userId: json['user_id'] as String,
      shopId: json['shop_id'] as String,
      rating: json['rating'] as int,
      comment: json['comment'] as String?,
      isAnonymous: json['is_anonymous'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'user_id': userId,
      'shop_id': shopId,
      'rating': rating,
      'comment': comment,
      'is_anonymous': isAnonymous,
      'created_at': createdAt.toIso8601String(),
    };
  }

  ReviewModel copyWith({
    String? id,
    String? orderId,
    String? userId,
    String? shopId,
    int? rating,
    String? comment,
    bool? isAnonymous,
    DateTime? createdAt,
  }) {
    return ReviewModel(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      userId: userId ?? this.userId,
      shopId: shopId ?? this.shopId,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
