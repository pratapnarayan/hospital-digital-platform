import 'package:flutter/material.dart';
import 'patient_login_screen.dart';
import 'patient_dashboard_screen.dart';
import 'medical_history_screen.dart';
import 'upload_prescription_screen.dart';
import 'patient_profile_screen.dart';
import 'reset_password_screen.dart';

enum PatientScreen { login, resetPassword, dashboard, history, upload, profile }

class PatientApp extends StatefulWidget {
  const PatientApp({super.key});

  @override
  State<PatientApp> createState() => _PatientAppState();
}

class _PatientAppState extends State<PatientApp> {
  PatientScreen _currentScreen = PatientScreen.login;
  bool _isLoggedIn = false;
  String _pendingUsername = '';
  String _pendingPassword = '';

  void _handleLogin() {
    setState(() {
      _isLoggedIn = true;
      _currentScreen = PatientScreen.dashboard;
      _pendingUsername = '';
      _pendingPassword = '';
    });
  }

  void _handleResetPassword(String username, String currentPassword) {
    setState(() {
      _pendingUsername = username;
      _pendingPassword = currentPassword;
      _currentScreen = PatientScreen.resetPassword;
    });
  }

  void _handleLogout() {
    setState(() {
      _isLoggedIn = false;
      _currentScreen = PatientScreen.login;
      _pendingUsername = '';
      _pendingPassword = '';
    });
  }

  void _handleNavigate(PatientScreen screen) {
    setState(() {
      _currentScreen = screen;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 448),
        margin: const EdgeInsets.all(16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            constraints: const BoxConstraints(
              minHeight: 667,
              maxHeight: 844,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: !_isLoggedIn
                ? (_currentScreen == PatientScreen.resetPassword
                    ? ResetPasswordScreen(
                        username: _pendingUsername,
                        currentPassword: _pendingPassword,
                        onSuccess: _handleLogin,
                      )
                    : PatientLoginScreen(
                        onLogin: _handleLogin,
                        onResetPassword: _handleResetPassword,
                      ))
                : _buildCurrentScreen(),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentScreen() {
    switch (_currentScreen) {
      case PatientScreen.dashboard:
        return PatientDashboardScreen(onNavigate: _handleNavigate);
      case PatientScreen.history:
        return MedicalHistoryScreen(onNavigate: _handleNavigate);
      case PatientScreen.upload:
        return UploadPrescriptionScreen(onNavigate: _handleNavigate);
      case PatientScreen.profile:
        return PatientProfileScreen(
          onNavigate: _handleNavigate,
          onLogout: _handleLogout,
        );
      default:
        return PatientDashboardScreen(onNavigate: _handleNavigate);
    }
  }
}
