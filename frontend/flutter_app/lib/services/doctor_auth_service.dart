/// doctor_auth_service.dart
/// Standalone helper for Doctor registration.
/// Does NOT modify AuthServiceInterface — keeps the patient register path intact.

import 'package:dio/dio.dart';

final Dio _dio = Dio(BaseOptions(baseUrl: 'http://localhost:8080'));

/// Registers a new DOCTOR user.
///
/// Returns null on success, or an error message string on failure.
Future<String?> registerDoctor({
  required String email,
  required String password,
  required String hospitalId,
}) async {
  try {
    final response = await _dio.post('/auth/register', data: {
      'username': email,
      'password': password,
      'role': 'DOCTOR',
      'hospitalId': hospitalId,
    });

    if (response.statusCode == 200) {
      return null; // success
    }
    return 'Registration failed. Please try again.';
  } on DioException catch (e) {
    final message = e.response?.data;
    if (message is String && message.isNotEmpty) {
      return message;
    }
    if (e.response?.statusCode == 409) {
      return 'An account with this email already exists.';
    }
    if (e.response?.statusCode == 400) {
      return 'Invalid registration data. Please check all fields.';
    }
    return 'Could not connect to server. Please try again.';
  }
}
