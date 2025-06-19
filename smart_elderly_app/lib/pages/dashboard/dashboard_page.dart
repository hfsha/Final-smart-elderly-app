import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:smart_elderly_app/services/auth_service.dart';
import 'package:smart_elderly_app/services/sensor_service.dart';
import 'package:smart_elderly_app/services/device_command_service.dart';
import 'package:smart_elderly_app/theme/app_colors.dart';
import 'package:smart_elderly_app/theme/text_styles.dart';
import 'package:smart_elderly_app/widgets/emergency_banner.dart';
import 'danger_card.dart';
import 'environment_card.dart';
import 'occupancy_card.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late SensorService _sensorService;
  bool _isAlert = false;
  String _alertType = '';
  bool _relayOn = false;
  Timer? _pollingTimer;
  final String _deviceId = 'ELDERLY_MONITOR_001'; // Use your actual device ID

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _sensorService = Provider.of<SensorService>(context, listen: false);
      _sensorService.startMonitoring(_deviceId, interval: 1);
      _startPolling();
    });
  }

  void _startPolling() {
    _fetchAlertAndRelay();
    _pollingTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _fetchAlertAndRelay();
    });
  }

  Future<void> _fetchAlertAndRelay() async {
    try {
      // Fetch latest alert
      final alertResp = await http.get(Uri.parse(
        'https://humancc.site/shahidatulhidayah/smart-elderly-app/api/alerts/list.php?device_id=$_deviceId&unhandled_only=true&limit=2',
      ));
      bool isAlert = false;
      String alertType = '';
      if (alertResp.statusCode == 200) {
        final data = json.decode(alertResp.body);
        final alerts = data['data']['alerts'] as List;
        bool fire = false;
        bool fall = false;
        for (final alert in alerts) {
          if (alert['value'] == true && alert['is_handled'] == false) {
            if (alert['alert_type'] == 'fire') fire = true;
            if (alert['alert_type'] == 'fall') fall = true;
          }
        }
        if (fire && fall) {
          isAlert = true;
          alertType = 'both';
        } else if (fire) {
          isAlert = true;
          alertType = 'fire';
        } else if (fall) {
          isAlert = true;
          alertType = 'fall';
        }
      }

      // Fetch relay state (latest command)
      final relayResp = await http.get(Uri.parse(
        'https://humancc.site/shahidatulhidayah/smart-elderly-app/api/device/relay_state.php?device_id=$_deviceId',
      ));
      bool relayOn = false;
      if (relayResp.statusCode == 200) {
        final data = json.decode(relayResp.body);
        relayOn = data['relay_on'] == true;
      }

      setState(() {
        _isAlert = isAlert;
        _alertType = alertType;
        _relayOn = relayOn;
      });
    } catch (e) {
      // Handle error
    }
  }

  void _onRelayToggle(bool value) async {
    setState(() {
      _relayOn = value; // Optimistic update for instant UI feedback
    });
    try {
      await DeviceCommandService.sendRelayCommand(_deviceId, value);
      // Fetch the latest relay state from backend to ensure sync
      final relayResp = await http.get(Uri.parse(
        'https://humancc.site/shahidatulhidayah/smart-elderly-app/api/device/relay_state.php?device_id=$_deviceId',
      ));
      if (relayResp.statusCode == 200) {
        final data = json.decode(relayResp.body);
        setState(() {
          _relayOn = data['relay_on'] == true;
        });
      }
    } catch (e) {
      // Optionally show error and revert UI if needed
      setState(() {
        _relayOn = !value; // Revert if failed
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
            child: Consumer<AuthService>(
              builder: (context, authService, child) {
                final userName = authService.currentUser?.name ?? 'Guest';
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Hello, $userName!',
                          style: TextStyles.headline1.copyWith(color: Colors.white),
                        ).animate().fadeIn(duration: 500.ms, delay: 200.ms).slideX(begin: -0.1),
                        IconButton(
                          icon: const Icon(Icons.notifications, color: AppColors.softWhite, size: 28),
                          onPressed: () {
                            // Handle notifications
                          },
                        ).animate().fadeIn(duration: 500.ms, delay: 300.ms).slideX(begin: 0.1),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Welcome back to your smart home dashboard.',
                      style: TextStyles.bodyText2.copyWith(color: AppColors.softWhite.withOpacity(0.8)),
                    ).animate().fadeIn(duration: 500.ms, delay: 400.ms).slideX(begin: -0.1),
                  ],
                );
              },
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xF5F3F2),
          ),
          child: RefreshIndicator(
            onRefresh: () async {
              await _sensorService.fetchSensorData('ELDERLY_MONITOR_001');
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  Builder(
                    builder: (context) {
                      final sensorData = Provider.of<SensorService>(context).latestData;
                      bool fire = sensorData?.fireDetected ?? false;
                      bool fall = sensorData?.fallDetected ?? false;
                      bool isAlert = fire || fall;
                      String alertType = '';
                      if (fire && fall) {
                        alertType = 'both';
                      } else if (fire) {
                        alertType = 'fire';
                      } else if (fall) {
                        alertType = 'fall';
                      }
                      return EmergencyBanner(
                        isAlert: isAlert,
                        alertType: alertType,
                        relayOn: _relayOn,
                        onRelayToggle: _onRelayToggle,
                      );
                    },
                  ),
                  const SizedBox(height: 12),

                  // Dashboard Cards
                  Wrap(
                    spacing: 12.0, // Horizontal spacing between cards
                    runSpacing: 12.0, // Vertical spacing between rows of cards
                    alignment: WrapAlignment.center, // Center the cards in the wrap
                    children: [
                      const OccupancyCard()
                          .animate(delay: 100.ms)
                          .fadeIn()
                          .slideY(begin: 0.1, end: 0),

                      const EnvironmentCard()
                          .animate(delay: 200.ms)
                          .fadeIn()
                          .slideY(begin: 0.1, end: 0),

                      // DangerCard removed
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _sensorService.stopMonitoring();
    _pollingTimer?.cancel();
    super.dispose();
  }
}
