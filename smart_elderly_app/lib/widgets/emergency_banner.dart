import 'package:flutter/material.dart';

class EmergencyBanner extends StatelessWidget {
  final bool isAlert;
  final String alertType; // 'fire', 'fall', 'both', or ''
  final bool relayOn;
  final ValueChanged<bool> onRelayToggle;

  const EmergencyBanner({
    super.key,
    required this.isAlert,
    required this.alertType,
    required this.relayOn,
    required this.onRelayToggle,
  });

  Color _getBannerColor() {
    if (!isAlert) return Colors.green[600]!;
    if (alertType == 'both') return Colors.red[900]!;
    if (alertType == 'fire') return Colors.red[700]!;
    if (alertType == 'fall') return Colors.orange[800]!;
    return Colors.red[700]!;
  }

  IconData _getBannerIcon() {
    if (!isAlert) return Icons.check_circle;
    if (alertType == 'both') return Icons.priority_high;
    if (alertType == 'fire') return Icons.local_fire_department;
    if (alertType == 'fall') return Icons.directions_walk;
    return Icons.warning;
  }

  String _getTitle() {
    if (!isAlert) return 'All Safe';
    if (alertType == 'both') return 'HIGH ALERT!';
    if (alertType == 'fire') return 'Fire Alert!';
    if (alertType == 'fall') return 'Fall Alert!';
    return 'Alert!';
  }

  String _getMessage() {
    if (!isAlert) return 'No emergency detected.';
    if (alertType == 'both') return 'Fire and fall detected! Please act immediately!';
    if (alertType == 'fire') return 'A fire has been detected. Please act now!';
    if (alertType == 'fall') return 'A fall has been detected. Please check immediately!';
    return 'Emergency detected!';
  }

  @override
  Widget build(BuildContext context) {
    final color = _getBannerColor();
    final icon = _getBannerIcon();
    final title = _getTitle();
    final message = _getMessage();

    return Card(
      color: color,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(10),
              child: Icon(icon, size: 36, color: Colors.white),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                const Text('Alarm', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Opacity(
                  opacity: relayOn ? 1.0 : 0.5, // Less opaque when OFF
                  child: Switch(
                    value: relayOn,
                    onChanged: relayOn ? onRelayToggle : null, // Only allow turning OFF
                    activeColor: Colors.white,
                    inactiveThumbColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
