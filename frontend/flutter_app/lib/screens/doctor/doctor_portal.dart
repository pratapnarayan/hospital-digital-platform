import 'package:flutter/material.dart';
import 'doctor_login_screen.dart';
import 'doctor_dashboard_screen.dart';
import 'patient_record_viewer_screen.dart';

enum DoctorScreen { login, dashboard, patientRecord, addDiagnosis, notifications }

class DoctorPortal extends StatefulWidget {
  const DoctorPortal({super.key});

  @override
  State<DoctorPortal> createState() => _DoctorPortalState();
}

class _DoctorPortalState extends State<DoctorPortal> {
  DoctorScreen _currentScreen = DoctorScreen.login;
  bool _isLoggedIn = false;
  String? _selectedPatientId;

  void _handleLogin() {
    setState(() {
      _isLoggedIn = true;
      _currentScreen = DoctorScreen.dashboard;
    });
  }

  void _handleLogout() {
    setState(() {
      _isLoggedIn = false;
      _currentScreen = DoctorScreen.login;
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

  @override
  Widget build(BuildContext context) {
    if (!_isLoggedIn) {
      return DoctorLoginScreen(onLogin: _handleLogin);
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
