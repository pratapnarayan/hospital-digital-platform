class Appointment {
  final String id;
  final String hospitalId;
  final String doctorId;
  final String patientId;
  final DateTime appointmentTime;
  final int durationMinutes;
  final DateTime? appointmentEndTime;
  final String status;
  final String reason;
  final String? notes;
  final DateTime createdAt;

  Appointment({
    required this.id,
    required this.hospitalId,
    required this.doctorId,
    required this.patientId,
    required this.appointmentTime,
    required this.durationMinutes,
    this.appointmentEndTime,
    required this.status,
    required this.reason,
    this.notes,
    required this.createdAt,
  });

  static DateTime? __parseDate(dynamic dateVal) {
    if (dateVal == null) return null;
    if (dateVal is String) return DateTime.tryParse(dateVal);
    if (dateVal is int) {
      return dateVal > 100000000000 
          ? DateTime.fromMillisecondsSinceEpoch(dateVal)
          : DateTime.fromMillisecondsSinceEpoch(dateVal * 1000);
    }
    if (dateVal is double) {
      return DateTime.fromMillisecondsSinceEpoch((dateVal * 1000).toInt());
    }
    return null;
  }

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id']?.toString() ?? '',
      hospitalId: json['hospitalId']?.toString() ?? '',
      doctorId: json['doctorId']?.toString() ?? '',
      patientId: json['patientId']?.toString() ?? '',
      appointmentTime: __parseDate(json['appointmentTime']) ?? DateTime.now(),
      durationMinutes: json['durationMinutes'] is int ? json['durationMinutes'] : 30,
      appointmentEndTime: __parseDate(json['appointmentEndTime']),
      status: json['status']?.toString() ?? 'SCHEDULED',
      reason: json['reason']?.toString() ?? '',
      notes: json['notes']?.toString(),
      createdAt: __parseDate(json['createdAt']) ?? DateTime.now(),
    );
  }
}
