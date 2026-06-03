import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/section_header.dart';
import '../widgets/active_order_banner.dart';
import '../widgets/greeting_header.dart';
import '../widgets/home_search_bar.dart';
import '../widgets/nearby_shop_list.dart';
import '../widgets/promo_banner.dart';
import '../widgets/service_category_grid.dart';
import '../widgets/template_recommend_grid.dart';

/// Halaman utama (Home Screen) aplikasi GoPrint.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ─── App Bar & Header ─────────────────────────────────────
          SliverAppBar(
            expandedHeight: 140,
            toolbarHeight: 0, // Menghilangkan area kosong di atas search bar saat di-scroll
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: AppColors.teal700,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: isDark
                      ? AppColors.headerGradientDark
                      : AppColors.headerGradient,
                ),
                child: SafeArea(
                  child: Column(
                    children: [
                      GreetingHeader(
                        name: 'Ilham',
                        unreadNotifications: 3,
                        onNotificationTap: () => context.go('/notifications'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(28),
              child: Transform.translate(
                offset: const Offset(0, 24),
                child: const HomeSearchBar(),
              ),
            ),
          ),
          
          // Padding kompensasi untuk search bar yang floating
          const SliverToBoxAdapter(
            child: SizedBox(height: 36),
          ),

          // ─── Main Content (SliverList) ────────────────────────────
          SliverList(
            delegate: SliverChildListDelegate(
              [
                const ActiveOrderBanner(
                  orderNumber: '#GP-1092',
                  shopName: 'Fotokopi Surya Gemilang',
                  statusText: 'Diproses',
                  estimateText: 'Selesai pukul 14:30',
                ),
                const SizedBox(height: 12),
                const PromoBanner(),
                const SizedBox(height: 12),
                const ServiceCategoryGrid(),
                SectionHeader(
                  title: 'Toko Terdekat',
                  onSeeAll: () {},
                ),
                const NearbyShopList(),
                const SizedBox(height: 12),
                SectionHeader(
                  title: 'Template Populer',
                  onSeeAll: () => context.go('/templates'),
                ),
                const TemplateRecommendGrid(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

