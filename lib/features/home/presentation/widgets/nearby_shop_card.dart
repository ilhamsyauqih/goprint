import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';

/// Kartu toko fotokopi terdekat.
class NearbyShopCard extends StatelessWidget {
  const NearbyShopCard({
    required this.id,
    required this.name,
    required this.rating,
    required this.distance,
    required this.isOpen,
    required this.imageUrl,
    super.key,
  });

  final String id;
  final String name;
  final double rating;
  final String distance;
  final bool isOpen;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: 220,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            context.push('/shop/$id');
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image header
              SizedBox(
                height: 110,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Load actual NetworkImage if imageUrl is not empty, otherwise fallback
                    imageUrl.isNotEmpty
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (ctx, e, st) => Container(
                              decoration: const BoxDecoration(color: AppColors.teal900),
                              child: Icon(
                                Icons.storefront_rounded,
                                color: Colors.white.withValues(alpha: 0.2),
                                size: 48,
                              ),
                            ),
                            loadingBuilder: (ctx, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                decoration: const BoxDecoration(color: AppColors.teal900),
                                child: Icon(
                                  Icons.storefront_rounded,
                                  color: Colors.white.withValues(alpha: 0.2),
                                  size: 48,
                                ),
                              );
                            },
                          )
                        : Container(
                            decoration: const BoxDecoration(color: AppColors.teal900),
                            child: Icon(
                              Icons.storefront_rounded,
                              color: Colors.white.withValues(alpha: 0.2),
                              size: 48,
                            ),
                          ),
                    // Gradient overlay
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0),
                            Colors.black.withValues(alpha: 0.7),
                          ],
                        ),
                      ),
                    ),
                    // Rating & Distance badge
                    Positioned(
                      bottom: 8,
                      left: 12,
                      child: Row(
                        children: [
                          Icon(
                            Icons.star_rounded,
                            color: AppColors.warningDark,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            rating.toString(),
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 4,
                            height: 4,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            distance,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: isOpen ? AppColors.success : AppColors.error,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isOpen ? 'Buka' : 'Tutup',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: isOpen
                                ? (isDark
                                      ? AppColors.successDark
                                      : AppColors.success)
                                : (isDark
                                      ? AppColors.errorDark
                                      : AppColors.error),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.teal800.withValues(alpha: 0.3)
                                : const Color(0xFFE0F2F1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Print & Jilid',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: isDark
                                  ? AppColors.teal300
                                  : AppColors.teal700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
