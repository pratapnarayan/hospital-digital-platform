import '../models/user.dart';
import '../models/hospital.dart';
import '../models/system_log.dart';

abstract class ApiServiceInterface {
  Future<List<User>> getUsers();
  Future<List<Hospital>> getHospitals();
  Future<List<SystemLog>> getSystemLogs();
}
