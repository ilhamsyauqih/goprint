import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/mock_shops.dart';

/// Komponen: [ShopInfoHeader] — header bergambar + gradient overlay + nama toko
class ShopInfoHeader extends StatelessWidget {
  const ShopInfoHeader({
    required this.shop,
    super.key,
  });

  final Shop shop;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(24),
        bottomRight: Radius.circular(24),
      ),
      child: Stack(
        children: [
          // ─── Foto Toko (Background) ──────────────────────────────────
          Container(
            height: 240,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: AppColors.teal900,
            ),
            child: Image.network(
              shop.imageUrl,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    color: Colors.white.withValues(alpha: 0.5),
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Center(
                  child: Icon(
                    Icons.storefront_rounded,
                    color: Colors.white.withValues(alpha: 0.3),
                    size: 64,
                  ),
                );
              },
            ),
          ),

          // ─── Gradient Overlay ────────────────────────────────────────
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.4),
                    Colors.black.withValues(alpha: 0.1),
                    Colors.black.withValues(alpha: 0.85),
                  ],
                  stops: const [0.0, 0.4, 1.0],
                ),
              ),
            ),
          ),

          // ─── Informasi Toko (Bottom) ─────────────────────────────────
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Badge Status (Buka/Tutup)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: shop.isOpen
                        ? (isDark ? AppColors.successDark : AppColors.success)
                        : (isDark ? AppColors.errorDark : AppColors.error),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    shop.isOpen ? 'BUKA' : 'TUTUP',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Nama Toko
                Text(
                  shop.name,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),

                // Rating & Jarak
                Row(
                  children: [
                    Icon(
                      Icons.star_rounded,
                      color: AppColors.warningDark,
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      shop.rating.toString(),
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: Colors.white60,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.location_on_rounded,
                      color: Colors.white70,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      shop.distance,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ─── Tombol Kembali (Top Left) ────────────────────────────────
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            child: CircleAvatar(
              backgroundColor: Colors.black.withValues(alpha: 0.4),
              foregroundColor: Colors.white,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
