class DoctorAppointment {
  final String appointmentId;
  final String patientId;
  final DateTime appointmentTime;
  final int durationMinutes;
  final String status;
  final String reason;

  DoctorAppointment({
    required this.appointmentId,
    required this.patientId,
    required this.appointmentTime,
    required this.durationMinutes,
    required this.status,
    required this.reason,
  });

  factory DoctorAppointment.fromJson(Map<String, dynamic> json) {
    DateTime parsedTime = DateTime.now();
    if (json['appointmentTime'] != null) {
      final parsed = DateTime.tryParse(json['appointmentTime'].toString());
      if (parsed != null) {
        parsedTime = parsed.toLocal(); // Ensure localized time for display
      }
    }

    return DoctorAppointment(
      appointmentId: json['appointmentId']?.toString() ?? json['id']?.toString() ?? '',
      patientId: json['patientId']?.toString() ?? '',
      appointmentTime: parsedTime,
      durationMinutes: json['durationMinutes'] is int ? json['durationMinutes'] : 30,
      status: json['status']?.toString() ?? 'SCHEDULED',
      reason: json['reason']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'appointmentId': appointmentId,
      'patientId': patientId,
      'appointmentTime': appointmentTime.toUtc().toIso8601String(),
      'durationMinutes': durationMinutes,
      'status': status,
      'reason': reason,
    };
  }
}
