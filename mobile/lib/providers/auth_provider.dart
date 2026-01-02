import 'dart:async';
import 'package:flutter/material.dart';
import 'package:grpc/grpc.dart';
import 'package:smart_campus/generated/auth.pbgrpc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  AuthServiceClient? _client;
  String? _accessToken;
  String? _refreshToken;
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get accessToken => _accessToken;
  bool get isAuthenticated => _accessToken != null;

  AuthProvider() {
    _initClient();
    _loadTokens();
  }

  void _initClient() {
    final channel = ClientChannel(
      '10.0.2.2', // Измени на IP сервера если нужно
      port: 50051,
      options: const ChannelOptions(
        credentials: ChannelCredentials.insecure(),
        idleTimeout: Duration(minutes: 1),
      ),
    );
    _client = AuthServiceClient(channel);
  }

  Future<void> _loadTokens() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString('access_token');
    _refreshToken = prefs.getString('refresh_token');
    notifyListeners();
  }

  Future<void> _saveTokens(String accessToken, String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', accessToken);
    await prefs.setString('refresh_token', refreshToken);
    _accessToken = accessToken;
    _refreshToken = refreshToken;
  }

  Future<void> register(
    String email,
    String password,
    String fullName,
    String role,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final request = RegisterRequest()
        ..email = email
        ..password = password
        ..fullName = fullName
        ..role = role;

      final response = await _client!.register(request);

      if (response.success) {
        // После регистрации автоматически логинимся
        await login(email, password);
      } else {
        _error = response.error;
      }
    } catch (e) {
      _error = 'Registration failed: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final request = LoginRequest()
        ..email = email
        ..password = password;

      final response = await _client!.login(request);

      if (response.success) {
        await _saveTokens(response.accessToken, response.refreshToken);
        _error = null;
      } else {
        _error = response.error;
      }
    } catch (e) {
      _error = 'Login failed: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    _accessToken = null;
    _refreshToken = null;
    notifyListeners();
  }

  Future<bool> validateToken() async {
    if (_accessToken == null) return false;

    try {
      final request = ValidateRequest()..token = _accessToken!;
      final response = await _client!.validateToken(request);
      return response.valid;
    } catch (e) {
      return false;
    }
  }
}
