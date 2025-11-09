import '../models/user_model.dart';

class ApiService {
  // Mock Users
  List<User> getMockUsers() {
    return [
      User(
        id: 1,
        name: 'Dr. Michael Chen',
        email: 'michael.chen@hospital.com',
        role: 'Doctor',
        hospital: 'City General Hospital',
        status: 'Active',
      ),
      User(
        id: 2,
        name: 'Dr. Sarah Williams',
        email: 'sarah.w@hospital.com',
        role: 'Doctor',
        hospital: 'St. Mary Medical Center',
        status: 'Active',
      ),
      User(
        id: 3,
        name: 'Sarah Johnson',
        email: 'sarah.j@email.com',
        role: 'Patient',
        hospital: '-',
        status: 'Active',
      ),
      User(
        id: 4,
        name: 'Michael Brown',
        email: 'michael.b@email.com',
        role: 'Patient',
        hospital: '-',
        status: 'Active',
      ),
      User(
        id: 5,
        name: 'Admin User',
        email: 'admin@system.com',
        role: 'Admin',
        hospital: 'System',
        status: 'Active',
      ),
      User(
        id: 6,
        name: 'Dr. James Anderson',
        email: 'james.a@hospital.com',
        role: 'Doctor',
        hospital: 'City General Hospital',
        status: 'Inactive',
      ),
    ];
  }

  // Mock Hospitals
  List<Hospital> getMockHospitals() {
    return [
      Hospital(
        id: 1,
        name: 'City General Hospital',
        location: 'New York, NY',
        type: 'General',
        patients: 1247,
        doctors: 86,
        status: 'Active',
      ),
      Hospital(
        id: 2,
        name: 'St. Mary Medical Center',
        location: 'Los Angeles, CA',
        type: 'Specialty',
        patients: 892,
        doctors: 54,
        status: 'Active',
      ),
      Hospital(
        id: 3,
        name: 'Children\'s Healthcare',
        location: 'Chicago, IL',
        type: 'Pediatric',
        patients: 634,
        doctors: 42,
        status: 'Active',
      ),
      Hospital(
        id: 4,
        name: 'Regional Medical Center',
        location: 'Houston, TX',
        type: 'General',
        patients: 1056,
        doctors: 68,
        status: 'Active',
      ),
      Hospital(
        id: 5,
        name: 'Downtown Clinic',
        location: 'Boston, MA',
        type: 'Clinic',
        patients: 423,
        doctors: 28,
        status: 'Inactive',
      ),
    ];
  }

  // Mock System Logs
  List<SystemLog> getMockSystemLogs() {
    return [
      SystemLog(
        id: 1,
        timestamp: 'Nov 9, 2025 14:32',
        action: 'User Login',
        user: 'Dr. Michael Chen',
        details: 'Doctor portal access granted',
        level: 'info',
      ),
      SystemLog(
        id: 2,
        timestamp: 'Nov 9, 2025 14:28',
        action: 'Record Updated',
        user: 'Dr. Sarah Williams',
        details: 'Patient MED-784932 medical history updated',
        level: 'info',
      ),
      SystemLog(
        id: 3,
        timestamp: 'Nov 9, 2025 14:15',
        action: 'Failed Login Attempt',
        user: 'unknown@example.com',
        details: 'Invalid credentials provided',
        level: 'warning',
      ),
      SystemLog(
        id: 4,
        timestamp: 'Nov 9, 2025 13:58',
        action: 'New User Created',
        user: 'System Admin',
        details: 'New patient account: Emily Davis',
        level: 'info',
      ),
      SystemLog(
        id: 5,
        timestamp: 'Nov 9, 2025 13:45',
        action: 'System Error',
        user: 'System',
        details: 'Database connection timeout',
        level: 'error',
      ),
      SystemLog(
        id: 6,
        timestamp: 'Nov 9, 2025 13:30',
        action: 'Hospital Added',
        user: 'System Admin',
        details: 'New hospital registered: Regional Medical Center',
        level: 'success',
      ),
    ];
  }

  Future<List<User>> getUsers() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return getMockUsers();
  }

  Future<List<Hospital>> getHospitals() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return getMockHospitals();
  }

  Future<List<SystemLog>> getSystemLogs() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return getMockSystemLogs();
  }
}

// Singleton instance
final apiService = ApiService();
