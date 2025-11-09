import 'package:flutter/material.dart';
import '../screens/admin/admin_panel.dart';

class AdminSidebar extends StatelessWidget {
  final AdminScreen currentScreen;
  final Function(AdminScreen) onNavigate;
  final VoidCallback onLogout;

  const AdminSidebar({
    super.key,
    required this.currentScreen,
    required this.onNavigate,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 256,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1976D2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.shield,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Admin',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          'System Panel',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                _buildNavItem(
                  'Users',
                  Icons.people,
                  AdminScreen.users,
                ),
                const SizedBox(height: 8),
                _buildNavItem(
                  'Hospitals',
                  Icons.local_hospital,
                  AdminScreen.hospitals,
                ),
                const SizedBox(height: 8),
                _buildNavItem(
                  'System Logs',
                  Icons.description,
                  AdminScreen.logs,
                ),
              ],
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(24),
            child: OutlinedButton.icon(
              onPressed: onLogout,
              icon: const Icon(Icons.logout),
              label: const Text('Sign Out'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                alignment: Alignment.centerLeft,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(String label, IconData icon, AdminScreen screen) {
    final isActive = currentScreen == screen;

    return InkWell(
      onTap: () => onNavigate(screen),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF1976D2) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isActive ? Colors.white : Colors.black54,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: isActive ? Colors.white : Colors.black87,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
