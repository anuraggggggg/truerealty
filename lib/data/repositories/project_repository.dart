import 'package:truerealtycrm/data/api/api_client.dart';
import 'package:truerealtycrm/data/models/api_response.dart';

class ProjectRepository {
  ProjectRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<ApiResponse<dynamic>> listProjects({
    String? search,
    String? status,
    String? location,
  }) {
    return _apiClient.get(
      '/projects',
      queryParameters: {
        'search': search,
        'status': status,
        'location': location,
      },
    );
  }

  Future<ApiResponse<dynamic>> createProject(Map<String, dynamic> body) {
    return _apiClient.post('/projects', body: body);
  }

  Future<ApiResponse<dynamic>> getProject(String projectId) {
    return _apiClient.get('/projects/$projectId');
  }

  Future<ApiResponse<dynamic>> updateProject({
    required String projectId,
    required Map<String, dynamic> body,
  }) {
    return _apiClient.patch('/projects/$projectId', body: body);
  }

  Future<ApiResponse<dynamic>> listUnits(String projectId) {
    return _apiClient.get('/projects/$projectId/units');
  }

  Future<ApiResponse<dynamic>> getUnit({
    required String projectId,
    required String unitId,
  }) {
    return _apiClient.get('/projects/$projectId/units/$unitId');
  }

  Future<ApiResponse<dynamic>> createUnit({
    required String projectId,
    required Map<String, dynamic> body,
  }) {
    return _apiClient.post('/projects/$projectId/units', body: body);
  }

  Future<ApiResponse<dynamic>> updateUnit({
    required String projectId,
    required String unitId,
    required Map<String, dynamic> body,
  }) {
    return _apiClient.patch('/projects/$projectId/units/$unitId', body: body);
  }

  Future<ApiResponse<dynamic>> listProjectLeads({
    required String projectId,
    int page = 1,
    int limit = 10,
  }) {
    return _apiClient.get(
      '/projects/$projectId/leads',
      queryParameters: {'page': page, 'limit': limit},
    );
  }

  Future<ApiResponse<dynamic>> linkLeadToUnit({
    required String projectId,
    required String unitId,
    required String leadId,
  }) {
    return _apiClient.post(
      '/projects/$projectId/units/$unitId/link-lead',
      body: {'leadId': leadId},
    );
  }

  Future<ApiResponse<dynamic>> listBookings({
    int page = 1,
    int limit = 10,
    String? dateFrom,
    String? dateTo,
  }) {
    return _apiClient.get(
      '/bookings',
      queryParameters: {
        'page': page,
        'limit': limit,
        'dateFrom': dateFrom,
        'dateTo': dateTo,
      },
    );
  }
}
