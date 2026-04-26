import 'package:dio/dio.dart';
import '../models/appointment_model.dart';
import 'api_service.dart';

class AppointmentServiceException implements Exception {
  final String message;
  final int? statusCode;
  AppointmentServiceException(this.message, {this.statusCode});
}

class AppointmentService {

  Future<Appointment> createAppointment({
    required String patientId,
    required DateTime appointmentTime,
    required int durationMinutes,
    required String reason,
  }) async {
    try {
      final response = await apiService.dio.post('/appointment', data: {
        'patientId': patientId,
        'appointmentTime': appointmentTime.toUtc().toIso8601String(),
        'durationMinutes': durationMinutes,
        'reason': reason,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        // According to backend mapping AppointmentResponse is returned identically
        return Appointment.fromJson(response.data);
      }
      throw AppointmentServiceException('Failed to create appointment');
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        throw AppointmentServiceException(
          'This time slot is already booked. Please choose another.',
          statusCode: 409,
        );
      }
      throw AppointmentServiceException(
        e.response?.data?['message'] ?? 'Unable to connect to service',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      throw AppointmentServiceException('Unexpected error occurred: $e');
    }
  }

  Future<List<Appointment>> getPatientAppointments({int page = 0, int size = 10}) async {
    try {
      final response = await apiService.dio.get('/appointment/patient', queryParameters: {
        'page': page,
        'size': size,
      });

      if (response.statusCode == 200) {
        // Backend returns Page<AppointmentResponse>. We extract 'content' array.
        final List content = response.data['content'] ?? [];
        return content.map((json) => Appointment.fromJson(json)).toList();
      }
    } on DioException catch (e) {
      print('DioError fetching appointments: ${e.response?.statusCode}');
    } catch (e) {
      print('Error fetching patient appointments: $e');
    }
    return [];
  }
}

// Singleton instance
final appointmentService = AppointmentService();
