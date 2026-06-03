import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';

/// Card banner untuk pesanan yang sedang aktif.
class ActiveOrderBanner extends StatelessWidget {
  const ActiveOrderBanner({
    required this.orderNumber,
    required this.shopName,
    required this.statusText,
    required this.estimateText,
    this.statusColor,
    super.key,
  });

  final String orderNumber;
  final String shopName;
  final String statusText;
  final String estimateText;
  final Color? statusColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final effectiveStatusColor =
        statusColor ?? (isDark ? AppColors.warningDark : AppColors.warning);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: InkWell(
        onTap: () {
          // Navigate to order details (placeholder)
          context.push('/orders/dummy_active');
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkElevated : AppColors.lightCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: effectiveStatusColor.withValues(alpha: 0.5),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: effectiveStatusColor.withValues(alpha: 0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Colored left indicator
              Container(
                width: 6,
                height: 80,
                decoration: BoxDecoration(
                  color: effectiveStatusColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: effectiveStatusColor.withValues(
                                alpha: 0.15,
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              statusText.toUpperCase(),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: effectiveStatusColor,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          Text(
                            orderNumber,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: isDark
                                  ? AppColors.darkMutedText
                                  : AppColors.lightSubtleText,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        shopName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.schedule_rounded,
                            size: 14,
                            color: effectiveStatusColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            estimateText,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: effectiveStatusColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(right: 16),
                child: Icon(Icons.chevron_right_rounded),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
