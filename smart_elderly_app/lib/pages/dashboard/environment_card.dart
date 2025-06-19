import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_elderly_app/services/sensor_service.dart';
// import 'package:syncfusion_flutter_gauges/gauges.dart'; // Removed unused import
import 'package:smart_elderly_app/theme/app_colors.dart';
import 'package:smart_elderly_app/theme/text_styles.dart';
import 'package:smart_elderly_app/widgets/gauge_display_card.dart';
import 'dart:ui'; // New import for ImageFilter

class EnvironmentCard extends StatelessWidget {
  const EnvironmentCard({super.key});

  @override
  Widget build(BuildContext context) {
    final sensorService = Provider.of<SensorService>(context);
    final temperature = sensorService.latestData?.temperature ?? 0.0;
    final humidity = sensorService.latestData?.humidity ?? 0.0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          decoration: BoxDecoration(
            color: Color(0xFFF9F5FB).withOpacity(0.85),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.gradientPurple.withOpacity(0.18),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.gradientPurple.withOpacity(0.10),
                blurRadius: 32,
                spreadRadius: 2,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Accent bar
                Container(
                  width: 6,
                  height: 32,
                  margin: const EdgeInsets.only(top: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    gradient: const LinearGradient(
                      colors: [AppColors.gradientPurple, AppColors.gradientBlue],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                const SizedBox(width: 18),
                // Card content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Environment',
                        style: TextStyles.headline1.copyWith(
                          color: AppColors.charcoal,
                          fontWeight: FontWeight.w900,
                          fontSize: 24,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _FrostedMiniGaugeCard(
                              child: GaugeDisplayCard(
                                label: 'Temperature',
                                currentValue: temperature,
                                unit: '°C',
                                minValue: 0,
                                maxValue: 50,
                               
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _FrostedMiniGaugeCard(
                              child: GaugeDisplayCard(
                                label: 'Humidity',
                                currentValue: humidity,
                                unit: '%',
                                minValue: 0,
                                maxValue: 100,
                             
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FrostedMiniGaugeCard extends StatelessWidget {
  final Widget child;
  const _FrostedMiniGaugeCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.softWhite.withOpacity(0.6),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: AppColors.charcoal.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
            border: Border.all(
              color: AppColors.softWhite.withOpacity(0.4),
              width: 1,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
