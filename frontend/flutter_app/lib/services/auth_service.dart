/// auth_service.dart
/// Handles real user authentication with JWT token management.

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_service.dart';
import 'auth_service_interface.dart';
import 'jwt_decoder.dart';

class AuthService implements AuthServiceInterface {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://localhost:8080'));
  final _storage = const FlutterSecureStorage();

  // In-memory decoded JWT claims (cleared on logout)
  String? _currentUserId;
  String? _currentUserRole;
  String? _currentHospitalId;

  @override
  bool get isLoggedIn => _currentUserId != null;

  @override
  String? get currentUserId => _currentUserId;

  @override
  String? get currentUserRole => _currentUserRole;

  @override
  String? get currentUserName => _currentUserId; // username is the email/login field

  /// The hospitalId extracted from the JWT (available for DOCTOR role).
  String? get currentHospitalId => _currentHospitalId;

  @override
  Future<bool> login(String email, String password, [String? role]) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'username': email,
        'password': password,
      });

      if (response.statusCode == 200 && response.data['token'] != null) {
        final token = response.data['token'] as String;

        // Save JWT in secure storage
        await _storage.write(key: 'jwt_token', value: token);

        // Set token globally for all Dio instances
        apiService.setAuthToken(token);

        // Decode claims and cache them in memory
        _applyTokenClaims(token);

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
    _currentUserId = null;
    _currentUserRole = null;
    _currentHospitalId = null;
  }

  /// Utility to restore JWT token after app restart and re-populate in-memory claims.
  Future<void> restoreSession() async {
    final token = await _storage.read(key: 'jwt_token');
    if (token != null) {
      apiService.setAuthToken(token);
      _applyTokenClaims(token);
    }
  }

  /// Decodes the JWT and stores claims in memory.
  void _applyTokenClaims(String token) {
    _currentUserId = JwtDecoder.getUserId(token);
    _currentUserRole = JwtDecoder.getRole(token);
    _currentHospitalId = JwtDecoder.getHospitalId(token);
  }
}

final AuthService authService = AuthService();
