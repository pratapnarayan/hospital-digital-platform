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
    required this.status,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
      hospital: json['hospital'],
      status: json['status'],
    );
  }

  String get initials {
    List<String> names = name.split(' ');
    if (names.length > 1) {
      return names[0].substring(0, 1) + names[1].substring(0, 1);
    } else {
      return names[0].substring(0, 1);
    }
  }
}
