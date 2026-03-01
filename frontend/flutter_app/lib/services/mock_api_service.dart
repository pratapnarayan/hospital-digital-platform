/// mock_api_service.dart
/// Mock data layer generated from Figma for offline UI testing.

import '../models/user.dart';
import '../models/hospital.dart';
import '../models/system_log.dart';
import 'api_service_interface.dart';

class MockApiService implements ApiServiceInterface {
  List<User> getMockUsers() => [
    User(id: 1, name: 'Dr. Michael Chen', email: 'michael.chen@hospital.com', role: 'Doctor', hospital: 'City General Hospital', status: 'Active'),
    User(id: 2, name: 'Sarah Johnson', email: 'sarah.j@email.com', role: 'Patient', hospital: '-', status: 'Active'),
  ];

  List<Hospital> getMockHospitals() => [
    Hospital(id: 1, name: 'City General Hospital', location: 'New York', type: 'General', patients: 1247, doctors: 86, status: 'Active'),
  ];

  List<SystemLog> getMockSystemLogs() => [
    SystemLog(id: 1, timestamp: 'Nov 9, 2025 14:32', action: 'User Login', user: 'Dr. Michael Chen', details: 'Doctor portal access granted', level: 'info'),
  ];

  @override
  Future<List<User>> getUsers() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return getMockUsers();
  }

  @override
  Future<List<Hospital>> getHospitals() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return getMockHospitals();
  }

  @override
  Future<List<SystemLog>> getSystemLogs() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return getMockSystemLogs();
  }
}

final MockApiService mockApiService = MockApiService();
