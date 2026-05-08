abstract class AuthServiceInterface {
  Future<bool> login(String email, String password, [String? role]);
  Future<bool> register(String name, String email, String password, [String? medicalId]);
  Future<void> logout();
  Future<bool> resetPassword(String username, String currentPassword, String newPassword);
  bool get isLoggedIn;
  bool get requiresPasswordReset;
  String? get currentUserId;
  String? get currentPatientId;
  String? get currentUserRole;
  String? get currentUserName;
}
