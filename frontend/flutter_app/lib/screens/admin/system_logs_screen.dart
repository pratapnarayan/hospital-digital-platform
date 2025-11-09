import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'admin_panel.dart';
import '../../widgets/admin_sidebar.dart';

class SystemLogsScreen extends StatefulWidget {
  final Function(AdminScreen) onNavigate;
  final VoidCallback onLogout;

  const SystemLogsScreen({
    super.key,
    required this.onNavigate,
    required this.onLogout,
  });

  @override
  State<SystemLogsScreen> createState() => _SystemLogsScreenState();
}

class _SystemLogsScreenState extends State<SystemLogsScreen> {
  final _searchController = TextEditingController();
  String _levelFilter = 'all';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final logs = apiService.getMockSystemLogs();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Row(
        children: [
          AdminSidebar(
            currentScreen: AdminScreen.logs,
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
                    'System Logs',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Monitor system activity and audit logs',
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
                                hintText: 'Search logs',
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
                              value: _levelFilter,
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
                                  child: Text('All Levels'),
                                ),
                                DropdownMenuItem(
                                  value: 'info',
                                  child: Text('Info'),
                                ),
                                DropdownMenuItem(
                                  value: 'warning',
                                  child: Text('Warning'),
                                ),
                                DropdownMenuItem(
                                  value: 'error',
                                  child: Text('Error'),
                                ),
                                DropdownMenuItem(
                                  value: 'success',
                                  child: Text('Success'),
                                ),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _levelFilter = value!;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.download, size: 20),
                            label: const Text('Export Logs'),
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

                  // Logs List
                  ...logs.map((log) {
                    return Card(
                      elevation: 0,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Colors.grey[300]!),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.only(top: 6),
                              decoration: BoxDecoration(
                                color: _getLevelColor(log.level),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        log.action,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _getLevelColor(log.level)
                                              .withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          log.level.toUpperCase(),
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: _getLevelColor(log.level),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    log.details,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.person,
                                        size: 16,
                                        color: Colors.black54,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        log.user,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.black54,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      const Icon(
                                        Icons.access_time,
                                        size: 16,
                                        color: Colors.black54,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        log.timestamp,
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
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getLevelColor(String level) {
    switch (level) {
      case 'info':
        return const Color(0xFF1976D2);
      case 'warning':
        return Colors.orange;
      case 'error':
        return Colors.red;
      case 'success':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
