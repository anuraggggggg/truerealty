import 'package:truerealtycrm/data/api/api_client.dart';
import 'package:truerealtycrm/data/models/api_response.dart';

class EmployeeRepository {
  EmployeeRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<ApiResponse<dynamic>> listEmployees({
    String search = '',
    String role = 'all',
    String teamId = 'all',
    String? status = 'Active',
    int page = 1,
    int limit = 10,
  }) {
    return _apiClient.get(
      '/employees',
      queryParameters: {
        'search': search,
        'role': role,
        'teamId': teamId,
        'status': status,
        'page': page,
        'limit': limit,
      },
    );
  }

  Future<ApiResponse<dynamic>> currentEmployee() {
    return _apiClient.get(
      '/employees/me',
      queryParameters: {'_ts': DateTime.now().millisecondsSinceEpoch},
      headers: const {
        'Cache-Control': 'no-cache, no-store, must-revalidate',
        'Pragma': 'no-cache',
      },
    );
  }

  Future<ApiResponse<dynamic>> getEmployee(String employeeId) {
    return _apiClient.get(
      '/employees/$employeeId',
      queryParameters: {'_ts': DateTime.now().millisecondsSinceEpoch},
      headers: const {
        'Cache-Control': 'no-cache, no-store, must-revalidate',
        'Pragma': 'no-cache',
      },
    );
  }

  Future<ApiResponse<dynamic>> createEmployee(Map<String, dynamic> body) {
    return _apiClient.post('/employees', body: body);
  }

  Future<ApiResponse<dynamic>> updateEmployee({
    required String employeeId,
    required Map<String, dynamic> body,
  }) {
    return _apiClient.patch('/employees/$employeeId', body: body);
  }

  Future<ApiResponse<dynamic>> listTeams() {
    return _apiClient.get('/teams');
  }

  Future<ApiResponse<dynamic>> getTeam(String teamId) {
    return _apiClient.get('/teams/$teamId');
  }

  Future<ApiResponse<dynamic>> createTeam(Map<String, dynamic> body) {
    return _apiClient.post('/teams', body: body);
  }

  Future<ApiResponse<dynamic>> updateTeam({
    required String teamId,
    required Map<String, dynamic> body,
  }) {
    return _apiClient.patch('/teams/$teamId', body: body);
  }

  Future<ApiResponse<dynamic>> addTeamMember({
    required String teamId,
    required String memberUserId,
  }) {
    return _apiClient.post(
      '/teams/$teamId/members',
      body: {'memberUserId': memberUserId},
    );
  }

  Future<ApiResponse<dynamic>> removeTeamMember({
    required String teamId,
    required String employeeId,
  }) {
    return _apiClient.delete('/teams/$teamId/members/$employeeId');
  }
}
