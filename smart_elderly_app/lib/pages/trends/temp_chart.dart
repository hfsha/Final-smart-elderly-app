import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:smart_elderly_app/models/sensor_data.dart';
import 'package:smart_elderly_app/theme/app_colors.dart';
import 'package:intl/intl.dart';

class TempChart extends StatelessWidget {
  final List<SensorData> data;
  final int timeRange;

  const TempChart({
    super.key,
    required this.data,
    required this.timeRange,
  });

  @override
  Widget build(BuildContext context) {
    // Sort and filter data by unique timestamp (keep latest)
    final sortedData = List<SensorData>.from(data)..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    final uniqueData = <int, SensorData>{};
    for (var d in sortedData) {
      uniqueData[d.timestamp.millisecondsSinceEpoch] = d;
    }
    final plotData = uniqueData.values.toList();

    // Filter unique timestamps and sample for visual clarity
    List<SensorData> sampledData = plotData;
    if (plotData.length > 8) {
      final step = (plotData.length / 8).ceil();
      sampledData = [for (int i = 0; i < plotData.length; i += step) plotData[i]];
      if (sampledData.last != plotData.last) sampledData.add(plotData.last);
    }

    final xValues = sampledData.map((d) => d.timestamp.millisecondsSinceEpoch.toDouble()).toList();
    final yValues = sampledData.map((d) => d.temperature).toList();
    final minX = xValues.isNotEmpty ? xValues.reduce((a, b) => a < b ? a : b) : 0.0;
    final maxX = xValues.isNotEmpty ? xValues.reduce((a, b) => a > b ? a : b) : 1.0;
    final xPadding = (maxX - minX) * 0.10;
    final minY = yValues.isNotEmpty ? yValues.reduce((a, b) => a < b ? a : b) : 0.0;
    final maxY = yValues.isNotEmpty ? yValues.reduce((a, b) => a > b ? a : b) : 1.0;
    final yPadding = (maxY - minY) * 0.1;

    // If only two points, add a midpoint for visual balance
    List<FlSpot> spots;
    if (sampledData.length == 2) {
      final midX = (xValues[0] + xValues[1]) / 2;
      final midY = (yValues[0] + yValues[1]) / 2;
      spots = [
        FlSpot(xValues[0], yValues[0]),
        FlSpot(midX, midY),
        FlSpot(xValues[1], yValues[1]),
      ];
    } else if (sampledData.length == 1) {
      spots = [
        FlSpot(minX, yValues[0]),
        FlSpot(maxX, yValues[0]),
      ];
    } else {
      spots = sampledData.map((d) {
        return FlSpot(
          d.timestamp.millisecondsSinceEpoch.toDouble(),
          d.temperature,
        );
      }).toList();
    }

    // Helper for X-axis label interval
    double getSmartInterval(double minX, double maxX) {
      final total = maxX - minX;
      return total / 4; // 4 labels
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.gradientPurple, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.gradientPurple.withOpacity(0.10),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            horizontalInterval: 5,
            verticalInterval: _getOptimalInterval(data),
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey.shade200,
                strokeWidth: 1,
              );
            },
            getDrawingVerticalLine: (value) {
              return FlLine(
                color: Colors.grey.shade200,
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: getSmartInterval(minX, maxX),
                getTitlesWidget: (value, meta) {
                  final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                  final formatted = DateFormat('HH:mm:ss').format(date);
                  // Only show label if it's one of the 4 main intervals
                  final interval = getSmartInterval(minX, maxX);
                  if ((value - minX) % interval < 1000 || (maxX - value) < 1000) {
                    return Text(
                      formatted,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 10,
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 5,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toStringAsFixed(0) + '°',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 10,
                    ),
                  );
                },
                reservedSize: 42,
              ),
            ),
          ),
          borderData: FlBorderData(
            show: false,
          ),
          minX: minX - xPadding,
          maxX: maxX + xPadding,
          minY: minY - yPadding,
          maxY: maxY + yPadding,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: sampledData.length > 3,
              color: Colors.orange,
              barWidth: 2.2,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, bar, index) {
                  final isLatest = index == spots.length - 1;
                  return FlDotCirclePainter(
                    radius: isLatest ? 6 : 3.5,
                    color: Colors.orange,
                    strokeWidth: isLatest ? 6 : 1.5,
                    strokeColor: isLatest ? Colors.orange.withOpacity(0.35) : Colors.white,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    AppColors.gradientPurple.withOpacity(0.25),
                    Colors.orange.withOpacity(0.18),
                    Colors.red.withOpacity(0.15),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                cutOffY: 0,
                applyCutOffY: false,
              ),
              isStepLineChart: false,
              curveSmoothness: 0.25,
            ),
          ],
          lineTouchData: LineTouchData(
            enabled: true,
            touchTooltipData: LineTouchTooltipData(
              tooltipBgColor: Colors.white.withOpacity(0.97),
              tooltipRoundedRadius: 14,
              fitInsideHorizontally: true,
              fitInsideVertically: true,
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  final date = DateTime.fromMillisecondsSinceEpoch(spot.x.toInt());
                  final formatted = DateFormat('MMM d, HH:mm:ss').format(date);
                  return LineTooltipItem(
                    '${spot.y.toStringAsFixed(1)}°C\n$formatted',
                    const TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  );
                }).toList();
              },
            ),
          ),
        ),
      ),
    );
  }

  double _getOptimalInterval(List<SensorData> data) {
    if (data.length < 2) return 1.0;

    final double minX = data.first.timestamp.millisecondsSinceEpoch.toDouble();
    final double maxX = data.last.timestamp.millisecondsSinceEpoch.toDouble();
    final double range = maxX - minX;

    const int desiredLabels = 6;
    return range / (desiredLabels - 1);
  }

  // Helper to get a smart interval for the X-axis
  double getDynamicInterval(double minX, double maxX) {
    final totalSeconds = (maxX - minX) / 1000;
    if (totalSeconds <= 60) return 10 * 1000; // 10 seconds
    if (totalSeconds <= 10 * 60) return 60 * 1000; // 1 minute
    if (totalSeconds <= 60 * 60) return 5 * 60 * 1000; // 5 minutes
    return 10 * 60 * 1000; // 10 minutes
  }
}
