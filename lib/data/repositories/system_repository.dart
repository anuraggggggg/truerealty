import 'package:truerealtycrm/data/api/api_client.dart';
import 'package:truerealtycrm/data/models/api_response.dart';

class SystemRepository {
  SystemRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<ApiResponse<dynamic>> rootHealth() {
    return _apiClient.get('/', requiresAuth: false);
  }

  Future<ApiResponse<dynamic>> hello() {
    return _apiClient.get('/hello', requiresAuth: false);
  }

  Future<ApiResponse<dynamic>> health() {
    return _apiClient.get('/health', requiresAuth: false);
  }

  Future<ApiResponse<dynamic>> liveness() {
    return _apiClient.get('/health/live', requiresAuth: false);
  }

  Future<ApiResponse<dynamic>> readiness() {
    return _apiClient.get('/health/ready', requiresAuth: false);
  }
}
