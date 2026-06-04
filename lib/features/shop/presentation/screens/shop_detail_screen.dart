import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../data/mock_shops.dart';
import '../widgets/operating_hours_widget.dart';
import '../widgets/service_menu_card.dart';
import '../widgets/shop_info_header.dart';

/// Layar untuk menampilkan detail lengkap toko.
class ShopDetailScreen extends StatefulWidget {
  const ShopDetailScreen({
    required this.shopId,
    super.key,
  });

  final String shopId;

  @override
  State<ShopDetailScreen> createState() => _ShopDetailScreenState();
}

class _ShopDetailScreenState extends State<ShopDetailScreen> {
  int _selectedTab = 0; // 0 = Layanan, 1 = Info, 2 = Ulasan

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Ambil data toko sesuai ID, fallback ke toko pertama jika tidak ditemukan
    final shop = MockShops.shops.firstWhere(
      (s) => s.id == widget.shopId,
      orElse: () => MockShops.shops.first,
    );

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Header Bergambar (ShopInfoHeader) ──────────────────────
            ShopInfoHeader(shop: shop),

            // ─── Tab Selector (Layanan | Info | Ulasan) ─────────────────
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  _buildTabButton(0, 'Layanan', Icons.print_rounded),
                  _buildTabButton(1, 'Info', Icons.info_outline_rounded),
                  _buildTabButton(2, 'Ulasan', Icons.star_border_rounded),
                ],
              ),
            ),

            // ─── Tab Content ─────────────────────────────────────────────
            _buildTabContent(shop),

            // Spacing bawah
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // Helper untuk membangun button tab segmen
  Widget _buildTabButton(int index, String label, IconData icon) {
    final isSelected = _selectedTab == index;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? AppColors.darkElevated : Colors.white)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: isDark ? 0.2 : 0.05,
                      ),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected
                    ? (isDark ? AppColors.teal300 : AppColors.teal700)
                    : (isDark ? AppColors.darkMutedText : AppColors.lightSubtleText),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? (isDark ? AppColors.teal300 : AppColors.teal700)
                      : (isDark ? AppColors.darkMutedText : AppColors.lightSubtleText),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Membangun konten sesuai tab yang aktif
  Widget _buildTabContent(Shop shop) {
    switch (_selectedTab) {
      case 0:
        return _buildServicesTab(shop);
      case 1:
        return _buildInfoTab(shop);
      case 2:
        return _buildReviewsTab(shop);
      default:
        return const SizedBox.shrink();
    }
  }

  // 1. Tab Konten: Layanan
  Widget _buildServicesTab(Shop shop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Text(
            'Pilih Layanan',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: shop.services.length,
          itemBuilder: (context, index) {
            final service = shop.services[index];
            return ServiceMenuCard(
              service: service,
              onTap: () {
                // TODO: Mulai alur checkout (SelectServiceScreen / Order Flow)
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Layanan "${service.name}" dipilih (Alur pemesanan menyusul)',
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  // 2. Tab Konten: Info Toko
  Widget _buildInfoTab(Shop shop) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Deskripsi
          Text(
            'Tentang Toko',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            shop.description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? AppColors.darkMutedText : AppColors.lightSubtleText,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),

          // Alamat
          _buildInfoRow(
            Icons.location_on_outlined,
            'Alamat',
            shop.address,
          ),
          const SizedBox(height: 16),

          // Kontak
          _buildInfoRow(
            Icons.phone_outlined,
            'Nomor Telepon',
            shop.phone,
            action: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              minimumSize: Size.zero,
            ),
            actionWidget: InkWell(
              onTap: () {}, // WhatsApp / call Integration
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.teal800.withValues(alpha: 0.2)
                      : const Color(0xFFE0F2F1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.chat_bubble_outline_rounded,
                  color: isDark ? AppColors.teal300 : AppColors.teal700,
                  size: 18,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Jam Operasional Widget
          OperatingHoursWidget(operatingHours: shop.operatingHours),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    ButtonStyle? action,
    Widget? actionWidget,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: isDark ? AppColors.teal300 : AppColors.teal700,
            size: 20,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: isDark ? AppColors.darkMutedText : AppColors.lightSubtleText,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        if (actionWidget != null) ...[
          const SizedBox(width: 8),
          actionWidget,
        ],
      ],
    );
  }

  // 3. Tab Konten: Ulasan
  Widget _buildReviewsTab(Shop shop) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (shop.reviews.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Text(
            'Belum ada ulasan untuk toko ini.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? AppColors.darkMutedText : AppColors.lightSubtleText,
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Ringkasan Rating di bagian atas
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          shop.rating.toString(),
                          style: theme.textTheme.displayLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: isDark ? AppColors.teal300 : AppColors.teal700,
                            height: 1,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '/ 5.0',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: isDark ? AppColors.darkMutedText : AppColors.lightSubtleText,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: List.generate(5, (index) {
                        final starVal = index + 1;
                        return Icon(
                          Icons.star_rounded,
                          size: 18,
                          color: starVal <= shop.rating.floor()
                              ? AppColors.warningDark
                              : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                        );
                      }),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Berdasarkan ${shop.reviews.length} ulasan',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: isDark ? AppColors.darkMutedText : AppColors.lightSubtleText,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                // Visualisasi Bar Bintang
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildRatingBar(5, 0.8),
                    const SizedBox(height: 4),
                    _buildRatingBar(4, 0.2),
                    const SizedBox(height: 4),
                    _buildRatingBar(3, 0.0),
                    const SizedBox(height: 4),
                    _buildRatingBar(2, 0.0),
                    const SizedBox(height: 4),
                    _buildRatingBar(1, 0.0),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Daftar Ulasan User
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: shop.reviews.length,
          separatorBuilder: (context, index) => const Divider(),
          itemBuilder: (context, index) {
            final review = shop.reviews[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Avatar
                      CircleAvatar(
                        radius: 18,
                        backgroundImage: NetworkImage(review.avatarUrl),
                        backgroundColor: isDark ? AppColors.darkElevated : AppColors.lightSurface,
                        child: Text(
                          review.name[0],
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Nama & Tanggal
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              review.name,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              review.date,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: isDark ? AppColors.darkMutedText : AppColors.lightSubtleText,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Rating bintang
                      Row(
                        children: List.generate(5, (starIndex) {
                          return Icon(
                            Icons.star_rounded,
                            size: 14,
                            color: starIndex < review.rating.floor()
                                ? AppColors.warningDark
                                : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                          );
                        }),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Komentar Ulasan
                  Text(
                    review.comment,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  // Row bar persentase rating
  Widget _buildRatingBar(int stars, double pct) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      children: [
        Text(
          stars.toString(),
          style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(width: 4),
        const Icon(Icons.star_rounded, size: 10, color: AppColors.warning),
        const SizedBox(width: 6),
        Container(
          width: 80,
          height: 6,
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            borderRadius: BorderRadius.circular(3),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: 80 * pct,
              height: 6,
              decoration: BoxDecoration(
                color: AppColors.warning,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
