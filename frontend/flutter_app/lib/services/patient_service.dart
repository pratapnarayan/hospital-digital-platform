import '../models/patient_model.dart';
import '../models/record_model.dart';
import 'api_service.dart';

class PatientService {

  Future<Map<String, dynamic>?> createPatient({
    required String name,
    required int age,
    required String gender,
    required String phone,
  }) async {
    try {
      final response = await apiService.dio.post('/patient/register', data: {
        'name': name,
        'age': age,
        'gender': gender,
        'phone': phone,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'patient': Patient.fromJson(response.data['patient']),
          'credentials': response.data['credentials'],
        };
      }
    } catch (e) {
      print('Error creating patient: $e');
    }
    return null;
  }

  Future<List<Patient>> getPatients() async {
    try {
      final response = await apiService.dio.get('/patient/list');
      if (response.statusCode == 200) {
        return (response.data as List).map((json) => Patient.fromJson(json)).toList();
      }
    } catch (e) {
      print('Error fetching patients: $e');
    }
    return [];
  }

  Future<Patient?> getPatientById(String id) async {
    try {
      final response = await apiService.dio.get('/patient/$id');
      if (response.statusCode == 200) {
        return Patient.fromJson(response.data);
      }
    } catch (e) {
      print('Error fetching patient: $e');
    }
    return null;
  }

  Future<MedicalRecord?> createMedicalRecord({
    required String patientId,
    required String title,
    required String description,
    required String diagnosis,
  }) async {
    try {
      final response = await apiService.dio.post('/record', data: {
        'patientId': patientId,
        'title': title,
        'description': description,
        'diagnosis': diagnosis,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        return MedicalRecord.fromJson(response.data);
      }
    } catch (e) {
      print('Error creating medical record: $e');
    }
    return null;
  }

  Future<List<MedicalRecord>> getPatientRecords(String patientId) async {
    try {
      final response = await apiService.dio.get('/record/patient/$patientId');
      if (response.statusCode == 200) {
        return (response.data as List).map((json) => MedicalRecord.fromJson(json)).toList();
      }
    } catch (e) {
      print('Error fetching patient records: $e');
    }
    return [];
  }
}

// Singleton instance
final patientService = PatientService();
