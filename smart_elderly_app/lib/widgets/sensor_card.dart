import 'package:flutter/material.dart';
import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';

class SensorCard extends StatelessWidget {
  final String title;
  final double value;
  final String unit;
  final Color color;
  final IconData icon;

  const SensorCard({
    super.key,
    required this.title,
    required this.value,
    required this.unit,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 100,
              width: 100,
              child: LiquidCircularProgressIndicator(
                value: value / 100,
                valueColor: AlwaysStoppedAnimation(color),
                backgroundColor: Colors.white,
                borderColor: color,
                borderWidth: 2.0,
                center: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 24, color: color),
                    Text(
                      '${value.toStringAsFixed(1)}$unit',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
