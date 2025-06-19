import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_elderly_app/services/sensor_service.dart';
import 'package:smart_elderly_app/theme/app_colors.dart';
import 'package:smart_elderly_app/theme/text_styles.dart';
import 'dart:ui'; // New import for ImageFilter

class DangerCard extends StatelessWidget {
  const DangerCard({super.key});

  @override
  Widget build(BuildContext context) {
    final sensorService = Provider.of<SensorService>(context);
    final hasFire = sensorService.latestData?.fireDetected ?? false;
    final hasFall = sensorService.latestData?.fallDetected ?? false;

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16), // Stronger blur for glassmorphism
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
                        'Safety Status',
                        style: TextStyles.headline1.copyWith(
                          color: AppColors.charcoal,
                          fontWeight: FontWeight.w900,
                          fontSize: 24,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildDangerIndicator(
                            context,
                            label: 'Fire',
                            isActive: hasFire,
                            icon: Icons.fireplace,
                          ),
                          _buildDangerIndicator(
                            context,
                            label: 'Fall',
                            isActive: hasFall,
                            icon: Icons.warning,
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

  Widget _buildDangerIndicator(
    BuildContext context, {
    required String label,
    required bool isActive,
    required IconData icon,
  }) {
    final Color indicatorColor = isActive ? AppColors.coral : AppColors.mintGreen; // Updated to coral and mintGreen
    final Color textColor = isActive ? AppColors.softWhite : AppColors.charcoal; // Updated to softWhite and charcoal
    final Color backgroundColor = isActive ? indicatorColor : AppColors.softWhite; // Updated to softWhite

    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: backgroundColor,
            border: Border.all(
              color: indicatorColor,
              width: 2,
            ),
          ),
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) {
                return ScaleTransition(
                  scale: animation,
                  child: child,
                );
              },
              child: Icon(
                icon,
                key: ValueKey<bool>(isActive),
                size: 50,
                color: textColor,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyles.bodyText1.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.charcoal, // Updated to charcoal
          ),
        ),
        Text(
          isActive ? 'Detected!' : 'Normal',
          style: TextStyles.bodyText2.copyWith(
            color: indicatorColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
