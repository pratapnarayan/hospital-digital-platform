class AuthService {
  String? _currentUserId;
  String? _currentUserRole;
  String? _currentUserName;

  bool get isLoggedIn => _currentUserId != null;
  String? get currentUserId => _currentUserId;
  String? get currentUserRole => _currentUserRole;
  String? get currentUserName => _currentUserName;

  Future<bool> login(String email, String password, String role) async {
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 500));

    // Mock authentication - accept any credentials
    _currentUserId = email.split('@').first;
    _currentUserRole = role;
    _currentUserName = _getUserNameByRole(role);

    return true;
  }

  Future<bool> register(
    String name,
    String email,
    String password,
    String? medicalId,
  ) async {
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 500));

    _currentUserId = email.split('@').first;
    _currentUserRole = 'patient';
    _currentUserName = name;

    return true;
  }

  void logout() {
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

// Singleton instance
final authService = AuthService();
