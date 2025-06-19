import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_elderly_app/models/sensor_data.dart';
import 'package:smart_elderly_app/services/sensor_service.dart';
import 'package:smart_elderly_app/widgets/time_range_selector.dart';
import 'temp_chart.dart';
import 'humidity_chart.dart';
import 'dart:async';
import 'package:smart_elderly_app/theme/app_colors.dart';
// import 'package:flutter/rendering.dart';
import 'dart:ui';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';

class TrendsPage extends StatefulWidget {
  const TrendsPage({super.key});

  @override
  State<TrendsPage> createState() => _TrendsPageState();
}

class _TrendsPageState extends State<TrendsPage> {
  int _selectedHours = 24; // Default to 24 hours
  Timer? _debounceTimer;
  bool _isInitialLoad = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  Future<void> _loadInitialData() async {
    if (!mounted) return;
    final sensorService = Provider.of<SensorService>(context, listen: false);
    await sensorService.fetchTrendsData(
      hours: _selectedHours,
      deviceId: 'ELDERLY_MONITOR_001',
    );
    if (mounted) {
      setState(() {
        _isInitialLoad = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xF5F3F2),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120.0),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.gradientPurple,
                AppColors.gradientBlue,
              ],
            ),
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 40, 16, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Trends Analysis',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                TimeRangeSelector(
                  selectedHours: _selectedHours,
                  onChanged: (hours) {
                    setState(() => _selectedHours = hours);
                    _debounceTimer?.cancel();
                    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
                      final sensorService =
                          Provider.of<SensorService>(context, listen: false);
                      sensorService.fetchTrendsData(
                        hours: hours,
                        deviceId: 'ELDERLY_MONITOR_001',
                      );
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      body: Consumer<SensorService>(
        builder: (context, sensorService, _) {
          if (_isInitialLoad || sensorService.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading trend data...'),
                ],
              ),
            );
          }

          if (sensorService.trendsData.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.data_usage, size: 48, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No data available for the selected time range'),
                ],
              ),
            );
          }

          // Sample the data to prevent OutOfMemory errors on charts
          final sampledData =
              _sampleData(sensorService.trendsData, _selectedHours);

          if (sampledData.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.data_usage, size: 48, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Not enough data points to display a meaningful trend.'),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              final sensorService =
                  Provider.of<SensorService>(context, listen: false);
              await sensorService.fetchTrendsData(
                hours: _selectedHours,
                deviceId: 'ELDERLY_MONITOR_001',
              );
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Temperature Trend', icon: Icons.thermostat, color: AppColors.primary),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 250,
                    child: TempChart(
                      data: sampledData,
                      timeRange: _selectedHours,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Humidity Trend', icon: Icons.water_drop, color: AppColors.teal),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 250,
                    child: HumidityChart(
                      data: sampledData,
                      timeRange: _selectedHours,
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildSectionTitle('History Table'),
                  const SizedBox(height: 8),
                  _HistoryTable(data: sensorService.trendsData),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  List<SensorData> _sampleData(List<SensorData> originalData, int hours) {
    if (originalData.isEmpty) {
      return [];
    }

    // Sort data by timestamp to ensure proper sampling
    originalData.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    int targetDataPoints;
    if (hours <= 24) {
      targetDataPoints =
          6; // Aim for up to 6 points for 24 hours (e.g., every 4 hours)
    } else if (hours <= 7 * 24) {
      // Up to 7 days
      targetDataPoints =
          14; // Aim for max 14 points (e.g., 1 point every 12 hours)
    } else {
      // More than 7 days (e.g., 1 month or more)
      targetDataPoints = 10; // Aim for max 10 points (roughly every few days)
    }

    if (originalData.length <= targetDataPoints) {
      return originalData; // No sampling needed if data is already sparse enough
    }

    final List<SensorData> sampled = [];
    final double step = originalData.length / targetDataPoints;

    for (int i = 0; i < targetDataPoints; i++) {
      final int index = (i * step).floor();
      if (index < originalData.length) {
        sampled.add(originalData[index]);
      }
    }
    return sampled;
  }

  Widget _buildSectionTitle(String title, {IconData? icon, Color? color}) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 28,
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            gradient: const LinearGradient(
              colors: [AppColors.gradientPurple, AppColors.gradientBlue],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        if (icon != null) ...[
          Icon(icon, color: color ?? AppColors.gradientPurple, size: 22),
          const SizedBox(width: 8),
        ],
        Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: AppColors.charcoal,
            shadows: [
              Shadow(
                color: Colors.black26,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}

class _HistoryTable extends StatelessWidget {
  final List<SensorData> data;
  const _HistoryTable({required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(child: Text('No history data available.'));
    }
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              padding: const EdgeInsets.all(0),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.55),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppColors.gradientPurple.withOpacity(0.18),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.gradientPurple.withOpacity(0.13),
                    blurRadius: 32,
                    spreadRadius: 2,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Gradient header row
                  Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          AppColors.gradientPurple,
                          AppColors.gradientBlue
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    child: Row(
                      children: const [
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 14),
                            child: Text(
                              'Time',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 14),
                            child: Text(
                              'Temp (°C)',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 14),
                            child: Text(
                              'Humidity (%)',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Divider
                  Container(
                    height: 1.5,
                    color: AppColors.gradientPurple.withOpacity(0.13),
                  ),
                  // Table body
                  ..._buildUniqueRows(data, context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper to build unique timestamp rows with modern style
  List<Widget> _buildUniqueRows(List<SensorData> data, BuildContext context) {
    final List<Widget> rows = [];
    final Set<String> seenTimestamps = {};
    final dateFormat = DateFormat('HH:mm:ss');
    final uniqueData = data.reversed
        .where((d) {
          final ts = d.timestamp != null ? dateFormat.format(d.timestamp) : '-';
          if (seenTimestamps.contains(ts)) return false;
          seenTimestamps.add(ts);
          return true;
        })
        .take(20)
        .toList();

    for (int i = 0; i < uniqueData.length; i++) {
      final d = uniqueData[i];
      final isEven = i % 2 == 0;
      rows.add(
        Container(
          decoration: BoxDecoration(
            color: isEven
                ? Colors.white.withOpacity(0.85)
                : AppColors.gradientBlue.withOpacity(0.07),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  child: Text(
                    d.timestamp != null ? dateFormat.format(d.timestamp) : '-',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'GoogleSans',
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  child: Text(
                    d.temperature.toStringAsFixed(1),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'GoogleSans',
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  child: Text(
                    d.humidity.toStringAsFixed(1),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'GoogleSans',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
      // Divider between rows
      if (i < uniqueData.length - 1) {
        rows.add(Container(
          height: 1,
          color: AppColors.softWhite.withOpacity(0.18),
        ));
      }
    }
    return rows;
  }
}
