// lib/data/repositories/shop_repository_impl.dart

import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/supabase/supabase_service.dart';
import '../../domain/repositories/shop_repository.dart';
import '../models/shop_model.dart';

class ShopRepositoryImpl implements ShopRepository {
  final SupabaseClient _client;

  ShopRepositoryImpl(this._client);

  @override
  Future<List<ShopModel>> getShops({String? query}) async {
    var builder = _client.from('shops').select();
    if (query != null && query.isNotEmpty) {
      builder = builder.ilike('name', '%$query%');
    }
    final List data = await builder;
    return data.map((json) => ShopModel.fromJson(json)).toList();
  }

  @override
  Future<ShopModel> getShopById(String id) async {
    final data = await _client.from('shops').select().eq('id', id).single();
    return ShopModel.fromJson(data);
  }

  @override
  Future<List<ServiceModel>> getShopServices(String shopId) async {
    final List data = await _client
        .from('services')
        .select()
        .eq('shop_id', shopId)
        .eq('is_active', true);
    return data.map((json) => ServiceModel.fromJson(json)).toList();
  }

  @override
  Future<List<ShopModel>> getNearbyShops(
    double lat,
    double lng, {
    double maxDistanceKm = 10.0,
  }) async {
    final List data = await _client.from('shops').select();
    final allShops = data.map((json) => ShopModel.fromJson(json)).toList();

    final List<MapEntry<ShopModel, double>> shopsWithDistance = [];
    for (final shop in allShops) {
      final distance = _calculateHaversine(lat, lng, shop.lat, shop.lng);
      if (distance <= maxDistanceKm) {
        shopsWithDistance.add(MapEntry(shop, distance));
      }
    }

    // Sort by status (open shops first) then distance (closest first)
    shopsWithDistance.sort((a, b) {
      if (a.key.isOpen && !b.key.isOpen) return -1;
      if (!a.key.isOpen && b.key.isOpen) return 1;
      return a.value.compareTo(b.value);
    });

    return shopsWithDistance.map((entry) => entry.key).toList();
  }

  double _calculateHaversine(double lat1, double lon1, double lat2, double lon2) {
    const double r = 6371; // Earth radius in km
    final dLat = _degToRad(lat2 - lat1);
    final dLon = _degToRad(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degToRad(lat1)) * cos(_degToRad(lat2)) * sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return r * c;
  }

  double _degToRad(double deg) {
    return deg * (pi / 180);
  }
}

/// Riverpod provider for ShopRepository
final shopRepositoryProvider = Provider<ShopRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return ShopRepositoryImpl(client);
});
