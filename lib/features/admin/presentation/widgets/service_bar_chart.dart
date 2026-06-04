import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Grafik batang kontribusi kategori layanan (ServiceBarChart) berbasis fl_chart untuk dasbor admin.
class ServiceBarChart extends StatelessWidget {
  final String period;

  const ServiceBarChart({required this.period, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final data = _getServiceCounts();
    final categories = ['Print', 'Jilid', 'Laminasi', 'Scan', 'Fotokopi'];
    final total = data.fold<int>(0, (sum, val) => sum + val);

    final activeColor = isDark ? AppColors.teal300 : AppColors.teal700;

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
                'Pesanan Per Layanan',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '$total Cetak',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: activeColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: _getMaxY(),
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
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
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
                        if (idx >= 0 && idx < categories.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              categories[idx],
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
                barGroups: List.generate(data.length, (index) {
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: data[index].toDouble(),
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            activeColor,
                            _getBarColor(index, isDark),
                          ],
                        ),
                        width: 16,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(6),
                          topRight: Radius.circular(6),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<int> _getServiceCounts() {
    switch (period) {
      case 'Hari Ini':
        return const [15, 4, 2, 5, 20];
      case '7 Hari':
        return const [85, 18, 10, 25, 110];
      case '30 Hari':
        return const [340, 75, 45, 90, 450];
      default: // Kustom
        return const [85, 18, 10, 25, 110];
    }
  }

  double _getMaxY() {
    switch (period) {
      case 'Hari Ini':
        return 25;
      case '7 Hari':
        return 130;
      case '30 Hari':
        return 500;
      default: // Kustom
        return 130;
    }
  }

  Color _getBarColor(int index, bool isDark) {
    final colors = [
      AppColors.teal200,
      Colors.orange.shade300,
      Colors.purple.shade300,
      Colors.blue.shade300,
      Colors.green.shade300,
    ];
    return colors[index % colors.length];
  }
}
