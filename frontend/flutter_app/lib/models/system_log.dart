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
      id: json['id'],
      timestamp: json['timestamp'],
      action: json['action'],
      user: json['user'],
      details: json['details'],
      level: json['level'],
    );
  }
}
