// lib/domain/repositories/review_repository.dart

import '../../data/models/review_model.dart';

abstract class ReviewRepository {
  /// Create a new review/rating for a completed order
  Future<void> createReview(ReviewModel review);

  /// Fetch all reviews received by a specific shop
  Future<List<ReviewModel>> getShopReviews(String shopId);
}
