import 'package:dio/dio.dart';
import '../models/doctor_appointment_model.dart';
import 'api_service.dart';

class DoctorAppointmentServiceException implements Exception {
  final String message;
  final int? statusCode;
  DoctorAppointmentServiceException(this.message, {this.statusCode});
}

class DoctorAppointmentService {
  Future<List<DoctorAppointment>> getDoctorAppointments({
    required DateTime date,
    int page = 0,
    int size = 10,
  }) async {
    try {
      final formattedDate = 
          '${date.year.toString().padLeft(4, '0')}-'
          '${date.month.toString().padLeft(2, '0')}-'
          '${date.day.toString().padLeft(2, '0')}';

      final response = await apiService.dio.get('/appointment/doctor', queryParameters: {
        'date': formattedDate,
        'page': page,
        'size': size,
      });

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic> && data['success'] == true && data['data'] != null) {
          final List content = data['data'];
          return content.map((json) => DoctorAppointment.fromJson(json)).toList();
        } else if (data['content'] != null) { // Fallback if backend returns Page response directly
           final List content = data['content'];
           return content.map((json) => DoctorAppointment.fromJson(json)).toList();
        }
      }
      return [];
    } on DioException catch (e) {
      throw DoctorAppointmentServiceException(
        e.response?.data?['message'] ?? 'Failed to load appointments',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      throw DoctorAppointmentServiceException('An unexpected error occurred: $e');
    }
  }

  Future<DoctorAppointment> updateAppointmentStatus({
    required String appointmentId,
    required String status,
  }) async {
    try {
      final response = await apiService.dio.put('/appointment/$appointmentId/status', data: {
        'status': status.toUpperCase(),
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        return DoctorAppointment.fromJson(response.data);
      }
      throw DoctorAppointmentServiceException('Failed to update status');
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        throw DoctorAppointmentServiceException(
          'Failed due to conflict. Status might already be finalized.',
          statusCode: 409,
        );
      }
      throw DoctorAppointmentServiceException(
        e.response?.data?['message'] ?? 'Unable to connect to service',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      throw DoctorAppointmentServiceException('Unexpected error occurred: $e');
    }
  }
}

// Singleton instance
final doctorAppointmentService = DoctorAppointmentService();
