import 'package:truerealtycrm/data/api/api_client.dart';
import 'package:truerealtycrm/data/models/api_response.dart';

class TaskRepository {
  TaskRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<ApiResponse<dynamic>> listTasks({
    String? assignedToId,
    String? status,
    int page = 1,
    int limit = 10,
  }) {
    return _apiClient.get(
      '/tasks',
      queryParameters: {
        'assignedToId': assignedToId,
        'status': status,
        'page': page,
        'limit': limit,
      },
    );
  }

  Future<ApiResponse<dynamic>> createEmployeeTask(Map<String, dynamic> body) {
    return _apiClient.post('/tasks', body: body);
  }

  Future<ApiResponse<dynamic>> updateEmployeeTask({
    required String taskId,
    required Map<String, dynamic> body,
  }) {
    return _apiClient.patch('/tasks/$taskId', body: body);
  }

  Future<ApiResponse<dynamic>> listCallLogs({
    String? leadId,
    String? dateFrom,
    String? dateTo,
  }) {
    return _apiClient.get(
      '/call-logs',
      queryParameters: {
        'leadId': leadId,
        'dateFrom': dateFrom,
        'dateTo': dateTo,
      },
    );
  }

  Future<ApiResponse<dynamic>> createCallLog(Map<String, dynamic> body) {
    return _apiClient.post('/call-logs', body: body);
  }
}
