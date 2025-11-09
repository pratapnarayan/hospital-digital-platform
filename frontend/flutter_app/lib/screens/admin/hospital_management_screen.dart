import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'admin_panel.dart';
import '../../widgets/admin_sidebar.dart';

class HospitalManagementScreen extends StatefulWidget {
  final Function(AdminScreen) onNavigate;
  final VoidCallback onLogout;

  const HospitalManagementScreen({
    super.key,
    required this.onNavigate,
    required this.onLogout,
  });

  @override
  State<HospitalManagementScreen> createState() =>
      _HospitalManagementScreenState();
}

class _HospitalManagementScreenState extends State<HospitalManagementScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hospitals = apiService.getMockHospitals();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Row(
        children: [
          AdminSidebar(
            currentScreen: AdminScreen.hospitals,
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
                    'Hospital Management',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Manage registered hospitals and medical facilities',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Search and Add
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
                                hintText: 'Search hospitals',
                                border: InputBorder.none,
                                prefixIcon: Icon(Icons.search),
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.add, size: 20),
                            label: const Text('Add Hospital'),
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

                  // Hospitals Table
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
                          DataColumn(label: Text('Hospital')),
                          DataColumn(label: Text('Location')),
                          DataColumn(label: Text('Type')),
                          DataColumn(label: Text('Patients')),
                          DataColumn(label: Text('Doctors')),
                          DataColumn(label: Text('Status')),
                          DataColumn(label: Text('Actions')),
                        ],
                        rows: hospitals.map((hospital) {
                          return DataRow(
                            cells: [
                              DataCell(
                                Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF1976D2)
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.local_hospital,
                                        color: Color(0xFF1976D2),
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      hospital.name,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              DataCell(Text(hospital.location)),
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.blue[100],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    hospital.type,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.blue[900],
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(Text(hospital.patients.toString())),
                              DataCell(Text(hospital.doctors.toString())),
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: hospital.status == 'Active'
                                        ? Colors.green
                                        : Colors.grey,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    hospital.status,
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
}
