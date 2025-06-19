class Device {
  final String id;
  final String type;
  final bool isActive;
  final DateTime lastSeen;

  Device({
    required this.id,
    required this.type,
    required this.isActive,
    required this.lastSeen,
  });

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      id: json['device_id'],
      type: json['device_type'],
      isActive: json['is_active'],
      lastSeen: DateTime.parse(json['last_seen']),
    );
  }
}
