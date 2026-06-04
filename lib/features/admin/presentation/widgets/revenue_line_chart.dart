import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Grafik garis tren pendapatan (RevenueLineChart) berbasis fl_chart untuk dasbor admin.
class RevenueLineChart extends StatelessWidget {
  final String period;

  const RevenueLineChart({required this.period, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final primaryColor = isDark ? AppColors.teal300 : AppColors.teal700;

    // Mendapatkan data spot, judul sumbu X, dan total pendapatan berdasarkan periode terpilih
    final spots = _getSpots();
    final titles = _getBottomTitles();
    final total = _getTotalRevenue();

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
              Text(
                'Tren Pendapatan',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                total,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
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
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        if (value == 0) return const SizedBox();
                        String label = '';
                        if (value >= 1000000) {
                          label = '${(value / 1000000).toStringAsFixed(1)}M';
                        } else if (value >= 1000) {
                          label = '${(value / 1000).toStringAsFixed(0)}rb';
                        } else {
                          label = value.toStringAsFixed(0);
                        }
                        return Text(
                          label,
                          style: TextStyle(
                            fontSize: 10,
                            color: isDark ? AppColors.darkMutedText : AppColors.lightSubtleText,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx >= 0 && idx < titles.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              titles[idx],
                              style: TextStyle(
                                fontSize: 10,
                                color: isDark ? AppColors.darkMutedText : AppColors.lightSubtleText,
                                fontWeight: FontWeight.bold,
                              ),
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
                      colors: [
                        primaryColor,
                        isDark ? AppColors.teal200 : AppColors.teal600,
                      ],
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
                          primaryColor.withValues(alpha: isDark ? 0.3 : 0.15),
                          primaryColor.withValues(alpha: 0.0),
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

  List<FlSpot> _getSpots() {
    switch (period) {
      case 'Hari Ini':
        return const [
          FlSpot(0, 15000),
          FlSpot(1, 45000),
          FlSpot(2, 30000),
          FlSpot(3, 85000),
          FlSpot(4, 120000),
          FlSpot(5, 90000),
        ];
      case '7 Hari':
        return const [
          FlSpot(0, 150000),
          FlSpot(1, 220000),
          FlSpot(2, 180000),
          FlSpot(3, 240000),
          FlSpot(4, 310000),
          FlSpot(5, 280000),
          FlSpot(6, 100000),
        ];
      case '30 Hari':
        return const [
          FlSpot(0, 1100000),
          FlSpot(1, 1400000),
          FlSpot(2, 1600000),
          FlSpot(3, 1720000),
        ];
      default: // Kustom
        return const [
          FlSpot(0, 150000),
          FlSpot(1, 220000),
          FlSpot(2, 180000),
          FlSpot(3, 240000),
          FlSpot(4, 310000),
          FlSpot(5, 280000),
          FlSpot(6, 100000),
        ];
    }
  }

  List<String> _getBottomTitles() {
    switch (period) {
      case 'Hari Ini':
        return const ['08:00', '10:00', '12:00', '14:00', '16:00', '18:00'];
      case '7 Hari':
        return const ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
      case '30 Hari':
        return const ['Mgg 1', 'Mgg 2', 'Mgg 3', 'Mgg 4'];
      default: // Kustom
        return const ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    }
  }

  String _getTotalRevenue() {
    int total = 0;
    for (var spot in _getSpots()) {
      total += spot.y.toInt();
    }
    return 'Total: Rp ${total.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => "${m[1]}.")}';
  }
}
