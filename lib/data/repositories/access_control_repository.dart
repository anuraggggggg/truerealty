import 'package:truerealtycrm/data/api/api_client.dart';
import 'package:truerealtycrm/data/models/api_response.dart';

class AccessControlRepository {
  AccessControlRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<ApiResponse<dynamic>> listModules() {
    return _apiClient.get('/access/modules');
  }

  Future<ApiResponse<dynamic>> listTemplates() {
    return _apiClient.get('/access/templates');
  }

  Future<ApiResponse<dynamic>> updateRoleTemplate({
    required String role,
    required Map<String, dynamic> body,
  }) {
    return _apiClient.patch('/access/templates/$role', body: body);
  }

  Future<ApiResponse<dynamic>> getUserAccess(String employeeId) {
    return _apiClient.get('/access/users/$employeeId');
  }

  Future<ApiResponse<dynamic>> updateUserAccess({
    required String employeeId,
    required Map<String, dynamic> body,
  }) {
    return _apiClient.patch('/access/users/$employeeId', body: body);
  }

  Future<ApiResponse<dynamic>> resetUserAccess(String employeeId) {
    return _apiClient.delete('/access/users/$employeeId');
  }
}
