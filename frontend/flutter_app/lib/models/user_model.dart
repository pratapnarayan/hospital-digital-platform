class User {
  final int id;
  final String name;
  final String email;
  final String role;
  final String hospital;
  final String status;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.hospital,
    this.status = 'Active',
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      hospital: json['hospital'] as String,
      status: json['status'] as String? ?? 'Active',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'hospital': hospital,
      'status': status,
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
    this.status = 'Active',
  });

  factory Hospital.fromJson(Map<String, dynamic> json) {
    return Hospital(
      id: json['id'] as int,
      name: json['name'] as String,
      location: json['location'] as String,
      type: json['type'] as String,
      patients: json['patients'] as int,
      doctors: json['doctors'] as int,
      status: json['status'] as String? ?? 'Active',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'type': type,
      'patients': patients,
      'doctors': doctors,
      'status': status,
    };
  }
}

class SystemLog {
  final int id;
  final String timestamp;
  final String action;
  final String user;
  final String details;
  final String level;

  SystemLog({
    required this.id,
    required this.timestamp,
    required this.action,
    required this.user,
    required this.details,
    required this.level,
  });

  factory SystemLog.fromJson(Map<String, dynamic> json) {
    return SystemLog(
      id: json['id'] as int,
      timestamp: json['timestamp'] as String,
      action: json['action'] as String,
      user: json['user'] as String,
      details: json['details'] as String,
      level: json['level'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp,
      'action': action,
      'user': user,
      'details': details,
      'level': level,
    };
  }
}
