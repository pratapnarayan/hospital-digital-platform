import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'admin_panel.dart';
import '../../widgets/admin_sidebar.dart';

class UserManagementScreen extends StatefulWidget {
  final Function(AdminScreen) onNavigate;
  final VoidCallback onLogout;

  const UserManagementScreen({
    super.key,
    required this.onNavigate,
    required this.onLogout,
  });

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final _searchController = TextEditingController();
  String _roleFilter = 'all';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final users = apiService.getMockUsers();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Row(
        children: [
          AdminSidebar(
            currentScreen: AdminScreen.users,
            onNavigate: widget.onNavigate,
            onLogout: widget.onLogout,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'User Management',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Manage system users, roles, and permissions',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Filters
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.grey[300]!),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              decoration: const InputDecoration(
                                hintText: 'Search by name or email',
                                border: InputBorder.none,
                                prefixIcon: Icon(Icons.search),
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          SizedBox(
                            width: 200,
                            child: DropdownButtonFormField<String>(
                              value: _roleFilter,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 'all',
                                  child: Text('All Roles'),
                                ),
                                DropdownMenuItem(
                                  value: 'doctor',
                                  child: Text('Doctors'),
                                ),
                                DropdownMenuItem(
                                  value: 'patient',
                                  child: Text('Patients'),
                                ),
                                DropdownMenuItem(
                                  value: 'admin',
                                  child: Text('Admins'),
                                ),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _roleFilter = value!;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.add, size: 20),
                            label: const Text('Add User'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1976D2),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Users Table
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.grey[300]!),
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columnSpacing: 40,
                        columns: const [
                          DataColumn(label: Text('User')),
                          DataColumn(label: Text('Role')),
                          DataColumn(label: Text('Hospital')),
                          DataColumn(label: Text('Status')),
                          DataColumn(label: Text('Actions')),
                        ],
                        rows: users.map((user) {
                          return DataRow(
                            cells: [
                              DataCell(
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: Colors.grey[200],
                                      child: Text(
                                        user.initials,
                                        style: const TextStyle(
                                          color: Colors.black87,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          user.name,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Text(
                                          user.email,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getRoleColor(user.role),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    user.role,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(Text(user.hospital)),
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: user.status == 'Active'
                                        ? Colors.green
                                        : Colors.grey,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    user.status,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, size: 20),
                                      onPressed: () {},
                                      color: Colors.black54,
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, size: 20),
                                      onPressed: () {},
                                      color: Colors.red,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'Admin':
        return Colors.purple;
      case 'Doctor':
        return const Color(0xFF1976D2);
      case 'Patient':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}
