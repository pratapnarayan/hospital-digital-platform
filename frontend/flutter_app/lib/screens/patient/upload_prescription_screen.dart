import 'package:flutter/material.dart';
import 'patient_app.dart';

class UploadPrescriptionScreen extends StatefulWidget {
  final Function(PatientScreen) onNavigate;

  const UploadPrescriptionScreen({
    super.key,
    required this.onNavigate,
  });

  @override
  State<UploadPrescriptionScreen> createState() =>
      _UploadPrescriptionScreenState();
}

class _UploadPrescriptionScreenState extends State<UploadPrescriptionScreen> {
  String? _uploadedFile;
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _handleUpload() {
    setState(() {
      _uploadedFile = 'prescription_scan_${DateTime.now().millisecondsSinceEpoch}.jpg';
    });
  }

  void _handleSubmit() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Prescription uploaded successfully!'),
        backgroundColor: Colors.green,
      ),
    );
    widget.onNavigate(PatientScreen.dashboard);
  }

  @override
  Widget build(BuildContext context) {
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
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => widget.onNavigate(PatientScreen.dashboard),
              ),
              const Text(
                'Upload Prescription',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),

        // Content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Upload Area
                GestureDetector(
                  onTap: _handleUpload,
                  child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey[300]!,
                        width: 2,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: _uploadedFile == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cloud_upload,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Tap to upload prescription',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Supports JPG, PNG, PDF',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[400],
                                ),
                              ),
                            ],
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.check_circle,
                                size: 48,
                                color: Colors.green,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _uploadedFile!,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _uploadedFile = null;
                                  });
                                },
                                child: const Text('Remove'),
                              ),
                            ],
                          ),
                  ),
                ),

                const SizedBox(height: 24),

                // Date Selector
                const Text(
                  'Prescription Date',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.calendar_today),
                  label: const Text('Nov 9, 2025'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    alignment: Alignment.centerLeft,
                  ),
                ),

                const SizedBox(height: 24),

                // Doctor Name
                const Text(
                  'Doctor Name',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Enter doctor name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                ),

                const SizedBox(height: 24),

                // Notes
                const Text(
                  'Notes (Optional)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _notesController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Add any additional notes...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                ),

                const SizedBox(height: 32),

                // Submit Button
                ElevatedButton(
                  onPressed: _uploadedFile != null ? _handleSubmit : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1976D2),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    disabledBackgroundColor: Colors.grey[300],
                  ),
                  child: const Text('Submit Prescription'),
                ),

                const SizedBox(height: 16),

                // Info Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.blue[700],
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Your prescription will be reviewed by our medical team within 24 hours.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black87,
                          ),
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
  }
}
