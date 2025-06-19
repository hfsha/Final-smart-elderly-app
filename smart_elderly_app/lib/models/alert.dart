class Alert {
  final String id;
  final String deviceId;
  final String alertType;
  final DateTime timestamp;
  final bool isHandled;

  Alert({
    required this.id,
    required this.deviceId,
    required this.alertType,
    required this.timestamp,
    required this.isHandled,
  });

  factory Alert.fromJson(Map<String, dynamic> json) {
    return Alert(
      id: json['id'],
      deviceId: json['device_id'],
      alertType: json['alert_type'],
      timestamp: DateTime.parse(json['timestamp']),
      isHandled: json['is_handled'],
    );
  }
}
