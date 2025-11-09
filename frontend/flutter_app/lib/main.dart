import 'package:flutter/material.dart';
import 'screens/patient/patient_app.dart';
import 'screens/doctor/doctor_portal.dart';
import 'screens/admin/admin_panel.dart';

void main() {
  runApp(const HospitalDigitalRecordsApp());
}

class HospitalDigitalRecordsApp extends StatelessWidget {
  const HospitalDigitalRecordsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hospital Digital Records',
      theme: ThemeData(
        primaryColor: const Color(0xFF1976D2),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1976D2),
          primary: const Color(0xFF1976D2),
          secondary: const Color(0xFF1565C0),
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      debugShowCheckedModeBanner: false,
      home: const DemoModeSwitcher(),
    );
  }
}

class DemoModeSwitcher extends StatefulWidget {
  const DemoModeSwitcher({super.key});

  @override
  State<DemoModeSwitcher> createState() => _DemoModeSwitcherState();
}

class _DemoModeSwitcherState extends State<DemoModeSwitcher> {
  int _currentIndex = 0;

  final List<Widget> _views = [
    const PatientApp(),
    const DoctorPortal(),
    const AdminPanel(),
  ];

  final List<String> _viewTitles = [
    'Patient App',
    'Doctor Portal',
    'Admin Panel',
  ];

  final List<IconData> _viewIcons = [
    Icons.smartphone,
    Icons.medical_services,
    Icons.shield,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // Demo Switcher Header
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Colors.grey[200]!),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Hospital Digital Records System',
                          style: TextStyle(
                            fontSize: 20,
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
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Demo Mode',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Tab Selector
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: List.generate(3, (index) {
                          final isSelected = _currentIndex == index;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _currentIndex = index;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.05),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      _viewIcons[index],
                                      size: 16,
                                      color: isSelected
                                          ? const Color(0xFF1976D2)
                                          : Colors.black54,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _viewTitles[index],
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                        color: isSelected
                                            ? const Color(0xFF1976D2)
                                            : Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Active View
          Expanded(
            child: _views[_currentIndex],
          ),
        ],
      ),
    );
  }
}
