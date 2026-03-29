import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/environment.dart';
import 'doctor_login_screen.dart';
import 'doctor_register_screen.dart';
import 'doctor_dashboard_screen.dart';
import 'patient_record_viewer_screen.dart';

enum DoctorScreen { login, register, dashboard, patientRecord, addDiagnosis, notifications }

class DoctorPortal extends StatefulWidget {
  const DoctorPortal({super.key});

  @override
  State<DoctorPortal> createState() => _DoctorPortalState();
}

class _DoctorPortalState extends State<DoctorPortal> {
  DoctorScreen _currentScreen = DoctorScreen.login;
  bool _isLoggedIn = false;
  String? _selectedPatientId;
  String? _errorMessage; // shown when a non-DOCTOR user tries to log in here

  void _handleLogin() {
    // In real mode: verify the role from the decoded JWT
    if (!useMockData) {
      final role = authService.currentUserRole;
      if (role != null && role.toUpperCase() != 'DOCTOR') {
        // Wrong role — reject and show an error
        setState(() {
          _errorMessage =
              'This portal is for doctors only. Your account role is "$role".';
        });
        return;
      }
    }

    setState(() {
      _isLoggedIn = true;
      _errorMessage = null;
      _currentScreen = DoctorScreen.dashboard;
    });
  }

  void _handleLogout() {
    authService.logout();
    setState(() {
      _isLoggedIn = false;
      _currentScreen = DoctorScreen.login;
      _errorMessage = null;
    });
  }

  void _handleNavigate(DoctorScreen screen) {
    setState(() {
      _currentScreen = screen;
    });
  }

  void _handleViewPatient(String patientId) {
    setState(() {
      _selectedPatientId = patientId;
      _currentScreen = DoctorScreen.patientRecord;
    });
  }

  void _handleGoToRegister() {
    setState(() {
      _currentScreen = DoctorScreen.register;
      _errorMessage = null;
    });
  }

  void _handleBackToLogin() {
    setState(() {
      _currentScreen = DoctorScreen.login;
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoggedIn) {
      // Show error banner above the login screen if there was a role mismatch
      final loginScreen = DoctorLoginScreen(
        onLogin: _handleLogin,
        onRegister: _handleGoToRegister,
      );

      if (_currentScreen == DoctorScreen.register) {
        return DoctorRegisterScreen(
          onRegistered: _handleBackToLogin,
          onBackToLogin: _handleBackToLogin,
        );
      }

      if (_errorMessage != null) {
        return Column(
          children: [
            Material(
              color: Colors.red[700],
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded,
                          color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 13),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close,
                            color: Colors.white, size: 18),
                        onPressed: () =>
                            setState(() => _errorMessage = null),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(child: loginScreen),
          ],
        );
      }

      return loginScreen;
    }

    switch (_currentScreen) {
      case DoctorScreen.dashboard:
        return DoctorDashboardScreen(
          onNavigate: _handleNavigate,
          onViewPatient: _handleViewPatient,
          onLogout: _handleLogout,
        );
      case DoctorScreen.patientRecord:
        return PatientRecordViewerScreen(
          patientId: _selectedPatientId,
          onNavigate: _handleNavigate,
        );
      default:
        return DoctorDashboardScreen(
          onNavigate: _handleNavigate,
          onViewPatient: _handleViewPatient,
          onLogout: _handleLogout,
        );
    }
  }
}
