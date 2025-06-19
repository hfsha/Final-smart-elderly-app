import 'package:intl/intl.dart';

class SensorData {
  final double temperature;
  final double humidity;
  final bool motion;
  final bool fallDetected;
  final bool fireDetected;
  final DateTime timestamp;

  SensorData({
    required this.temperature,
    required this.humidity,
    required this.motion,
    required this.fallDetected,
    required this.fireDetected,
    required this.timestamp,
  });

  factory SensorData.fromJson(Map<String, dynamic> json) {
    return SensorData(
      temperature: json['temperature']?.toDouble() ?? 0.0,
      humidity: json['humidity']?.toDouble() ?? 0.0,
      motion: json['motion'] == 1,
      fallDetected: json['fall_detected'] == 1,
      fireDetected: json['fire_detected'] == 1,
      timestamp: json['timestamp'] != null ? DateTime.parse(json['timestamp']) : DateTime.now(),
    );
  }

  String get formattedTime {
    return DateFormat('h:mm a').format(timestamp);
  }
}
