class Hospital {
  final int id;
  final String name;
  final String location;
  final String type;
  final int patients;
  final int doctors;
  final String status;

  Hospital({
    required this.id,
    required this.name,
    required this.location,
    required this.type,
    required this.patients,
    required this.doctors,
    required this.status,
  });

  factory Hospital.fromJson(Map<String, dynamic> json) {
    return Hospital(
      id: json['id'],
      name: json['name'],
      location: json['location'],
      type: json['type'],
      patients: json['patients'],
      doctors: json['doctors'],
      status: json['status'],
    );
  }
}
