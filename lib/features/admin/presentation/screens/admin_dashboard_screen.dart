import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../orders/data/order_flow_manager.dart';
import '../../../orders/data/order_model.dart';
import '../widgets/admin_drawer.dart';
import '../widgets/period_filter_chip.dart';
import '../widgets/recent_order_list.dart';
import '../widgets/revenue_line_chart.dart';
import '../widgets/service_bar_chart.dart';
import '../widgets/stat_card.dart';

/// Layar utama dasbor admin (AdminDashboardScreen) untuk memantau aktivitas toko secara terpusat.
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  String _selectedPeriod = '7 Hari';

  String _formatCurrency(int value) {
    return 'Rp ${value.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => "${m[1]}.")}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Kalkulasi data statistik real-time dari OrderFlowManager
    final allOrders = OrderFlowManager.instance.orders;
    final totalOrders = allOrders.length;
    final totalRevenue = allOrders
        .where((o) => o.status == OrderStatus.completed)
        .fold<int>(0, (sum, o) => sum + o.totalFee);
    final totalPending = allOrders.where((o) => o.status == OrderStatus.pending).length;
    final totalProcessing = allOrders.where((o) => o.status == OrderStatus.processing).length;

    // Simulasi penyesuaian metrik berdasarkan periode yang dipilih agar terlihat dinamis
    String ordersVal;
    String revenueVal;
    String pendingVal;
    String processingVal;
    List<String> trends;

    if (_selectedPeriod == 'Hari Ini') {
      ordersVal = '3';
      revenueVal = 'Rp 97.000';
      pendingVal = '1';
      processingVal = '1';
      trends = ['+15% dari kemarin', '+18.4% dari kemarin', '1 baru', '1 berjalan'];
    } else if (_selectedPeriod == '7 Hari') {
      ordersVal = totalOrders.toString();
      revenueVal = _formatCurrency(totalRevenue);
      pendingVal = totalPending.toString();
      processingVal = totalProcessing.toString();
      trends = ['+12.4% dari minggu lalu', '+8.2% dari minggu lalu', '$totalPending baru', '$totalProcessing berjalan'];
    } else if (_selectedPeriod == '30 Hari') {
      ordersVal = (totalOrders * 3.5).toStringAsFixed(0);
      revenueVal = _formatCurrency((totalRevenue * 3.2).toInt());
      pendingVal = (totalPending + 1).toString();
      processingVal = (totalProcessing + 2).toString();
      trends = ['+22.5% dari bulan lalu', '+14.8% dari bulan lalu', '${totalPending + 1} baru', '${totalProcessing + 2} berjalan'];
    } else {
      // Kustom
      ordersVal = totalOrders.toString();
      revenueVal = _formatCurrency(totalRevenue);
      pendingVal = totalPending.toString();
      processingVal = totalProcessing.toString();
      trends = ['+10% dari periode lalu', '+6.5% dari periode lalu', '$totalPending baru', '$totalProcessing berjalan'];
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      drawer: const AdminDrawer(currentRoute: '/admin/dashboard'),
      appBar: CustomAppBar(
        title: 'Dashboard Admin',
        showBackButton: false,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu_rounded, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Salam Pembuka Admin
            Text(
              'Selamat Datang, Surya Gemilang!',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Pantau kinerja toko cetak Anda secara real-time di sini.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? AppColors.darkMutedText : AppColors.lightSubtleText,
              ),
            ),
            const SizedBox(height: 20),

            // Chip Pilihan Periode (Filter)
            PeriodFilterChip(
              selectedPeriod: _selectedPeriod,
              onPeriodSelected: (period) {
                setState(() {
                  _selectedPeriod = period;
                });
              },
            ),
            const SizedBox(height: 20),

            // Grid Kartu Statistik 2x2
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.25,
              children: [
                StatCard(
                  title: 'Total Pesanan',
                  value: ordersVal,
                  icon: Icons.receipt_long_rounded,
                  iconColor: Colors.blue.shade600,
                  trendText: trends[0],
                  isPositiveTrend: true,
                ),
                StatCard(
                  title: 'Pendapatan',
                  value: revenueVal,
                  icon: Icons.payments_rounded,
                  iconColor: Colors.green.shade600,
                  trendText: trends[1],
                  isPositiveTrend: true,
                ),
                StatCard(
                  title: 'Menunggu',
                  value: pendingVal,
                  icon: Icons.hourglass_empty_rounded,
                  iconColor: Colors.orange.shade600,
                  trendText: trends[2],
                  isPositiveTrend: false,
                ),
                StatCard(
                  title: 'Diproses',
                  value: processingVal,
                  icon: Icons.print_rounded,
                  iconColor: Colors.teal.shade600,
                  trendText: trends[3],
                  isPositiveTrend: true,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Grafik Garis Tren Pendapatan
            RevenueLineChart(period: _selectedPeriod),
            const SizedBox(height: 20),

            // Grafik Batang Distribusi Layanan Terlaris
            ServiceBarChart(period: _selectedPeriod),
            const SizedBox(height: 20),

            // Daftar Pesanan Masuk Terbaru (Real-time)
            const RecentOrderList(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
