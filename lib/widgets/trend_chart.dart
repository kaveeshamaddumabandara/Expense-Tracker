import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class FinanceTrendChart extends StatelessWidget {
  const FinanceTrendChart({
    super.key,
    required this.weeklyAmounts,
    this.primaryDottedColor = AppColors.primaryBlue,
    this.secondaryDottedColor = const Color(0xFF93C5FD),
  });

  /// 7 values representing amounts for Sunday through Saturday
  final List<double> weeklyAmounts;
  final Color primaryDottedColor;
  final Color secondaryDottedColor;

  @override
  Widget build(BuildContext context) {
    final days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

    final effectiveAmounts = weeklyAmounts.length == 7
        ? weeklyAmounts
        : [120.0, 90.0, 174.0, 110.0, 240.0, 451.0, 290.0];

    final maxVal = effectiveAmounts.reduce((a, b) => a > b ? a : b);
    final ceiling = (maxVal * 1.35).clamp(100.0, 100000.0);

    // Finding top two peaks for reference-style tooltips
    int firstPeakIdx = 2; // default T
    int secondPeakIdx = 5; // default F
    double firstMax = -1;
    double secondMax = -1;

    for (int i = 0; i < effectiveAmounts.length; i++) {
      if (effectiveAmounts[i] > firstMax) {
        secondMax = firstMax;
        secondPeakIdx = firstPeakIdx;
        firstMax = effectiveAmounts[i];
        firstPeakIdx = i;
      } else if (effectiveAmounts[i] > secondMax) {
        secondMax = effectiveAmounts[i];
        secondPeakIdx = i;
      }
    }

    final primarySpots = List.generate(7, (i) {
      return FlSpot(i.toDouble(), effectiveAmounts[i]);
    });

    final secondarySpots = List.generate(7, (i) {
      // Create a complementary dashed guide curve
      final factor = 0.72 + 0.2 * (i % 2 == 0 ? 1 : -1);
      return FlSpot(i.toDouble(), (effectiveAmounts[i] * factor).clamp(20.0, ceiling));
    });

    return Column(
      children: [
        // Peak markers banner
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _PeakIndicator(
                day: days[firstPeakIdx],
                amount: effectiveAmounts[firstPeakIdx],
                color: primaryDottedColor,
              ),
              _PeakIndicator(
                day: days[secondPeakIdx],
                amount: effectiveAmounts[secondPeakIdx],
                color: primaryDottedColor,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 140,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: ceiling,
                minX: 0,
                maxX: 6,
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 24,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx >= 0 && idx < days.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              days[idx],
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                lineBarsData: [
                  // Primary dotted curve
                  LineChartBarData(
                    spots: primarySpots,
                    isCurved: true,
                    curveSmoothness: 0.35,
                    color: primaryDottedColor,
                    barWidth: 2.4,
                    dashArray: [5, 4],
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: (index == firstPeakIdx || index == secondPeakIdx) ? 5.0 : 3.0,
                          color: Colors.white,
                          strokeColor: primaryDottedColor,
                          strokeWidth: 2.2,
                        );
                      },
                    ),
                  ),
                  // Secondary subtle dotted curve matching reference image
                  LineChartBarData(
                    spots: secondarySpots,
                    isCurved: true,
                    curveSmoothness: 0.4,
                    color: secondaryDottedColor.withValues(alpha: 0.65),
                    barWidth: 1.8,
                    dashArray: [4, 4],
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PeakIndicator extends StatelessWidget {
  const _PeakIndicator({
    required this.day,
    required this.amount,
    required this.color,
  });

  final String day;
  final double amount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$day: ',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
          Text(
            'LKR ${amount.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
