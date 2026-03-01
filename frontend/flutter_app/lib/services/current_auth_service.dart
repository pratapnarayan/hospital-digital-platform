/// current_auth_service.dart
/// Selects between real and mock authentication services based on environment.

import 'environment.dart';
import 'auth_service.dart';
import 'mock_auth_service.dart';
import 'auth_service_interface.dart';

final AuthServiceInterface currentAuthService = useMockData ? mockAuthService : authService;
