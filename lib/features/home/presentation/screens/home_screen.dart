import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../notifications/presentation/providers/notification_provider.dart';
import '../../../orders/presentation/providers/order_provider.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../widgets/active_order_banner.dart';
import '../widgets/greeting_header.dart';
import '../widgets/home_search_bar.dart';
import '../widgets/nearby_shop_list.dart';
import '../widgets/promo_banner.dart';
import '../widgets/service_category_grid.dart';
import '../widgets/template_recommend_grid.dart';

/// Halaman utama (Home Screen) aplikasi GoPrint.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final profileState = ref.watch(profileNotifierProvider);
    final userName = profileState.user?.name ?? 'Pengguna';
    final unreadCount = ref.watch(unreadNotificationsCountProvider);
    final activeOrderAsync = ref.watch(activeOrderProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ─── App Bar & Header ─────────────────────────────────────
          SliverAppBar(
            expandedHeight: 170,
            toolbarHeight: 0, // Menghilangkan area kosong di atas search bar saat di-scroll
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: isDark
                      ? AppColors.headerGradientDark
                      : AppColors.headerGradient,
                ),
                child: SafeArea(
                  child: SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        GreetingHeader(
                          name: userName,
                          unreadNotifications: unreadCount,
                          onNotificationTap: () => context.go('/notifications'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(56),
              child: HomeSearchBar(
                onTap: () => context.push('/shops'),
              ),
            ),
          ),

          // Spacing below search bar
          const SliverToBoxAdapter(child: SizedBox(height: 12)),

          // ─── Main Content (SliverList) ────────────────────────────
          SliverList(
            delegate: SliverChildListDelegate([
              activeOrderAsync.when(
                data: (activeOrder) {
                  if (activeOrder == null) return const SizedBox.shrink();

                  final orderId = activeOrder['id'] as String;
                  final status = activeOrder['status'] as String;
                  final shopName = (activeOrder['shops'] as Map?)?['name'] as String? ?? 'Toko';

                  String statusText = 'Diproses';
                  String estimateText = 'Sedang diproses oleh toko';

                  switch (status) {
                    case 'pending':
                      statusText = 'Menunggu';
                      estimateText = 'Menunggu konfirmasi toko';
                      break;
                    case 'confirmed':
                      statusText = 'Dikonfirmasi';
                      estimateText = 'Pesanan dikonfirmasi';
                      break;
                    case 'processing':
                      statusText = 'Diproses';
                      estimateText = 'Sedang dikerjakan';
                      break;
                    case 'ready':
                      statusText = 'Siap';
                      estimateText = 'Siap diambil/dikirim';
                      break;
                  }

                  return ActiveOrderBanner(
                    orderNumber: '#${orderId.substring(0, 8).toUpperCase()}',
                    shopName: shopName,
                    statusText: statusText,
                    estimateText: estimateText,
                    orderId: orderId,
                  );
                },
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (e, _) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 12),
              const PromoBanner(),
              const SizedBox(height: 12),
              const ServiceCategoryGrid(),
              SectionHeader(
                title: 'Toko Terdekat',
                onSeeAll: () => context.push('/shops'),
              ),
              const NearbyShopList(),
              const SizedBox(height: 12),
              SectionHeader(
                title: 'Template Populer',
                onSeeAll: () => context.go('/templates'),
              ),
              const TemplateRecommendGrid(),
              const SizedBox(height: 40),
            ]),
          ),
        ],
      ),
    );
  }
}
