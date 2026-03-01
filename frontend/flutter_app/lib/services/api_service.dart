/// api_service.dart
/// Main REST API client integrated with Spring Boot backend and JWT support.

import 'package:dio/dio.dart';
import '../models/user.dart';
import '../models/hospital.dart';
import '../models/system_log.dart';
import 'api_service_interface.dart';

class ApiService implements ApiServiceInterface {
  static final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://localhost:8080',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 15),
  ));

  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
  }

  @override
  Future<List<User>> getUsers() async {
    try {
      final response = await _dio.get('/users');
      return (response.data as List).map((json) => User.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching users: $e');
      rethrow;
    }
  }

  @override
  Future<List<Hospital>> getHospitals() async {
    try {
      final response = await _dio.get('/hospitals');
      return (response.data as List).map((json) => Hospital.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching hospitals: $e');
      rethrow;
    }
  }

  @override
  Future<List<SystemLog>> getSystemLogs() async {
    try {
      final response = await _dio.get('/system/logs');
      return (response.data as List).map((json) => SystemLog.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching logs: $e');
      rethrow;
    }
  }
}

final ApiService apiService = ApiService();

// JWT Token Interceptor
void setupInterceptors() {
  ApiService._dio.interceptors.add(InterceptorsWrapper(
    onError: (DioException e, ErrorInterceptorHandler handler) async {
      if (e.response?.statusCode == 401) {
        print('⚠️ Unauthorized request - JWT may be expired.');
        // Optional: Navigate user back to login screen
      }
      return handler.next(e);
    },
  ));
}
