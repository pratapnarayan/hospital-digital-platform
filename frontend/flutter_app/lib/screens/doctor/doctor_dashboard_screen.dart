import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import '../../widgets/summary_card.dart';
import '../../widgets/section_header.dart';
import '../../widgets/dashboard_appointment_card.dart';
import '../../models/doctor_appointment_model.dart';
import '../../models/patient_model.dart';
import '../../services/doctor_appointment_service.dart';
import '../../services/patient_service.dart';
import 'doctor_portal.dart';

class DoctorDashboardScreen extends StatefulWidget {
  final Function(DoctorScreen) onNavigate;
  final Function(String) onViewPatient;
  final VoidCallback onLogout;

  const DoctorDashboardScreen({
    super.key,
    required this.onNavigate,
    required this.onViewPatient,
    required this.onLogout,
  });

  @override
  State<DoctorDashboardScreen> createState() => _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends State<DoctorDashboardScreen> {
  bool _isLoading = true;
  
  // API Data State
  int _totalPatients = 0;
  int _todayAppointmentsCount = 0;
  int _completedCount = 0;
  int _pendingCount = 0;
  
  List<DoctorAppointment> _todayAppointments = [];
  List<DoctorAppointment> _upcomingAppointments = [];
  List<Patient> _recentPatients = [];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    
    try {
      final now = DateTime.now();
      final tomorrow = now.add(const Duration(days: 1));
      final dayAfterTomorrow = now.add(const Duration(days: 2));

      // Fetch all required data concurrently
      final responses = await Future.wait([
        patientService.getPatients(),
        doctorAppointmentService.getDoctorAppointments(date: now),
        doctorAppointmentService.getDoctorAppointments(date: tomorrow),
        doctorAppointmentService.getDoctorAppointments(date: dayAfterTomorrow),
      ]);

      final allPatients = responses[0] as List<Patient>;
      final todayAppts = responses[1] as List<DoctorAppointment>;
      final tomorrowAppts = responses[2] as List<DoctorAppointment>;
      final nextDayAppts = responses[3] as List<DoctorAppointment>;

      _totalPatients = allPatients.length;
      
      // Top 5 recently accessed (using first 5 as a proxy for this example)
      _recentPatients = allPatients.take(5).toList();

      todayAppts.sort((a, b) => a.appointmentTime.compareTo(b.appointmentTime));
      _todayAppointments = todayAppts;

      _todayAppointmentsCount = _todayAppointments.length;
      _completedCount = _todayAppointments.where((a) => a.status.toUpperCase() == 'COMPLETED').length;
      _pendingCount = _todayAppointments.where((a) => a.status.toUpperCase() == 'SCHEDULED' || a.status.toUpperCase() == 'IN_PROGRESS').length;

      final upcoming = [...tomorrowAppts, ...nextDayAppts];
      upcoming.sort((a, b) => a.appointmentTime.compareTo(b.appointmentTime));
      _upcomingAppointments = upcoming.take(5).toList();
      
    } catch (e) {
      debugPrint('Dashboard load error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load dashboard data: $e'), backgroundColor: Colors.red),
        );
      }
    }

    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _handleAppointmentAction(String appointmentId, String newStatus) async {
    try {
      await doctorAppointmentService.updateAppointmentStatus(
        appointmentId: appointmentId,
        status: newStatus,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Appointment marked as ${newStatus.toLowerCase()}'),
            backgroundColor: Colors.green,
          ),
        );
        _loadDashboardData(); // Refresh dashboard
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Doctor Dashboard'),
        backgroundColor: const Color(0xFF1976D2),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboardData,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: widget.onLogout,
          ),
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Color(0xFF1976D2)))
        : LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final isDesktop = width >= 1024;
              final isTablet = width >= 600 && width < 1024;
              final isMobile = width < 600;

              return RefreshIndicator(
                onRefresh: _loadDashboardData,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1400), // Max width for ultrawide screens
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.all(isMobile ? 16 : 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _HeaderSection(),
                          SizedBox(height: isMobile ? 16 : 24),
                          _SummaryCardsSection(
                            width: width,
                            todayCount: _todayAppointmentsCount,
                            completedCount: _completedCount,
                            pendingCount: _pendingCount,
                            totalPatients: _totalPatients,
                          ),
                          SizedBox(height: isMobile ? 24 : 32),
                          
                          // Dashboard Content Grid
                          if (isDesktop)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Left Column (Main content)
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    children: [
                                      _TodayScheduleSection(
                                        appointments: _todayAppointments,
                                        onNavigate: widget.onNavigate,
                                        onAction: _handleAppointmentAction,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 32),
                                // Right Column (Sidebar)
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    children: [
                                      _QuickActionsSection(onNavigate: widget.onNavigate),
                                      const SizedBox(height: 32),
                                      _PatientQuickAccessSection(
                                        recentPatients: _recentPatients,
                                        onNavigate: widget.onNavigate,
                                        onViewPatient: widget.onViewPatient,
                                      ),
                                      const SizedBox(height: 32),
                                      _UpcomingAppointmentsSection(
                                        appointments: _upcomingAppointments,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          else
                            // Mobile/Tablet Layout
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _QuickActionsSection(onNavigate: widget.onNavigate),
                                SizedBox(height: isMobile ? 24 : 32),
                                _TodayScheduleSection(
                                  appointments: _todayAppointments,
                                  onNavigate: widget.onNavigate,
                                  onAction: _handleAppointmentAction,
                                ),
                                SizedBox(height: isMobile ? 24 : 32),
                                if (isTablet)
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: _PatientQuickAccessSection(
                                          recentPatients: _recentPatients,
                                          onNavigate: widget.onNavigate,
                                          onViewPatient: widget.onViewPatient,
                                        ),
                                      ),
                                      const SizedBox(width: 24),
                                      Expanded(
                                        child: _UpcomingAppointmentsSection(
                                          appointments: _upcomingAppointments,
                                        ),
                                      ),
                                    ],
                                  )
                                else ...[
                                  _PatientQuickAccessSection(
                                    recentPatients: _recentPatients,
                                    onNavigate: widget.onNavigate,
                                    onViewPatient: widget.onViewPatient,
                                  ),
                                  const SizedBox(height: 24),
                                  _UpcomingAppointmentsSection(
                                    appointments: _upcomingAppointments,
                                  ),
                                ],
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0, // 0 for Dashboard
        onTap: (index) {
          if (index == 1) widget.onNavigate(DoctorScreen.patients);
          if (index == 2) widget.onNavigate(DoctorScreen.appointments);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Patients'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Appointments'),
        ],
      ),
    );
  }
}

// --- Extracted Stateless Widgets for Performance Optimization ---

class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Welcome back, Doctor',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Here is your schedule for today.',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

class _SummaryCardsSection extends StatelessWidget {
  final double width;
  final int todayCount;
  final int completedCount;
  final int pendingCount;
  final int totalPatients;

  const _SummaryCardsSection({
    required this.width,
    required this.todayCount,
    required this.completedCount,
    required this.pendingCount,
    required this.totalPatients,
  });

  @override
  Widget build(BuildContext context) {
    if (width >= 1024) {
      // Desktop: 4 cards in a row
      return Row(
        children: [
          Expanded(child: SummaryCard(title: 'Appointments Today', value: '$todayCount', icon: Icons.calendar_today, color: Colors.blue)),
          const SizedBox(width: 16),
          Expanded(child: SummaryCard(title: 'Completed', value: '$completedCount', icon: Icons.check_circle, color: Colors.green)),
          const SizedBox(width: 16),
          Expanded(child: SummaryCard(title: 'Pending', value: '$pendingCount', icon: Icons.pending_actions, color: Colors.orange)),
          const SizedBox(width: 16),
          Expanded(child: SummaryCard(title: 'Total Patients', value: '$totalPatients', icon: Icons.people, color: Colors.purple)),
        ],
      );
    } else if (width >= 600) {
      // Tablet / Large Mobile: 2x2 grid
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: SummaryCard(title: 'Appointments Today', value: '$todayCount', icon: Icons.calendar_today, color: Colors.blue)),
              const SizedBox(width: 16),
              Expanded(child: SummaryCard(title: 'Completed', value: '$completedCount', icon: Icons.check_circle, color: Colors.green)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: SummaryCard(title: 'Pending', value: '$pendingCount', icon: Icons.pending_actions, color: Colors.orange)),
              const SizedBox(width: 16),
              Expanded(child: SummaryCard(title: 'Total Patients', value: '$totalPatients', icon: Icons.people, color: Colors.purple)),
            ],
          ),
        ],
      );
    } else {
      // Small Mobile: 1 card per row stacked vertically
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SummaryCard(title: 'Appointments Today', value: '$todayCount', icon: Icons.calendar_today, color: Colors.blue),
          const SizedBox(height: 12),
          SummaryCard(title: 'Completed', value: '$completedCount', icon: Icons.check_circle, color: Colors.green),
          const SizedBox(height: 12),
          SummaryCard(title: 'Pending', value: '$pendingCount', icon: Icons.pending_actions, color: Colors.orange),
          const SizedBox(height: 12),
          SummaryCard(title: 'Total Patients', value: '$totalPatients', icon: Icons.people, color: Colors.purple),
        ],
      );
    }
  }
}

class _QuickActionsSection extends StatelessWidget {
  final Function(DoctorScreen) onNavigate;

  const _QuickActionsSection({required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Quick Actions'),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => onNavigate(DoctorScreen.createPatient),
                icon: const Icon(Icons.person_add),
                label: const Text('Add Patient'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1976D2),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => onNavigate(DoctorScreen.appointments),
                icon: const Icon(Icons.add_task),
                label: const Text('Book Appt.'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF1976D2),
                  side: const BorderSide(color: Color(0xFF1976D2), width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TodayScheduleSection extends StatelessWidget {
  final List<DoctorAppointment> appointments;
  final Function(DoctorScreen) onNavigate;
  final Function(String, String) onAction;

  const _TodayScheduleSection({
    required this.appointments,
    required this.onNavigate,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Today\'s Schedule',
          actionText: 'View All',
          onAction: () => onNavigate(DoctorScreen.appointments),
        ),
        if (appointments.isEmpty)
          const Card(
             child: Padding(
               padding: EdgeInsets.all(32.0),
               child: Center(child: Text('No appointments scheduled for today.')),
             ),
          )
        else
          ...appointments.map((appt) {
            final patientName = 'Patient ID: ${appt.patientId.substring(max(0, appt.patientId.length - 6))}';
            return DashboardAppointmentCard(
              appointmentId: appt.appointmentId,
              time: DateFormat('h:mm a').format(appt.appointmentTime),
              patientName: patientName,
              reason: appt.reason,
              duration: '${appt.durationMinutes} mins',
              status: appt.status,
              onAction: onAction,
            );
          }),
      ],
    );
  }
}

class _UpcomingAppointmentsSection extends StatelessWidget {
  final List<DoctorAppointment> appointments;

  const _UpcomingAppointmentsSection({required this.appointments});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Upcoming Appointments'),
        if (appointments.isEmpty)
           const Text('No upcoming appointments.', style: TextStyle(color: Colors.black54))
        else
           ...appointments.map((appt) {
            final patientName = 'Patient ID: ${appt.patientId.substring(max(0, appt.patientId.length - 6))}';
            return DashboardAppointmentCard(
              appointmentId: appt.appointmentId,
              time: DateFormat('E, h:mm a').format(appt.appointmentTime),
              patientName: patientName,
              reason: appt.reason,
              duration: '${appt.durationMinutes} mins',
              status: appt.status,
              compact: true,
            );
          }),
      ],
    );
  }
}

class _PatientQuickAccessSection extends StatelessWidget {
  final List<Patient> recentPatients;
  final Function(DoctorScreen) onNavigate;
  final Function(String) onViewPatient;

  const _PatientQuickAccessSection({
    required this.recentPatients,
    required this.onNavigate,
    required this.onViewPatient,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Patient Quick Access',
          actionText: 'See All',
          onAction: () => onNavigate(DoctorScreen.patients),
        ),
        // Search Bar
        TextField(
          decoration: InputDecoration(
            hintText: 'Search patient name or ID...',
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Recent Patients List
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey[200]!),
          ),
          child: recentPatients.isEmpty
            ? const Padding(padding: EdgeInsets.all(16), child: Text('No registered patients found.'))
            : ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recentPatients.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final patient = recentPatients[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFF1976D2).withOpacity(0.1),
                    child: Text(
                      patient.initials,
                      style: const TextStyle(color: Color(0xFF1976D2), fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(patient.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text('ID: ${patient.id} • ${patient.gender}'),
                  trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.black54),
                  onTap: () => onViewPatient(patient.id),
                );
              },
            ),
        ),
      ],
    );
  }
}
