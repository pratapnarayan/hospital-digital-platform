class MedicalRecord {
  final int id;
  final String date;
  final String type;
  final String title;
  final String doctor;
  final String department;
  final String diagnosis;
  final int files;

  MedicalRecord({
    required this.id,
    required this.date,
    required this.type,
    required this.title,
    required this.doctor,
    required this.department,
    required this.diagnosis,
    required this.files,
  });

  factory MedicalRecord.fromJson(Map<String, dynamic> json) {
    return MedicalRecord(
      id: json['id'] as int,
      date: json['date'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      doctor: json['doctor'] as String,
      department: json['department'] as String,
      diagnosis: json['diagnosis'] as String,
      files: json['files'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'type': type,
      'title': title,
      'doctor': doctor,
      'department': department,
      'diagnosis': diagnosis,
      'files': files,
    };
  }
}

class Diagnosis {
  final String id;
  final String patientId;
  final String patientName;
  final String date;
  final String condition;
  final String symptoms;
  final String treatment;
  final String notes;
  final List<String> medications;

  Diagnosis({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.date,
    required this.condition,
    required this.symptoms,
    required this.treatment,
    required this.notes,
    required this.medications,
  });

  factory Diagnosis.fromJson(Map<String, dynamic> json) {
    return Diagnosis(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      patientName: json['patientName'] as String,
      date: json['date'] as String,
      condition: json['condition'] as String,
      symptoms: json['symptoms'] as String,
      treatment: json['treatment'] as String,
      notes: json['notes'] as String,
      medications: List<String>.from(json['medications'] as List),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'patientName': patientName,
      'date': date,
      'condition': condition,
      'symptoms': symptoms,
      'treatment': treatment,
      'notes': notes,
      'medications': medications,
    };
  }
}
