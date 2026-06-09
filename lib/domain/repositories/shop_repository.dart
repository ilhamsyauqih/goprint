// lib/domain/repositories/shop_repository.dart

import '../../data/models/shop_model.dart';

abstract class ShopRepository {
  /// Fetch all active shops, optionally filtered by name/query
  Future<List<ShopModel>> getShops({String? query});

  /// Retrieve a specific shop by its ID
  Future<ShopModel> getShopById(String id);

  /// Fetch all services provided by a specific shop
  Future<List<ServiceModel>> getShopServices(String shopId);

  /// Fetch nearby shops based on user coordinates using the Haversine formula
  Future<List<ShopModel>> getNearbyShops(
    double lat,
    double lng, {
    double maxDistanceKm = 10.0,
  });
}
