abstract class AuthServiceInterface {
  Future<bool> login(String email, String password, [String? role]);
  Future<bool> register(String name, String email, String password, [String? medicalId]);
  Future<void> logout();
  bool get isLoggedIn;
  String? get currentUserId;
  String? get currentUserRole;
  String? get currentUserName;
}
