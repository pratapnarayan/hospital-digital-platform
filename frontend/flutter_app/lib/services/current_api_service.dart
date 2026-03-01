/// current_api_service.dart
/// Provides unified access to the correct API service based on environment.

import 'environment.dart';
import 'api_service.dart';
import 'mock_api_service.dart';
import 'api_service_interface.dart';

final ApiServiceInterface currentApiService = useMockData ? mockApiService : apiService;
