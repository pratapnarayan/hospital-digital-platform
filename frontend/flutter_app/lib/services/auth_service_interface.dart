abstract class AuthServiceInterface {
  Future<bool> login(String email, String password, [String? role]);
  Future<bool> register(String name, String email, String password, [String? medicalId]);
  Future<void> logout();
  Future<bool> resetPassword(String username, String currentPassword, String newPassword);
  Future<ForgotPasswordResult> forgotPassword(String phoneNumber);
  Future<bool> resetPasswordWithToken(String phoneNumber, String token, String newPassword);

  bool get isLoggedIn;
  bool get requiresPasswordReset;
  String? get currentUserId;
  String? get currentPatientId;
  String? get currentUserRole;
  String? get currentUserName;
}

/// Result of a forgot-password API call.
///
/// [devResetToken] is populated in MVP/development mode when the backend returns
/// the token directly (no SMS). It will be null once SMS integration is live.
class ForgotPasswordResult {
  final bool success;
  final String message;
  final String? devResetToken;

  const ForgotPasswordResult({
    required this.success,
    required this.message,
    this.devResetToken,
  });
}
