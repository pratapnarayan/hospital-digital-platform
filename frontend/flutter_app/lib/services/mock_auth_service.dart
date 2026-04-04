/// mock_auth_service.dart
/// Mock authentication service generated from Figma for offline UI testing.

import 'auth_service_interface.dart';

class MockAuthService implements AuthServiceInterface {
  String? _currentUserId;
  String? _currentUserRole;
  String? _currentUserName;

  bool get isLoggedIn => _currentUserId != null;
  String? get currentUserId => _currentUserId;
  String? get currentPatientId => _currentUserId;
  String? get currentUserRole => _currentUserRole;
  String? get currentUserName => _currentUserName;

  @override
  Future<bool> login(String email, String password, [String? role]) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentUserId = email.split('@').first;
    _currentUserRole = role;
    _currentUserName = _getUserNameByRole(role ?? 'user');
    return true;
  }

  @override
  Future<bool> register(String name, String email, String password, [String? medicalId]) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentUserId = email.split('@').first;
    _currentUserRole = 'patient';
    _currentUserName = name;
    return true;
  }

  @override
  Future<void> logout() async {
    _currentUserId = null;
    _currentUserRole = null;
    _currentUserName = null;
  }

  String _getUserNameByRole(String role) {
    switch (role) {
      case 'patient':
        return 'Sarah Johnson';
      case 'doctor':
        return 'Dr. Michael Chen';
      case 'admin':
        return 'System Admin';
      default:
        return 'User';
    }
  }
}

final MockAuthService mockAuthService = MockAuthService();
