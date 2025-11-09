import '../models/patient_model.dart';
import '../models/record_model.dart';

class PatientService {
  // Mock data
  List<Patient> getMockPatients() {
    return [
      Patient(
        id: '1',
        name: 'Sarah Johnson',
        email: 'sarah.j@email.com',
        medicalId: 'MED-784932',
        phone: '+1 (555) 123-4567',
        dateOfBirth: '15 Mar 1990',
        bloodGroup: 'A+',
        address: '123 Main St, New York, NY',
        status: 'Active',
        lastVisit: 'Oct 28, 2025',
      ),
      Patient(
        id: '2',
        name: 'Michael Brown',
        email: 'michael.b@email.com',
        medicalId: 'MED-892341',
        phone: '+1 (555) 234-5678',
        dateOfBirth: '22 Jul 1985',
        bloodGroup: 'B+',
        status: 'Active',
        lastVisit: 'Oct 27, 2025',
      ),
      Patient(
        id: '3',
        name: 'Emily Davis',
        email: 'emily.d@email.com',
        medicalId: 'MED-453621',
        phone: '+1 (555) 345-6789',
        dateOfBirth: '10 Dec 1992',
        bloodGroup: 'O+',
        status: 'Active',
        lastVisit: 'Oct 26, 2025',
      ),
      Patient(
        id: '4',
        name: 'Robert Wilson',
        email: 'robert.w@email.com',
        medicalId: 'MED-678234',
        phone: '+1 (555) 456-7890',
        dateOfBirth: '05 May 1988',
        bloodGroup: 'AB+',
        status: 'Discharged',
        lastVisit: 'Oct 25, 2025',
      ),
    ];
  }

  List<MedicalRecord> getMockRecords() {
    return [
      MedicalRecord(
        id: 1,
        date: 'Oct 28, 2025',
        type: 'Consultation',
        title: 'Annual Physical Checkup',
        doctor: 'Dr. Michael Chen',
        department: 'Cardiology',
        diagnosis: 'Routine checkup - All vitals normal',
        files: 2,
      ),
      MedicalRecord(
        id: 2,
        date: 'Oct 25, 2025',
        type: 'Lab Report',
        title: 'Blood Test - Complete Panel',
        doctor: 'Lab Technician',
        department: 'Laboratory',
        diagnosis: 'All results within normal range',
        files: 1,
      ),
      MedicalRecord(
        id: 3,
        date: 'Sep 15, 2025',
        type: 'Prescription',
        title: 'Seasonal Allergies Treatment',
        doctor: 'Dr. Sarah Williams',
        department: 'General Medicine',
        diagnosis: 'Allergic rhinitis - Prescribed antihistamines',
        files: 1,
      ),
      MedicalRecord(
        id: 4,
        date: 'Aug 10, 2025',
        type: 'Imaging',
        title: 'Chest X-Ray',
        doctor: 'Dr. James Anderson',
        department: 'Radiology',
        diagnosis: 'Clear - No abnormalities detected',
        files: 3,
      ),
    ];
  }

  Future<List<Patient>> searchPatients(String query) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final patients = getMockPatients();
    
    if (query.isEmpty) {
      return patients;
    }

    return patients.where((patient) {
      return patient.name.toLowerCase().contains(query.toLowerCase()) ||
          patient.medicalId.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  Future<Patient?> getPatientById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final patients = getMockPatients();
    
    try {
      return patients.firstWhere((patient) => patient.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<List<MedicalRecord>> getPatientRecords(String patientId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // In a real app, this would filter by patientId
    return getMockRecords();
  }
}

// Singleton instance
final patientService = PatientService();
