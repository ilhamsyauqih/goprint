import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../widgets/admin_drawer.dart';
import '../widgets/revenue_line_chart.dart';
import '../widgets/service_bar_chart.dart';

class AdminReportScreen extends StatefulWidget {
  const AdminReportScreen({super.key});

  @override
  State<AdminReportScreen> createState() => _AdminReportScreenState();
}

class _AdminReportScreenState extends State<AdminReportScreen> {
  String _selectedPeriod = '7 Hari';
  DateTimeRange? _customDateRange;

  String _formatCurrency(int value) {
    return 'Rp ${value.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => "${m[1]}.")}';
  }

  String _getPeriodText() {
    if (_selectedPeriod == 'Custom' && _customDateRange != null) {
      final start = _customDateRange!.start;
      final end = _customDateRange!.end;
      return '${start.day}/${start.month}/${start.year} - ${end.day}/${end.month}/${end.year}';
    }
    return _selectedPeriod;
  }

  // Menampilkan date range picker kustom
  Future<void> _selectCustomDateRange() async {
    final now = DateTime.now();
    final pickedRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 1),
      lastDate: now,
      initialDateRange: _customDateRange ??
          DateTimeRange(
            start: now.subtract(const Duration(days: 7)),
            end: now,
          ),
      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Theme(
          data: isDark
              ? ThemeData.dark().copyWith(
                  colorScheme: const ColorScheme.dark(
                    primary: AppColors.teal300,
                    onPrimary: AppColors.teal900,
                    surface: AppColors.darkSurface,
                    onSurface: AppColors.darkPrimaryText,
                  ),
                )
              : ThemeData.light().copyWith(
                  colorScheme: const ColorScheme.light(
                    primary: AppColors.teal700,
                    onPrimary: Colors.white,
                    surface: Colors.white,
                    onSurface: AppColors.lightPrimaryText,
                  ),
                ),
          child: child!,
        );
      },
    );

    if (pickedRange != null) {
      setState(() {
        _selectedPeriod = 'Custom';
        _customDateRange = pickedRange;
      });
    }
  }

  void _exportReport() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        final isDark = Theme.of(dialogContext).brightness == Brightness.dark;
        return Dialog(
          backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  color: isDark ? AppColors.teal300 : AppColors.teal700,
                ),
                const SizedBox(height: 20),
                Text(
                  'Mengekspor Laporan...',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sedang memproses data laporan periode ${_getPeriodText()}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.darkMutedText : AppColors.lightSubtleText,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    // Simulasi loading ekspor selama 1.5 detik
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        Navigator.of(context).pop(); // Tutup loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Laporan periode ${_getPeriodText()} berhasil diekspor ke folder Downloads!',
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Data statistik dinamis berdasarkan filter
    int totalRevenue = 1560000;
    int aov = 42500;
    double completionRate = 94.2;
    int totalOrders = 38;

    if (_selectedPeriod == 'Hari Ini') {
      totalRevenue = 97000;
      aov = 32300;
      completionRate = 100.0;
      totalOrders = 3;
    } else if (_selectedPeriod == '7 Hari') {
      totalRevenue = 545000;
      aov = 36300;
      completionRate = 92.5;
      totalOrders = 15;
    } else if (_selectedPeriod == '30 Hari') {
      totalRevenue = 1860000;
      aov = 44500;
      completionRate = 96.0;
      totalOrders = 42;
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
        drawer: const AdminDrawer(currentRoute: '/admin/reports'),
        appBar: CustomAppBar(
          title: 'Laporan Toko',
          showBackButton: false,
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu_rounded, color: Colors.white),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          bottom: TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white.withValues(alpha: 0.6),
            indicatorColor: isDark ? AppColors.teal300 : AppColors.teal200,
            indicatorWeight: 3,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            tabs: const [
              Tab(text: 'Keuangan & Pendapatan'),
              Tab(text: 'Volume Pesanan'),
            ],
          ),
        ),
        body: Column(
          children: [
            // DateRangePicker Section / Filter Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildPeriodChip('Hari Ini'),
                          const SizedBox(width: 8),
                          _buildPeriodChip('7 Hari'),
                          const SizedBox(width: 8),
                          _buildPeriodChip('30 Hari'),
                          const SizedBox(width: 8),
                          _buildPeriodChip(
                            'Custom',
                            label: _customDateRange != null
                                ? '${_customDateRange!.start.day}/${_customDateRange!.start.month} - ${_customDateRange!.end.day}/${_customDateRange!.end.month}'
                                : 'Custom',
                            onTap: _selectCustomDateRange,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // ExportButton Component
                  IconButton(
                    tooltip: 'Ekspor Laporan (PDF/Excel)',
                    onPressed: _exportReport,
                    icon: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        ),
                      ),
                      child: Icon(
                        Icons.download_rounded,
                        color: isDark ? AppColors.teal300 : AppColors.teal700,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Tab Bar View content
            Expanded(
              child: TabBarView(
                children: [
                  // Tab 1: Financial & Revenue
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // ReportSummaryCard Component
                        _buildReportSummaryGrid(
                          isDark: isDark,
                          theme: theme,
                          totalRevenue: totalRevenue,
                          aov: aov,
                          completionRate: completionRate,
                          totalOrders: totalOrders,
                        ),
                        const SizedBox(height: 20),

                        // Line Chart
                        RevenueLineChart(period: _selectedPeriod),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),

                  // Tab 2: Orders Volume & Service distribution
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // ReportSummaryCard Component
                        _buildReportSummaryGrid(
                          isDark: isDark,
                          theme: theme,
                          totalRevenue: totalRevenue,
                          aov: aov,
                          completionRate: completionRate,
                          totalOrders: totalOrders,
                        ),
                        const SizedBox(height: 20),

                        // Bar Chart
                        ServiceBarChart(period: _selectedPeriod),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodChip(String period, {String? label, VoidCallback? onTap}) {
    final isSelected = _selectedPeriod == period;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ChoiceChip(
      label: Text(
        label ?? period,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          fontSize: 12,
          color: isSelected
              ? (isDark ? AppColors.teal900 : Colors.white)
              : (isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText),
        ),
      ),
      selected: isSelected,
      selectedColor: isDark ? AppColors.teal300 : AppColors.teal700,
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected 
              ? Colors.transparent 
              : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
        ),
      ),
      onSelected: (selected) {
        if (selected) {
          if (onTap != null) {
            onTap();
          } else {
            setState(() {
              _selectedPeriod = period;
            });
          }
        }
      },
    );
  }

  Widget _buildReportSummaryGrid({
    required bool isDark,
    required ThemeData theme,
    required int totalRevenue,
    required int aov,
    required double completionRate,
    required int totalOrders,
  }) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.4,
      children: [
        _buildSummaryCard(
          title: 'Pendapatan Kotor',
          value: _formatCurrency(totalRevenue),
          icon: Icons.monetization_on_rounded,
          iconColor: Colors.green.shade600,
          isDark: isDark,
          theme: theme,
        ),
        _buildSummaryCard(
          title: 'Rata-rata Pesanan (AOV)',
          value: _formatCurrency(aov),
          icon: Icons.analytics_rounded,
          iconColor: Colors.blue.shade600,
          isDark: isDark,
          theme: theme,
        ),
        _buildSummaryCard(
          title: 'Penyelesaian (Rate)',
          value: '${completionRate.toStringAsFixed(1)}%',
          icon: Icons.task_alt_rounded,
          iconColor: Colors.teal.shade600,
          isDark: isDark,
          theme: theme,
        ),
        _buildSummaryCard(
          title: 'Jumlah Transaksi',
          value: '$totalOrders Pesanan',
          icon: Icons.receipt_long_rounded,
          iconColor: Colors.orange.shade600,
          isDark: isDark,
          theme: theme,
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
    required bool isDark,
    required ThemeData theme,
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: isDark ? AppColors.darkMutedText : AppColors.lightSubtleText,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
