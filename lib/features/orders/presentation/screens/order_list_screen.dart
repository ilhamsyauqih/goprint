import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../data/order_flow_manager.dart';
import '../../data/order_model.dart';
import '../widgets/order_card.dart';

/// Layar Daftar Pesanan Pengguna dengan tab Aktif / Selesai / Dibatalkan.
class OrderListScreen extends StatefulWidget {
  const OrderListScreen({super.key});

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  final OrderFlowManager _orderFlow = OrderFlowManager.instance;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final allOrders = _orderFlow.orders;

    // Filter pesanan berdasarkan tab status
    final activeOrders = allOrders.where((o) =>
        o.status == OrderStatus.pending ||
        o.status == OrderStatus.confirmed ||
        o.status == OrderStatus.processing ||
        o.status == OrderStatus.ready).toList();

    final completedOrders = allOrders.where((o) => o.status == OrderStatus.completed).toList();
    final cancelledOrders = allOrders.where((o) => o.status == OrderStatus.cancelled).toList();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
        appBar: CustomAppBar(
          title: 'Pesanan Saya',
          showBackButton: false,
          bottom: TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white.withValues(alpha: 0.65),
            indicatorColor: isDark ? AppColors.teal300 : AppColors.teal200,
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorWeight: 3.0,
            labelStyle: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            unselectedLabelStyle: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
            tabs: const [
              Tab(text: 'Aktif'),
              Tab(text: 'Selesai'),
              Tab(text: 'Dibatalkan'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildTabContent(
              orders: activeOrders,
              emptyIcon: Icons.receipt_long_rounded,
              emptyTitle: 'Belum Ada Pesanan Aktif',
              emptySubtitle: 'Pesanan cetak dokumen Anda yang sedang aktif diproses akan muncul di sini.',
              showShopButton: true,
              theme: theme,
              isDark: isDark,
            ),
            _buildTabContent(
              orders: completedOrders,
              emptyIcon: Icons.task_alt_rounded,
              emptyTitle: 'Belum Ada Riwayat Selesai',
              emptySubtitle: 'Riwayat pesanan cetak dokumen Anda yang telah selesai akan disimpan di sini.',
              showShopButton: false,
              theme: theme,
              isDark: isDark,
            ),
            _buildTabContent(
              orders: cancelledOrders,
              emptyIcon: Icons.cancel_presentation_rounded,
              emptyTitle: 'Tidak Ada Pesanan Batal',
              emptySubtitle: 'Daftar pesanan Anda yang dibatalkan atau ditolak akan ditampilkan di sini.',
              showShopButton: false,
              theme: theme,
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent({
    required List<OrderModel> orders,
    required IconData emptyIcon,
    required String emptyTitle,
    required String emptySubtitle,
    required bool showShopButton,
    required ThemeData theme,
    required bool isDark,
  }) {
    if (orders.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Ilustrasi lingkaran dengan icon kustom
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.teal800.withValues(alpha: 0.15)
                      : AppColors.teal700.withValues(alpha: 0.06),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: (isDark ? AppColors.teal300 : AppColors.teal700).withValues(alpha: 0.2),
                    width: 2,
                  ),
                ),
                child: Icon(
                  emptyIcon,
                  size: 44,
                  color: isDark ? AppColors.teal300 : AppColors.teal700,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                emptyTitle,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                emptySubtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark ? AppColors.darkMutedText : AppColors.lightSubtleText,
                  height: 1.45,
                ),
                textAlign: TextAlign.center,
              ),
              if (showShopButton) ...[
                const SizedBox(height: 28),
                ElevatedButton.icon(
                  onPressed: () => context.go('/shops'),
                  icon: const Icon(Icons.search_rounded, size: 18),
                  label: const Text('Cari Toko Cetak'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? AppColors.teal300 : AppColors.teal700,
                    foregroundColor: isDark ? AppColors.teal900 : Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    // List view data kartu pesanan
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        return OrderCard(order: orders[index]);
      },
    );
  }
}
