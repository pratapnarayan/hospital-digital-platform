import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import '../../models/doctor_appointment_model.dart';
import '../../services/doctor_appointment_service.dart';
import 'doctor_portal.dart'; // import for DoctorScreen

class DoctorAppointmentsScreen extends StatefulWidget {
  final Function(DoctorScreen)? onNavigate;
  final VoidCallback? onLogout;

  const DoctorAppointmentsScreen({super.key, this.onNavigate, this.onLogout});

  @override
  State<DoctorAppointmentsScreen> createState() => _DoctorAppointmentsScreenState();
}

class _DoctorAppointmentsScreenState extends State<DoctorAppointmentsScreen> {
  DateTime _selectedDate = DateTime.now();
  List<DoctorAppointment> _appointments = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchAppointments();
  }

  Future<void> _fetchAppointments() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await doctorAppointmentService.getDoctorAppointments(date: _selectedDate);
      
      // Sort appointments by time
      data.sort((a, b) => a.appointmentTime.compareTo(b.appointmentTime));

      if (mounted) {
        setState(() {
          _appointments = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleAction(String appointmentId, String newStatus) async {
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
        _fetchAppointments(); // Refresh the list
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF1976D2)),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _fetchAppointments();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Appointments'),
        backgroundColor: const Color(0xFF1976D2),
        elevation: 0,
      ),
      body: Column(
        children: [
          // WEEKLY CALENDAR WIDGET
          Container(
            color: Colors.white,
            padding: const EdgeInsets.only(top: 16, bottom: 12),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            DateFormat('MMMM yyyy').format(_selectedDate),
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                          ),
                          const SizedBox(width: 16),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                InkWell(
                                  onTap: () {
                                    setState(() => _selectedDate = _selectedDate.subtract(const Duration(days: 7)));
                                    _fetchAppointments();
                                  },
                                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(8)),
                                  child: const Padding(
                                    padding: EdgeInsets.all(6.0),
                                    child: Icon(Icons.chevron_left, size: 20, color: Colors.black87),
                                  ),
                                ),
                                Container(width: 1, height: 20, color: Colors.grey[300]),
                                InkWell(
                                  onTap: () {
                                    setState(() => _selectedDate = _selectedDate.add(const Duration(days: 7)));
                                    _fetchAppointments();
                                  },
                                  borderRadius: const BorderRadius.horizontal(right: Radius.circular(8)),
                                  child: const Padding(
                                    padding: EdgeInsets.all(6.0),
                                    child: Icon(Icons.chevron_right, size: 20, color: Colors.black87),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.calendar_month, color: Color(0xFF1976D2)),
                        onPressed: _pickDate,
                        tooltip: 'Select Custom Date',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                WeeklyDateSelector(
                  selectedDate: _selectedDate,
                  onDateSelected: (date) {
                    setState(() {
                      _selectedDate = date;
                    });
                    _fetchAppointments();
                  },
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // LIST CONTENT
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF1976D2)))
                : _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, size: 48, color: Colors.red),
                            const SizedBox(height: 16),
                            Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _fetchAppointments,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : _appointments.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.event_available, size: 64, color: Colors.grey[300]),
                                const SizedBox(height: 16),
                                const Text(
                                  'No appointments for this day',
                                  style: TextStyle(fontSize: 16, color: Colors.black54),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _fetchAppointments,
                            child: ListView.builder(
                              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                              padding: const EdgeInsets.all(16),
                              itemCount: _appointments.length,
                              itemBuilder: (context, index) {
                                return DoctorAppointmentCard(
                                  appointment: _appointments[index],
                                  onAction: _handleAction,
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
      bottomNavigationBar: widget.onNavigate != null
          ? BottomNavigationBar(
              currentIndex: 2, // 2 for Appointments
              onTap: (index) {
                if (index == 0) widget.onNavigate!(DoctorScreen.dashboard);
                if (index == 1) widget.onNavigate!(DoctorScreen.patients);
              },
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
                BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Patients'),
                BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Appointments'),
              ],
            )
          : null,
    );
  }
}

// ----------------------------------------------------------------------
// WEEKLY DATE SELECTOR
// ----------------------------------------------------------------------

class WeeklyDateSelector extends StatefulWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;

  const WeeklyDateSelector({super.key, required this.selectedDate, required this.onDateSelected});

  @override
  State<WeeklyDateSelector> createState() => _WeeklyDateSelectorState();
}

class _WeeklyDateSelectorState extends State<WeeklyDateSelector> {
  late PageController _pageController;
  late DateTime _baseWeekStart;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  @override
  void didUpdateWidget(covariant WeeklyDateSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Sync external selectedDate changes with the controller if necessary
    if (oldWidget.selectedDate != widget.selectedDate) {
      final selectedWeekStart = widget.selectedDate.subtract(Duration(days: widget.selectedDate.weekday - 1));
      final pageIndex = 1000 + selectedWeekStart.difference(_baseWeekStart).inDays ~/ 7;
      if (_pageController.hasClients && _pageController.page?.round() != pageIndex) {
        _pageController.animateToPage(
          pageIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  void _initController() {
    final now = DateTime.now();
    _baseWeekStart = now.subtract(Duration(days: now.weekday - 1)); // Normalize to Monday
    
    final selectedWeekStart = widget.selectedDate.subtract(Duration(days: widget.selectedDate.weekday - 1));
    final initialPage = 1000 + selectedWeekStart.difference(_baseWeekStart).inDays ~/ 7;
    _pageController = PageController(initialPage: initialPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 75,
      child: PageView.builder(
        controller: _pageController,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          final weekOffset = index - 1000;
          final weekStart = _baseWeekStart.add(Duration(days: weekOffset * 7));
          
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(7, (dayIndex) {
              final date = weekStart.add(Duration(days: dayIndex));
              final isSelected = date.year == widget.selectedDate.year && 
                                 date.month == widget.selectedDate.month && 
                                 date.day == widget.selectedDate.day;
              final isToday = date.year == DateTime.now().year && 
                              date.month == DateTime.now().month && 
                              date.day == DateTime.now().day;
                
              return GestureDetector(
                onTap: () => widget.onDateSelected(date),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  width: 46,
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF1976D2) : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    border: isToday && !isSelected ? Border.all(color: const Color(0xFF1976D2).withOpacity(0.5), width: 2) : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat('E').format(date),
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected ? Colors.white : (isToday ? const Color(0xFF1976D2) : Colors.black54),
                          fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${date.day}',
                        style: TextStyle(
                          fontSize: 16,
                          color: isSelected ? Colors.white : (isToday ? const Color(0xFF1976D2) : Colors.black87),
                          fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}

// ----------------------------------------------------------------------
// APPOINTMENT CARD UI
// ----------------------------------------------------------------------

class DoctorAppointmentCard extends StatefulWidget {
  final DoctorAppointment appointment;
  final Function(String, String) onAction;

  const DoctorAppointmentCard({
    super.key,
    required this.appointment,
    required this.onAction,
  });

  @override
  State<DoctorAppointmentCard> createState() => _DoctorAppointmentCardState();
}

class _DoctorAppointmentCardState extends State<DoctorAppointmentCard> {
  bool _isProcessing = false;

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'SCHEDULED':
        return Colors.blue;
      case 'COMPLETED':
        return Colors.green;
      case 'CANCELLED':
        return Colors.red;
      case 'NO_SHOW':
        return Colors.grey;
      default:
        return Colors.black54;
    }
  }

  void _handleActionWrapper(String status) async {
    setState(() => _isProcessing = true);
    await widget.onAction(widget.appointment.appointmentId, status);
    if (mounted) setState(() => _isProcessing = false);
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(widget.appointment.status);
    final timeStr = DateFormat('h:mm a').format(widget.appointment.appointmentTime);
    
    // Placeholder patient name mapped from ID
    final patientName = 'Patient ID: ${widget.appointment.patientId.substring(max(0, widget.appointment.patientId.length - 6))}';

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  timeStr,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor.withOpacity(0.5)),
                  ),
                  child: Text(
                    widget.appointment.status,
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: statusColor, letterSpacing: 0.5),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.blue[50], shape: BoxShape.circle),
                  child: const Icon(Icons.person, size: 16, color: Color(0xFF1976D2)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    patientName, 
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black87)
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.medical_information_outlined, size: 18, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.appointment.reason, 
                    style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.3)
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.schedule, size: 18, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  '${widget.appointment.durationMinutes} minutes', 
                  style: TextStyle(fontSize: 14, color: Colors.grey[700])
                ),
              ],
            ),
            
            // ACTION BUTTONS
            if (widget.appointment.status == 'SCHEDULED') ...[
              const Divider(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: _isProcessing ? null : () => _handleActionWrapper('CANCELLED'),
                      child: _isProcessing 
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('Cancel Request', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: _isProcessing ? null : () => _handleActionWrapper('COMPLETED'),
                      child: _isProcessing
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('Mark Complete', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
