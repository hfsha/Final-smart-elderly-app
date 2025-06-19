import 'dart:convert';
import 'package:http/http.dart' as http;

class DeviceCommandService {
  static Future<void> sendRelayCommand(String deviceId, bool on) async {
    final url = Uri.parse('https://humancc.site/shahidatulhidayah/smart-elderly-app/api/device/command.php');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'device_id': deviceId,
        'command_type': 'relay',
        'command_value': on ? 1 : 0,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to send relay command: \\${response.body}');
    }
  }
} 