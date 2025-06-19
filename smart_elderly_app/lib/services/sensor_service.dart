import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:smart_elderly_app/api/api_service.dart';
import 'package:smart_elderly_app/api/endpoints.dart';
import 'package:smart_elderly_app/models/alert.dart';
import 'package:smart_elderly_app/models/device.dart';
import 'package:smart_elderly_app/models/sensor_data.dart';
import 'dart:convert';
import 'dart:isolate';

class SensorService with ChangeNotifier {
  final ApiService _apiService;
  List<SensorData> _sensorData = [];
  List<SensorData> _trendsSensorData = [];
  final List<Alert> _alerts = [];
  final List<Device> _devices = [];
  bool _isLoading = false;
  Timer? _updateTimer;
  bool _isUpdating = false;

  // Cache for trends data
  final Map<String, List<SensorData>> _trendsCache = {};
  final Map<String, DateTime> _cacheTimestamp = {};
  static const Duration _cacheDuration = Duration(minutes: 5);

  SensorService({required ApiService apiService}) : _apiService = apiService;

  List<SensorData> get sensorData => _sensorData;
  List<Alert> get alerts => _alerts;
  List<Device> get devices => _devices;
  bool get isLoading => _isLoading;
  SensorData? get latestData => _sensorData.isNotEmpty ? _sensorData.last : null;
  List<SensorData> get trendsData => _trendsSensorData;

  Future<void> fetchSensorData(String deviceId) async {
    if (_isUpdating) return; // Prevent concurrent updates
    _isUpdating = true;
    
    try {
      final response = await _apiService.getSensorData(deviceId);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final newData = [SensorData.fromJson(data['data'])];
        
        // Only notify if data actually changed
        if (_sensorData.isEmpty || !_areSensorDataListsEqual(_sensorData, newData)) {
          _sensorData = newData;
          notifyListeners();
        }
      }
    } catch (e) {
      print('Error fetching sensor data: $e');
    } finally {
      _isUpdating = false;
    }
  }

  bool _areSensorDataListsEqual(List<SensorData> list1, List<SensorData> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i].timestamp != list2[i].timestamp ||
          list1[i].temperature != list2[i].temperature ||
          list1[i].humidity != list2[i].humidity ||
          list1[i].motion != list2[i].motion ||
          list1[i].fallDetected != list2[i].fallDetected ||
          list1[i].fireDetected != list2[i].fireDetected) {
        return false;
      }
    }
    return true;
  }

  Future<void> dismissAlert(String deviceId, String alertType) async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();
    
    try {
      final response = await _apiService.handleAlert(deviceId, alertType);
      if (response.statusCode == 200) {
        await fetchSensorData(deviceId);
      }
    } catch (e) {
      print('Error dismissing alert: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchTrendsData({required int hours, required String deviceId}) async {
    final cacheKey = '${deviceId}_$hours';

    // Check cache first
    if (_trendsCache.containsKey(cacheKey)) {
      final cacheTime = _cacheTimestamp[cacheKey];
      if (cacheTime != null && DateTime.now().difference(cacheTime) < _cacheDuration) {
        _trendsSensorData = _trendsCache[cacheKey]!;
        notifyListeners();
        return;
      }
    }

    _isLoading = true;
    notifyListeners();

    try {
      final int dataPointsLimit = 100;
      final String apiUrl = '${Endpoints.sensorTrends}?device_id=$deviceId&hours=$hours&limit=$dataPointsLimit';
      final response = await _apiService.get(apiUrl);

      if (response.statusCode == 200) {
        // Process JSON in a separate isolate
        final data = await compute(_parseTrendsData, response.body);
        if (data != null) {
          _trendsSensorData = data;
          _trendsCache[cacheKey] = data;
          _cacheTimestamp[cacheKey] = DateTime.now();
          notifyListeners();
        }
      }
    } catch (e) {
      print('Error fetching trends data: $e');
      _trendsSensorData = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Static method to parse JSON in a separate isolate
  static List<SensorData>? _parseTrendsData(String jsonString) {
    try {
      final data = jsonDecode(jsonString);
      return (data['data'] as List)
          .map((item) => SensorData.fromJson(item))
          .toList();
    } catch (e) {
      print('Error parsing trends data: $e');
      return null;
    }
  }

  void startMonitoring(String deviceId, {int interval = 10}) {
    _updateTimer?.cancel();
    fetchSensorData(deviceId);

    _updateTimer = Timer.periodic(Duration(seconds: interval), (_) {
      fetchSensorData(deviceId);
    });
  }

  void stopMonitoring() {
    _updateTimer?.cancel();
    _updateTimer = null;
  }

  void clearCache() {
    _trendsCache.clear();
    _cacheTimestamp.clear();
  }

  @override
  void dispose() {
    stopMonitoring();
    clearCache();
    super.dispose();
  }
}
