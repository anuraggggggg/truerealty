import 'package:truerealtycrm/data/api/api_client.dart';
import 'package:truerealtycrm/data/models/api_response.dart';

class AutoAssignmentRepository {
  AutoAssignmentRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<ApiResponse<dynamic>> listRules() {
    return _apiClient.get('/auto-assignment/rules');
  }

  Future<ApiResponse<dynamic>> createRule(Map<String, dynamic> body) {
    return _apiClient.post('/auto-assignment/rules', body: body);
  }

  Future<ApiResponse<dynamic>> updateRule({
    required String autoAssignmentRuleId,
    required Map<String, dynamic> body,
  }) {
    return _apiClient.patch(
      '/auto-assignment/rules/$autoAssignmentRuleId',
      body: body,
    );
  }

  Future<ApiResponse<dynamic>> deleteRule(String autoAssignmentRuleId) {
    return _apiClient.delete('/auto-assignment/rules/$autoAssignmentRuleId');
  }

  Future<ApiResponse<dynamic>> listEvents({
    int page = 1,
    int limit = 20,
    String? ruleId,
  }) {
    return _apiClient.get(
      '/auto-assignment/events',
      queryParameters: {'page': page, 'limit': limit, 'ruleId': ruleId},
    );
  }
}
