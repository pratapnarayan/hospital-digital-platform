/// auth_service.dart
/// Handles real user authentication with JWT token management.

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_service.dart';
import 'auth_service_interface.dart';

class AuthService implements AuthServiceInterface {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://localhost:8080'));
  final _storage = const FlutterSecureStorage();

  @override
  Future<bool> login(String email, String password, [String? role]) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'username': email,
        'password': password,
      });

      if (response.statusCode == 200 && response.data['token'] != null) {
        final token = response.data['token'];

        // Save JWT in secure storage
        await _storage.write(key: 'jwt_token', value: token);

        // Set token globally for all Dio instances
        apiService.setAuthToken(token);
        return true;
      }
    } catch (e) {
      print('Login failed: $e');
    }
    return false;
  }

  @override
  Future<bool> register(String name, String email, String password, [String? medicalId]) async {
    try {
      final response = await _dio.post('/auth/register', data: {
        'name': name,
        'username': email,
        'password': password,
      });

      return response.statusCode == 200;
    } catch (e) {
      print('Registration failed: $e');
      return false;
    }
  }

  @override
  Future<void> logout() async {
    await _storage.delete(key: 'jwt_token');
    apiService.clearAuthToken();
  }

  /// Utility to restore JWT token after app restart
  Future<void> restoreSession() async {
    final token = await _storage.read(key: 'jwt_token');
    if (token != null) {
      apiService.setAuthToken(token);
    }
  }

  @override
  bool get isLoggedIn => throw UnimplementedError();

  @override
  String? get currentUserId => throw UnimplementedError();

  @override
  String? get currentUserRole => throw UnimplementedError();

  @override
  String? get currentUserName => throw UnimplementedError();
}

final AuthService authService = AuthService();
