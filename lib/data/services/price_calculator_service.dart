// lib/data/services/price_calculator_service.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/order_model.dart';

class PriceCalculatorService {
  /// Calculate pricing breakdown for a single item
  PriceBreakdown calculateItemPrice({
    required double basePrice,
    required int pages,
    required int copies,
    required bool isColor,
    required String? finishing,
    required bool isDoubleSided,
  }) {
    // 1. Base print price
    final double printPrice = basePrice * pages * copies;

    // 2. Color surcharge (+50% of base price)
    final double colorSurcharge = isColor ? (basePrice * 0.5 * pages * copies) : 0.0;

    // 3. Finishing cost:
    // - staple: +Rp 500 flat per copy
    // - spiral: +Rp 3.000 flat per copy
    // - laminate: +Rp 2.000 per page per copy
    double finishingCost = 0.0;
    if (finishing != null && finishing.isNotEmpty) {
      final lowerFinishing = finishing.toLowerCase();
      if (lowerFinishing.contains('staple')) {
        finishingCost += 500.0 * copies;
      } else if (lowerFinishing.contains('spiral')) {
        finishingCost += 3000.0 * copies;
      } else if (lowerFinishing.contains('laminate')) {
        finishingCost += 2000.0 * pages * copies;
      }
    }

    // Subtotal before double-sided discount
    final double subtotalBeforeDiscount = printPrice + colorSurcharge + finishingCost;

    // 4. Double-sided discount (-10% of subtotal)
    final double doubleSidedDiscount = isDoubleSided ? (subtotalBeforeDiscount * 0.1) : 0.0;

    final double finalSubtotal = subtotalBeforeDiscount - doubleSidedDiscount;

    return PriceBreakdown(
      basePrice: printPrice,
      colorSurcharge: colorSurcharge,
      finishingCost: finishingCost,
      doubleSidedDiscount: doubleSidedDiscount,
      deliveryFee: 0.0,
      subtotal: finalSubtotal,
      totalPrice: finalSubtotal,
    );
  }

  /// Calculate the overall order pricing by aggregating all item breakdowns and adding a delivery fee
  PriceBreakdown calculateOrderPrice({
    required List<OrderItemModel> items,
    required String deliveryType,
    double deliveryFee = 10000.0, // default flat fee Rp 10.000 (range flat Rp5.000-15.000)
  }) {
    double totalBasePrice = 0.0;
    double totalColorSurcharge = 0.0;
    double totalFinishingCost = 0.0;
    double totalDoubleSidedDiscount = 0.0;
    double totalItemsSubtotal = 0.0;

    for (final item in items) {
      // Re-calculate the breakdown of each item to aggregate it correctly
      // (assuming item.subtotal is already calculated or needs to be aggregated)
      totalItemsSubtotal += item.subtotal;
    }

    final double actualDeliveryFee = (deliveryType.toLowerCase() == 'delivery') ? deliveryFee : 0.0;
    final double totalPrice = totalItemsSubtotal + actualDeliveryFee;

    return PriceBreakdown(
      basePrice: totalBasePrice, // aggregated bases can be computed if necessary
      colorSurcharge: totalColorSurcharge,
      finishingCost: totalFinishingCost,
      doubleSidedDiscount: totalDoubleSidedDiscount,
      deliveryFee: actualDeliveryFee,
      subtotal: totalItemsSubtotal,
      totalPrice: totalPrice,
    );
  }
}

/// Riverpod provider for PriceCalculatorService
final priceCalculatorServiceProvider = Provider<PriceCalculatorService>((ref) {
  return PriceCalculatorService();
});
