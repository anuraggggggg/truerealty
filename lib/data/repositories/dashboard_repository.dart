import 'package:truerealtycrm/data/api/api_client.dart';
import 'package:truerealtycrm/data/models/api_response.dart';

class DashboardRepository {
  DashboardRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<ApiResponse<dynamic>> adminDashboard({
    String range = 'today',
    String? dateFrom,
    String? dateTo,
    String? source,
    String? status,
    String? leadType,
    String? propertyType,
    String? configuration,
    String? assignedTo,
    String? team,
    String? area,
    String? slaStatus,
  }) {
    return _apiClient.get(
      '/dashboard/admin',
      queryParameters: {
        'range': range,
        'dateFrom': dateFrom,
        'dateTo': dateTo,
        'source': source,
        'status': status,
        'leadType': leadType,
        'propertyType': propertyType,
        'configuration': configuration,
        'assignedTo': assignedTo,
        'team': team,
        'area': area,
        'slaStatus': slaStatus,
      },
      headers: const {'Cache-Control': 'no-cache', 'Pragma': 'no-cache'},
    );
  }

  Future<ApiResponse<dynamic>> adminPerformance({
    String? dateFrom,
    String? dateTo,
    String role = 'all',
    String teamId = 'all',
    String userId = 'all',
    String activityType = 'all',
    int page = 1,
    int limit = 20,
  }) {
    return _apiClient.get(
      '/dashboard/admin/performance',
      queryParameters: {
        'dateFrom': dateFrom,
        'dateTo': dateTo,
        'role': role,
        'teamId': teamId,
        'userId': userId,
        'activityType': activityType,
        'page': page,
        'limit': limit,
      },
    );
  }

  Future<ApiResponse<dynamic>> rankings({
    String range = 'monthly',
    String mode = 'both',
    String teamId = 'all',
    String userId = 'all',
  }) {
    return _apiClient.get(
      '/dashboard/rankings',
      queryParameters: {
        'range': range,
        'mode': mode,
        'teamId': teamId,
        'userId': userId,
      },
    );
  }

  Future<ApiResponse<dynamic>> telecallerDashboard() {
    return _apiClient.get('/dashboard/telecaller');
  }

  Future<ApiResponse<dynamic>> fieldExecutiveDashboard() {
    return _apiClient.get('/dashboard/field-executive');
  }
}
