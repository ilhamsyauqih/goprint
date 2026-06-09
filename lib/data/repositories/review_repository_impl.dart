// lib/data/repositories/review_repository_impl.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/supabase/supabase_service.dart';
import '../../domain/repositories/review_repository.dart';
import '../models/review_model.dart';

class ReviewRepositoryImpl implements ReviewRepository {
  final SupabaseClient _client;

  ReviewRepositoryImpl(this._client);

  @override
  Future<void> createReview(ReviewModel review) async {
    final json = review.toJson();
    if (review.id.isEmpty) {
      json.remove('id');
    }
    json.remove('created_at');

    await _client.from('reviews').insert(json);
  }

  @override
  Future<List<ReviewModel>> getShopReviews(String shopId) async {
    final List data = await _client
        .from('reviews')
        .select()
        .eq('shop_id', shopId)
        .order('created_at', ascending: false);
        
    return data.map((json) => ReviewModel.fromJson(json)).toList();
  }
}

/// Riverpod provider for ReviewRepository
final reviewRepositoryProvider = Provider<ReviewRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return ReviewRepositoryImpl(client);
});
