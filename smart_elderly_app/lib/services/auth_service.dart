import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_elderly_app/api/api_service.dart';
import 'package:smart_elderly_app/api/endpoints.dart';
import 'package:smart_elderly_app/models/user.dart';
import 'dart:convert';

class AuthService with ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  final ApiService _apiService;

  AuthService({required ApiService apiService}) : _apiService = apiService;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;

  Future<void> initialize() async {
    // Commented out persistent login for always requiring login after restart
    // final prefs = await SharedPreferences.getInstance();
    // final userJson = prefs.getString('user');

    // if (userJson != null) {
    //   _currentUser = User.fromJson(jsonDecode(userJson));
    //   notifyListeners();
    // }
    _currentUser = null;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.login(email, password);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _currentUser = User.fromJson(data['data']['user']);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user', jsonEncode(_currentUser?.toJson()));
      } else {
        throw Exception('Login failed: ${response.body}');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
    _currentUser = null;
    notifyListeners();
  }

  Future<void> register(String name, String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.post(
        Endpoints.register,
        jsonEncode({'name': name, 'email': email, 'password': password}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _currentUser = User.fromJson(data['data']['user']);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user', jsonEncode(_currentUser?.toJson()));
      } else {
        throw Exception('Registration failed: ${response.body}');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
