import 'package:flutter/material.dart';
import '../../models/appointment_model.dart';
import '../../services/appointment_service.dart';
import 'package:intl/intl.dart';
import 'book_appointment_screen.dart';

class AppointmentListScreen extends StatefulWidget {
  const AppointmentListScreen({super.key});

  @override
  State<AppointmentListScreen> createState() => _AppointmentListScreenState();
}

class _AppointmentListScreenState extends State<AppointmentListScreen> {
  late Future<List<Appointment>> _appointmentsFuture;

  @override
  void initState() {
    super.initState();
    _fetchAppointments();
  }

  void _fetchAppointments() {
    setState(() {
      _appointmentsFuture = appointmentService.getPatientAppointments(page: 0, size: 50); // Fetching up to 50 for simplicity in mobile scope
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 448),
          margin: const EdgeInsets.symmetric(vertical: 16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              constraints: const BoxConstraints(
                minHeight: 667,
                maxHeight: 844,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Scaffold(
                appBar: AppBar(
                  title: const Text('My Appointments'),
                  backgroundColor: const Color(0xFF1976D2),
                  elevation: 0,
                ),
                body: FutureBuilder<List<Appointment>>(
                  future: _appointmentsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, size: 48, color: Colors.red),
                            const SizedBox(height: 16),
                            const Text('Failed to load appointments.'),
                            TextButton(
                              onPressed: _fetchAppointments,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      );
                    }

                    final appointments = snapshot.data ?? [];
                    
                    if (appointments.isEmpty) {
                      return const Center(
                        child: Text(
                          'You have no appointments booked.',
                          style: TextStyle(fontSize: 16, color: Colors.black54),
                        ),
                      );
                    }

                    final now = DateTime.now();
                    final upcomingAppointments = appointments.where((a) => a.appointmentTime.isAfter(now) && a.status != 'CANCELLED').toList();
                    final pastAppointments = appointments.where((a) => a.appointmentTime.isBefore(now) || a.status == 'CANCELLED').toList();

                    return ListView(
                      padding: const EdgeInsets.all(16.0),
                      children: [
                        if (upcomingAppointments.isNotEmpty) ...[
                          const Text(
                            'Upcoming Appointments',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          ...upcomingAppointments.map((idx) => _buildAppointmentCard(idx, isActive: true)),
                          const SizedBox(height: 24),
                        ],
                        
                        if (pastAppointments.isNotEmpty) ...[
                          const Text(
                            'Past Appointments',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          ...pastAppointments.map((idx) => _buildAppointmentCard(idx, isActive: false)),
                        ],
                      ],
                    );
                  },
                ),
                floatingActionButton: FloatingActionButton.extended(
                  backgroundColor: const Color(0xFF1976D2),
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const BookAppointmentScreen()),
                    );
                    if (result == true) {
                      _fetchAppointments();
                    }
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Book Appointment'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppointmentCard(Appointment appointment, {required bool isActive}) {
    final dateFormatter = DateFormat('MMM d, yyyy • h:mm a');
    final formattedDate = dateFormatter.format(appointment.appointmentTime);
    
    Color statusColor;
    switch (appointment.status.toUpperCase()) {
      case 'SCHEDULED': statusColor = Colors.blue; break;
      case 'COMPLETED': statusColor = Colors.green; break;
      case 'CANCELLED': statusColor = Colors.red; break;
      case 'NO_SHOW': statusColor = Colors.orange; break;
      default: statusColor = Colors.grey;
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    formattedDate,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isActive ? Colors.black87 : Colors.black54,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: statusColor.withOpacity(0.5)),
                  ),
                  child: Text(
                    appointment.status,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  '${appointment.durationMinutes} minutes',
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    appointment.reason,
                    style: TextStyle(color: Colors.grey[800]),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
