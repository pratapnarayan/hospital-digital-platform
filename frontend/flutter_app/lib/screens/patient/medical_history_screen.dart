import 'package:flutter/material.dart';
import '../../models/record_model.dart';
import '../../services/patient_service.dart';
import '../../services/auth_service.dart';
import 'patient_app.dart';

class MedicalHistoryScreen extends StatefulWidget {
  final Function(PatientScreen) onNavigate;

  const MedicalHistoryScreen({
    super.key,
    required this.onNavigate,
  });

  @override
  State<MedicalHistoryScreen> createState() => _MedicalHistoryScreenState();
}

class _MedicalHistoryScreenState extends State<MedicalHistoryScreen> {
  late Future<List<MedicalRecord>> _recordsFuture;

  @override
  void initState() {
    super.initState();
    final patientId = authService.currentPatientId;
    if (patientId != null) {
      _recordsFuture = patientService.getPatientRecords(patientId);
    } else {
      _recordsFuture = Future.value([]);
    }
  }

  String _formatDate(String isoDate) {
    if (isoDate.isEmpty) return 'N/A';
    try {
      final date = DateTime.parse(isoDate);
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    } catch (_) {
      return isoDate.split('T').first;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (authService.currentPatientId == null) {
        return Center(
          child: ElevatedButton(
            onPressed: () => widget.onNavigate(PatientScreen.dashboard),
            child: const Text('Invalid Login State', style: TextStyle(color: Colors.red)),
          ),
        );
    }

    return Column(
      children: [
        // Header
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1976D2), Color(0xFF1565C0)],
            ),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => widget.onNavigate(PatientScreen.dashboard),
                  ),
                  const Text(
                    'My Medical Records',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),

        // Timeline
        Expanded(
          child: FutureBuilder<List<MedicalRecord>>(
            future: _recordsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(),
                ));
              }
              if (snapshot.hasError) {
                return const Center(child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Text('Error loading medical records.'),
                ));
              }

              final records = snapshot.data ?? [];
              if (records.isEmpty) {
                 return const Center(child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Text('You have no registered medical records.'),
                 ));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(24),
                itemCount: records.length,
                itemBuilder: (context, index) {
                  final record = records[index];
                  final isLast = index == records.length - 1;

                  return Stack(
                    children: [
                      if (!isLast)
                        Positioned(
                          left: 24,
                          top: 56,
                          bottom: 0,
                          child: Container(
                            width: 2,
                            color: Colors.grey[200],
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF1976D2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.description,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      record.title,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.calendar_today,
                                          size: 12,
                                          color: Colors.black54,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          _formatDate(record.createdAt),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[50],
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Diagnosis: ${record.diagnosis}',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              record.description,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ]),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            }
          ),
        ),
      ],
    );
  }
}
