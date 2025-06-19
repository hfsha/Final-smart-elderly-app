import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_elderly_app/models/sensor_data.dart';
import 'package:smart_elderly_app/services/sensor_service.dart';
import 'package:intl/intl.dart';
import 'package:smart_elderly_app/theme/app_colors.dart';
import 'package:smart_elderly_app/theme/text_styles.dart';
import 'package:flutter_animate/flutter_animate.dart';

class LogsPage extends StatefulWidget {
  const LogsPage({super.key});

  @override
  State<LogsPage> createState() => _LogsPageState();
}

class _LogsPageState extends State<LogsPage> with SingleTickerProviderStateMixin {
  String _selectedFilter = 'all';
  final List<String> _filterOptions = [
    'all',
    'motion',
    'fall',
    'fire',
    'environment'
  ];

  late TabController _tabController;

  final List<({String label, IconData icon, Color color})> _tabInfo = [
    (label: 'All', icon: Icons.all_inclusive, color: AppColors.gradientPurple),
    (label: 'Motion', icon: Icons.directions_walk, color: Colors.green),
    (label: 'Fall', icon: Icons.warning, color: Colors.orange),
    (label: 'Fire', icon: Icons.fireplace, color: Colors.red),
    (label: 'Environment', icon: Icons.thermostat, color: Colors.blue),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _filterOptions.length, vsync: this);
    _tabController.addListener(_handleFilterChange);
  }

  void _handleFilterChange() {
    setState(() {
      _selectedFilter = _filterOptions[_tabController.index];
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleFilterChange);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xF5F3F2),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(90.0),
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
              children: const [
                Text(
                  'Activity Logs',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Custom TabBar with equal-width tabs, horizontal icon+text, and full-width pill indicator
          Material(
            elevation: 3,
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                padding: EdgeInsets.zero,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: AppColors.gradientPurple,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.gradientPurple.withOpacity(0.25),
                      blurRadius: 16,
                      spreadRadius: 1,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                indicatorPadding: EdgeInsets.zero,
                labelPadding: const EdgeInsets.symmetric(horizontal: 12),
                tabs: _tabInfo.map((tab) {
                  return SizedBox(
                    height: 40,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(tab.icon, size: 20),
                        const SizedBox(width: 8),
                        Text(tab.label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      ],
                    ),
                  );
                }).toList(),
                labelColor: Colors.white,
                unselectedLabelColor: AppColors.gradientPurple,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 15),
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorColor: Colors.transparent,
                indicatorWeight: 0,
                dividerColor: Colors.transparent,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Consumer<SensorService>(
              builder: (context, sensorService, _) {
                final logs = sensorService.trendsData.reversed.toList();
                return _buildLogsList(logs);
              },
            ),
          ),
        ],
      ),
    );
  }

  String _capitalize(String s) => s.isNotEmpty ? s[0].toUpperCase() + s.substring(1).toLowerCase() : s;

  Widget _buildLogsList(List<SensorData> logs) {
    final filteredLogs = logs.where((log) {
      final eventInfo = _getEventInfo(log); // Get the primary event type for this log
      switch (_selectedFilter) {
        case 'motion':
          return eventInfo.title == 'Motion Detected';
        case 'fall':
          return eventInfo.title == 'Fall Detected';
        case 'fire':
          return eventInfo.title == 'Fire Alert';
        case 'environment':
          return eventInfo.title == 'Environment Update';
        default: // 'all'
          return true;
      }
    }).toList();

    if (filteredLogs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 60, color: AppColors.textSecondary.withOpacity(0.5)),
            const SizedBox(height: 12),
            Text(
              'No ${_selectedFilter == 'all' ? '' : '$_selectedFilter '}logs available.',
              style: TextStyles.headline2.copyWith(color: AppColors.textSecondary, fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              'Check back later or adjust your filter.',
              style: TextStyles.bodyText2.copyWith(color: AppColors.textSecondary.withOpacity(0.7), fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await Provider.of<SensorService>(context, listen: false)
            .fetchTrendsData(deviceId: 'ELDERLY_MONITOR_001', hours: 24);
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        itemCount: filteredLogs.length,
        itemBuilder: (context, index) {
          final log = filteredLogs[index];
          return LogItemCard(
            log: log,
            buildDetailRow: _buildDetailRow,
            getEventInfo: _getEventInfo,
            showLogDetails: _showLogDetails,
          ).animate().fadeIn(duration: 400.ms, delay: (index * 60).ms).slideY(begin: 0.04);
        },
      ),
    );
  }

  void _showLogDetails(SensorData log, ({String title, IconData icon, Color color}) eventInfo) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  eventInfo.title,
                  style: TextStyles.headline2.copyWith(color: AppColors.textPrimary, fontSize: 20),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textSecondary, size: 22),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildDetailRow('Time', DateFormat('MMM d, y - h:mm:ss a').format(log.timestamp), Icons.access_time),
            if (log.temperature > 0) _buildDetailRow('Temperature', '${log.temperature.toStringAsFixed(1)}°C', Icons.thermostat),
            if (log.humidity > 0) _buildDetailRow('Humidity', '${log.humidity.toStringAsFixed(1)}%', Icons.water_drop),
            if (log.motion) _buildDetailRow('Motion', 'Detected', Icons.directions_walk),
            if (log.fallDetected) _buildDetailRow('Fall', 'Detected', Icons.warning),
            if (log.fireDetected) _buildDetailRow('Fire', 'Detected', Icons.fireplace),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 18),
          const SizedBox(width: 10),
          Text(
            '$label:',
            style: TextStyles.bodyText2.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              value,
              style: TextStyles.bodyText2.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  ({String title, IconData icon, Color color}) _getEventInfo(SensorData log) {
    if (log.fireDetected) {
      return (title: 'Fire Alert', icon: Icons.fireplace, color: AppColors.danger);
    } else if (log.fallDetected) {
      return (title: 'Fall Detected', icon: Icons.warning, color: AppColors.warning);
    } else if (log.motion) {
      return (title: 'Motion Detected', icon: Icons.directions_walk, color: AppColors.success);
    } else {
      return (title: 'Environment Update', icon: Icons.thermostat, color: AppColors.info);
    }
  }
}

class LogItemCard extends StatefulWidget {
  final SensorData log;
  final Widget Function(String label, String value, IconData icon) buildDetailRow;
  final ({String title, IconData icon, Color color}) Function(SensorData log) getEventInfo;
  final void Function(SensorData log, ({String title, IconData icon, Color color}) eventInfo) showLogDetails;

  const LogItemCard({
    Key? key,
    required this.log,
    required this.buildDetailRow,
    required this.getEventInfo,
    required this.showLogDetails,
  }) : super(key: key);

  @override
  _LogItemCardState createState() => _LogItemCardState();
}

class _LogItemCardState extends State<LogItemCard> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final eventInfo = widget.getEventInfo(widget.log);
    return FadeTransition(
      opacity: Tween<double>(begin: 0.0, end: 1.0).animate(_animationController),
      child: GestureDetector(
        onTapDown: (_) => _animationController.reverse(),
        onTapUp: (_) => _animationController.forward(),
        onTapCancel: () => _animationController.forward(),
        onTap: () => widget.showLogDetails(widget.log, eventInfo),
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 14.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: eventInfo.color.withOpacity(0.10),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Card(
              elevation: 8,
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              shadowColor: eventInfo.color.withOpacity(0.18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Colored accent bar and icon
                  Container(
                    width: 8,
                    height: 90,
                    decoration: BoxDecoration(
                      color: eventInfo.color,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(18),
                        bottomLeft: Radius.circular(18),
                      ),
                    ),
                    margin: const EdgeInsets.only(right: 10),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(eventInfo.icon, color: eventInfo.color, size: 26),
                            const SizedBox(width: 10),
                            Text(
                              eventInfo.title,
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 19,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              DateFormat('MMM d, y').format(widget.log.timestamp),
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.only(left: 36.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                DateFormat('h:mm:ss a').format(widget.log.timestamp),
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              if (widget.log.temperature > 0)
                                Text(
                                  'Temperature: ${widget.log.temperature.toStringAsFixed(1)}°C',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 14,
                                  ),
                                ),
                              if (widget.log.humidity > 0)
                                Text(
                                  'Humidity: ${widget.log.humidity.toStringAsFixed(1)}%',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 14,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
