class MedicalRecord {
  final String id;
  final String hospitalId;
  final String patientId;
  final String doctorId;
  final String title;
  final String description;
  final String diagnosis;
  final String createdAt;
  final String updatedAt;

  MedicalRecord({
    required this.id,
    required this.hospitalId,
    required this.patientId,
    required this.doctorId,
    required this.title,
    required this.description,
    required this.diagnosis,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MedicalRecord.fromJson(Map<String, dynamic> json) {
    return MedicalRecord(
      id: json['id'] as String,
      hospitalId: json['hospitalId'] as String,
      patientId: json['patientId'] as String,
      doctorId: json['doctorId'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      diagnosis: json['diagnosis'] as String? ?? 'Pending Diagnosis',
      createdAt: json['createdAt'] as String? ?? '',
      updatedAt: json['updatedAt'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hospitalId': hospitalId,
      'patientId': patientId,
      'doctorId': doctorId,
      'title': title,
      'description': description,
      'diagnosis': diagnosis,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
