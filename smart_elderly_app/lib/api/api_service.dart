import 'package:http/http.dart' as http;
import 'package:smart_elderly_app/api/endpoints.dart';
import 'dart:convert';

class ApiService {
  final http.Client client;

  ApiService({required this.client});

  Future<http.Response> post(String endpoint, dynamic body) async {
    return await client.post(
      Uri.parse(endpoint),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );
  }

  Future<http.Response> get(String endpoint) async {
    return await client.get(
      Uri.parse(endpoint),
      headers: {'Content-Type': 'application/json'},
    );
  }

  // Authentication Methods
  Future<http.Response> login(String email, String password) async {
    return await post(
      Endpoints.login,
      jsonEncode({'email': email, 'password': password}),
    );
  }

  // Sensor Data Methods
  Future<http.Response> getSensorData(String deviceId) async {
    return await get('${Endpoints.sensorData}?device_id=$deviceId');
  }

  // Alert Methods
  Future<http.Response> handleAlert(String deviceId, String alertType) async {
    return await post(
      Endpoints.handleAlert,
      jsonEncode({'device_id': deviceId, 'alert_type': alertType}),
    );
  }
}
