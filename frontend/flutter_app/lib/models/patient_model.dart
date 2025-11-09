class Patient {
  final String id;
  final String name;
  final String email;
  final String medicalId;
  final String? phone;
  final String? dateOfBirth;
  final String? bloodGroup;
  final String? address;
  final String status;
  final String? lastVisit;

  Patient({
    required this.id,
    required this.name,
    required this.email,
    required this.medicalId,
    this.phone,
    this.dateOfBirth,
    this.bloodGroup,
    this.address,
    this.status = 'Active',
    this.lastVisit,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      medicalId: json['medicalId'] as String,
      phone: json['phone'] as String?,
      dateOfBirth: json['dateOfBirth'] as String?,
      bloodGroup: json['bloodGroup'] as String?,
      address: json['address'] as String?,
      status: json['status'] as String? ?? 'Active',
      lastVisit: json['lastVisit'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'medicalId': medicalId,
      'phone': phone,
      'dateOfBirth': dateOfBirth,
      'bloodGroup': bloodGroup,
      'address': address,
      'status': status,
      'lastVisit': lastVisit,
    };
  }

  String get initials {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}
