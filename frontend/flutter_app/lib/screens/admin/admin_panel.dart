import 'package:flutter/material.dart';
import 'admin_login_screen.dart';
import 'user_management_screen.dart';
import 'hospital_management_screen.dart';
import 'system_logs_screen.dart';

enum AdminScreen { login, users, hospitals, logs }

class AdminPanel extends StatefulWidget {
  const AdminPanel({super.key});

  @override
  State<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  AdminScreen _currentScreen = AdminScreen.login;
  bool _isLoggedIn = false;

  void _handleLogin() {
    setState(() {
      _isLoggedIn = true;
      _currentScreen = AdminScreen.users;
    });
  }

  void _handleLogout() {
    setState(() {
      _isLoggedIn = false;
      _currentScreen = AdminScreen.login;
    });
  }

  void _handleNavigate(AdminScreen screen) {
    setState(() {
      _currentScreen = screen;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoggedIn) {
      return AdminLoginScreen(onLogin: _handleLogin);
    }

    switch (_currentScreen) {
      case AdminScreen.users:
        return UserManagementScreen(
          onNavigate: _handleNavigate,
          onLogout: _handleLogout,
        );
      case AdminScreen.hospitals:
        return HospitalManagementScreen(
          onNavigate: _handleNavigate,
          onLogout: _handleLogout,
        );
      case AdminScreen.logs:
        return SystemLogsScreen(
          onNavigate: _handleNavigate,
          onLogout: _handleLogout,
        );
      default:
        return UserManagementScreen(
          onNavigate: _handleNavigate,
          onLogout: _handleLogout,
        );
    }
  }
}
