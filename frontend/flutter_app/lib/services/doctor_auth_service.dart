/// doctor_auth_service.dart
/// Standalone helper for Doctor registration.
/// Does NOT modify AuthServiceInterface — keeps the patient register path intact.

import 'package:dio/dio.dart';

final Dio _dio = Dio(BaseOptions(baseUrl: 'http://localhost:8080'));

/// Registers a new DOCTOR user.
///
/// [phoneNumber] is mandatory for all new registrations (backend enforces it).
/// Returns null on success, or an error message string on failure.
Future<String?> registerDoctor({
  required String email,
  required String password,
  required String hospitalId,
  required String phoneNumber,
}) async {
  try {
    final response = await _dio.post('/auth/register', data: {
      'username': email,
      'password': password,
      'role': 'DOCTOR',
      'hospitalId': hospitalId,
      'phoneNumber': phoneNumber,
    });

    if (response.statusCode == 200) {
      return null; // success
    }
    return 'Registration failed. Please try again.';
  } on DioException catch (e) {
    final data = e.response?.data;
    // Backend returns { success: false, message: "..." } for structured errors,
    // or a plain String for simple rejections.
    if (data is Map && data['message'] != null) {
      return data['message'] as String;
    }
    if (data is String && data.isNotEmpty) {
      return data;
    }
    if (e.response?.statusCode == 409) {
      return 'An account with this email or phone number already exists.';
    }
    if (e.response?.statusCode == 400) {
      return 'Invalid registration data. Please check all fields.';
    }
    return 'Could not connect to server. Please try again.';
  }
}
