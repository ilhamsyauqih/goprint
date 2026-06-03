import 'package:flutter/material.dart';

import 'nearby_shop_card.dart';

/// Daftar horizontal toko fotokopi terdekat.
class NearbyShopList extends StatelessWidget {
  const NearbyShopList({super.key});

  // Dummy shops
  static const List<Map<String, dynamic>> _dummyShops = [
    {
      'id': '1',
      'name': 'Fotokopi Surya Gemilang',
      'rating': 4.8,
      'distance': '0.5 km',
      'isOpen': true,
      'imageUrl': '',
    },
    {
      'id': '2',
      'name': 'Prima Print Center',
      'rating': 4.5,
      'distance': '1.2 km',
      'isOpen': true,
      'imageUrl': '',
    },
    {
      'id': '3',
      'name': 'Jaya Abadi Fotokopi',
      'rating': 4.2,
      'distance': '2.1 km',
      'isOpen': false,
      'imageUrl': '',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200, // Fixed height for horizontal scroll
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        itemCount: _dummyShops.length,
        itemBuilder: (context, index) {
          final shop = _dummyShops[index];
          return NearbyShopCard(
            id: shop['id'],
            name: shop['name'],
            rating: shop['rating'],
            distance: shop['distance'],
            isOpen: shop['isOpen'],
            imageUrl: shop['imageUrl'],
          );
        },
      ),
    );
  }
}
