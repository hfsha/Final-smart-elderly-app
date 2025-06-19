import 'package:flutter/material.dart';
import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';
import 'package:provider/provider.dart';
import 'package:smart_elderly_app/services/sensor_service.dart';
import 'package:smart_elderly_app/theme/app_colors.dart';
import 'package:smart_elderly_app/theme/text_styles.dart';
import 'dart:ui'; // New import for ImageFilter

class OccupancyCard extends StatefulWidget {
  const OccupancyCard({super.key});

  @override
  State<OccupancyCard> createState() => _OccupancyCardState();
}

class _OccupancyCardState extends State<OccupancyCard> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.9, end: 1.0).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sensorService = Provider.of<SensorService>(context);
    final bool isOccupied = sensorService.latestData?.motion ?? false;

    // Define colors based on AppColors for consistency and desired vibe
    final Color activeColor = AppColors.gradientPurple; // Purple for active/occupied
    final Color inactiveColor = AppColors.lightGray; // Light Gray for inactive/empty
    final Color indicatorBackgroundColor = AppColors.softWhite; // Soft White for indicator background

    final Color currentValueColor = isOccupied ? activeColor : inactiveColor;
    final Color currentBorderColor = isOccupied ? activeColor : inactiveColor; // Border color matches active/inactive

    final String statusText = isOccupied ? 'Occupied' : 'Empty';
    final IconData statusIcon = isOccupied ? Icons.person_add_alt_1 : Icons.person_off_outlined;

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16), // Stronger blur for glassmorphism
        child: Container(
          decoration: BoxDecoration(
            color: Color(0xF9F5FB).withOpacity(0.85),
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
                  height: 32, // Align with title text height
                  margin: const EdgeInsets.only(top: 4), // Small vertical alignment tweak
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
                        'Room Occupancy',
                        style: TextStyles.headline1.copyWith(
                          color: AppColors.charcoal,
                          fontWeight: FontWeight.w900,
                          fontSize: 24,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: SizedBox(
                          width: 140,
                          height: 140,
                          child: LiquidCircularProgressIndicator(
                            value: isOccupied ? _animation.value : 0.0,
                            valueColor: AlwaysStoppedAnimation(currentValueColor),
                            backgroundColor: indicatorBackgroundColor,
                            borderColor: currentBorderColor,
                            borderWidth: 3.0,
                            direction: Axis.vertical,
                            center: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  statusIcon,
                                  size: 56,
                                  color: currentValueColor,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  statusText,
                                  style: TextStyles.headline2.copyWith(color: currentValueColor, fontSize: 20),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: Text(
                          'Last updated: ${sensorService.latestData?.formattedTime ?? '--'}',
                          style: TextStyles.bodyText2.copyWith(color: AppColors.charcoal.withOpacity(0.7)),
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
    );
  }
}
