import 'package:flutter/material.dart';
import '../../services/patient_service.dart';
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
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    final records = patientService.getMockRecords();

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
                    'Medical History',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                  ),
                ),
                child: DropdownButton<String>(
                  value: _filter,
                  isExpanded: true,
                  dropdownColor: const Color(0xFF1976D2),
                  style: const TextStyle(color: Colors.white),
                  underline: const SizedBox(),
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('All Records')),
                    DropdownMenuItem(value: 'consultation', child: Text('Consultations')),
                    DropdownMenuItem(value: 'lab', child: Text('Lab Reports')),
                    DropdownMenuItem(value: 'prescription', child: Text('Prescriptions')),
                    DropdownMenuItem(value: 'imaging', child: Text('Imaging')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _filter = value!;
                    });
                  },
                ),
              ),
            ],
          ),
        ),

        // Timeline
        Expanded(
          child: ListView.builder(
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
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        record.type,
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      record.department,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.person,
                                      size: 12,
                                      color: Colors.black54,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      record.doctor,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.calendar_today,
                                      size: 12,
                                      color: Colors.black54,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      record.date,
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
                                  child: Text(
                                    record.diagnosis,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                OutlinedButton.icon(
                                  onPressed: () {},
                                  icon: const Icon(Icons.download, size: 16),
                                  label: Text('View Files (${record.files})'),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    textStyle: const TextStyle(fontSize: 12),
                                  ),
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
          ),
        ),
      ],
    );
  }
}
