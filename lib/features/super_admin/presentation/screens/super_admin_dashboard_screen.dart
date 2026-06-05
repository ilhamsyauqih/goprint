import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../data/super_admin_manager.dart';
import '../widgets/super_admin_drawer.dart';

class SuperAdminDashboardScreen extends StatefulWidget {
  const SuperAdminDashboardScreen({super.key});

  @override
  State<SuperAdminDashboardScreen> createState() => _SuperAdminDashboardScreenState();
}

class _SuperAdminDashboardScreenState extends State<SuperAdminDashboardScreen> {
  String _selectedPeriod = '7 Hari';

  String _formatCurrency(int value) {
    return 'Rp ${value.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => "${m[1]}.")}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final manager = SuperAdminManager.instance;

    return ListenableBuilder(
      listenable: manager,
      builder: (context, _) {
        final pendingPayouts = manager.payouts.where((p) => p.status == 'pending').toList();

        // Data statistik simulasi
        int totalGmv = 3680000;
        double feePercent = manager.config.platformFee;
        int totalCommission = (totalGmv * (feePercent / 100)).toInt();
        int activeShopsCount = 3; // Dari mock shops yang disetujui/aktif
        int totalUsersCount = manager.users.length;

        // Sesuaikan visual berdasarkan periode
        if (_selectedPeriod == 'Hari Ini') {
          totalGmv = 350000;
          totalCommission = (totalGmv * (feePercent / 100)).toInt();
        } else if (_selectedPeriod == '30 Hari') {
          totalGmv = 14850000;
          totalCommission = (totalGmv * (feePercent / 100)).toInt();
        }

        return Scaffold(
          backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
          drawer: const SuperAdminDrawer(currentRoute: '/superadmin/dashboard'),
          appBar: CustomAppBar(
            title: 'Dashboard Global',
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
                // Welcome header
                Text(
                  'Halo, Super Admin!',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Kelola performa keuangan, mitra percetakan, dan sistem GoPrint secara global.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark ? AppColors.darkMutedText : AppColors.lightSubtleText,
                  ),
                ),
                const SizedBox(height: 20),

                // Period Filter
                _buildPeriodFilter(),
                const SizedBox(height: 20),

                // 2x2 Stat Grid
                _buildStatGrid(totalGmv, totalCommission, activeShopsCount, totalUsersCount, isDark),
                const SizedBox(height: 20),

                // Revenue and Transaction Chart
                _buildRevenueChart(isDark, totalCommission),
                const SizedBox(height: 20),

                // Pending Withdrawals Section
                _buildPendingPayoutsSection(pendingPayouts, isDark, theme),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPeriodFilter() {
    final periods = ['Hari Ini', '7 Hari', '30 Hari'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: periods.map((period) {
          final isSelected = _selectedPeriod == period;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(
                period,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.purple.shade900,
                  fontWeight: FontWeight.bold,
                ),
              ),
              selected: isSelected,
              selectedColor: Colors.purple.shade700,
              backgroundColor: Colors.purple.shade50,
              onSelected: (val) {
                if (val) {
                  setState(() {
                    _selectedPeriod = period;
                  });
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStatGrid(int gmv, int commission, int shopsCount, int usersCount, bool isDark) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.3,
      children: [
        _buildStatCard(
          title: 'Total GMV',
          value: _formatCurrency(gmv),
          icon: Icons.monetization_on_rounded,
          iconColor: Colors.indigo.shade600,
          subtitle: 'Gross Merch Volume',
          isDark: isDark,
        ),
        _buildStatCard(
          title: 'Pendapatan Fee',
          value: _formatCurrency(commission),
          icon: Icons.payments_rounded,
          iconColor: Colors.purple.shade600,
          subtitle: '${SuperAdminManager.instance.config.platformFee}% Biaya Layanan',
          isDark: isDark,
        ),
        _buildStatCard(
          title: 'Mitra Aktif',
          value: '$shopsCount Toko',
          icon: Icons.store_mall_directory_rounded,
          iconColor: Colors.teal.shade600,
          subtitle: 'Toko mitra yang disetujui',
          isDark: isDark,
        ),
        _buildStatCard(
          title: 'Total Pengguna',
          value: '$usersCount Akun',
          icon: Icons.people_alt_rounded,
          iconColor: Colors.orange.shade700,
          subtitle: 'Pelanggan & Admin Toko',
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
    required String subtitle,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              Icon(icon, color: iconColor, size: 22),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 10, color: Colors.grey),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueChart(bool isDark, int commission) {
    final activeColor = isDark ? Colors.purple.shade300 : Colors.purple.shade700;

    // Dummy spots data
    final spots = _selectedPeriod == 'Hari Ini'
        ? const [
            FlSpot(0, 12000),
            FlSpot(1, 18000),
            FlSpot(2, 8000),
            FlSpot(3, 22000),
            FlSpot(4, 30000),
          ]
        : _selectedPeriod == '30 Hari'
            ? const [
                FlSpot(0, 320000),
                FlSpot(1, 410000),
                FlSpot(2, 390000),
                FlSpot(3, 485000),
              ]
            : const [
                FlSpot(0, 45000),
                FlSpot(1, 62000),
                FlSpot(2, 51000),
                FlSpot(3, 78000),
                FlSpot(4, 91000),
                FlSpot(5, 85000),
                FlSpot(6, 40000),
              ];

    final bottomLabels = _selectedPeriod == 'Hari Ini'
        ? const ['08:00', '10:00', '12:00', '14:00', '16:00']
        : _selectedPeriod == '30 Hari'
            ? const ['Mgg 1', 'Mgg 2', 'Mgg 3', 'Mgg 4']
            : const ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tren Pendapatan Platform',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              Text(
                'Total: ${_formatCurrency(commission)}',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  color: activeColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (val) => FlLine(
                    color: isDark ? Colors.white10 : Colors.grey.shade200,
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 38,
                      getTitlesWidget: (value, meta) {
                        String label = '';
                        if (value >= 1000000) {
                          label = '${(value / 1000000).toStringAsFixed(1)}jt';
                        } else if (value >= 1000) {
                          label = '${(value / 1000).toStringAsFixed(0)}rb';
                        } else {
                          label = value.toStringAsFixed(0);
                        }
                        return Text(
                          label,
                          style: const TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 24,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx >= 0 && idx < bottomLabels.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 6.0),
                            child: Text(
                              bottomLabels[idx],
                              style: const TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold),
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: (spots.length - 1).toDouble(),
                minY: 0,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    gradient: LinearGradient(
                      colors: [activeColor, Colors.purple.shade400],
                    ),
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          activeColor.withValues(alpha: 0.15),
                          activeColor.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingPayoutsSection(List<PayoutRequest> requests, bool isDark, ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Menunggu Verifikasi Payout',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              TextButton(
                onPressed: () => context.go('/superadmin/payouts'),
                child: Text(
                  'Lihat Semua',
                  style: TextStyle(
                    color: isDark ? Colors.purple.shade300 : Colors.purple.shade700,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (requests.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.check_circle_outline_rounded, color: Colors.green.shade600, size: 40),
                    const SizedBox(height: 8),
                    const Text(
                      'Semua request penarikan dana selesai diproses!',
                      style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: requests.length,
              itemBuilder: (context, index) {
                final req = requests[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.black26 : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? Colors.white10 : Colors.grey.shade200,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              req.shopName,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${req.bankName} • ${req.accountNumber}',
                              style: const TextStyle(fontSize: 11, color: Colors.grey),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Diajukan: ${req.requestDate}',
                              style: const TextStyle(fontSize: 10, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            _formatCurrency(req.amount),
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 13,
                              color: isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText,
                            ),
                          ),
                          const SizedBox(height: 6),
                          ElevatedButton(
                            onPressed: () => context.go('/superadmin/payouts/${req.id}'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isDark ? Colors.purple.shade800 : Colors.purple.shade50,
                              foregroundColor: isDark ? Colors.white : Colors.purple.shade900,
                              minimumSize: const Size(60, 26),
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              elevation: 0,
                            ),
                            child: const Text('Proses', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
