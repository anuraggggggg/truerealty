import 'package:truerealtycrm/data/models/api_response.dart';
import 'package:truerealtycrm/data/repositories/task_repository.dart';
import 'package:truerealtycrm/provider/api_provider_base.dart';

class TasksProvider extends ApiProviderBase {
  TasksProvider({TaskRepository? repository})
    : _repository = repository ?? TaskRepository();

  final TaskRepository _repository;

  Future<ApiResponse<dynamic>?> fetchTasks({
    String? assignedToId,
    String? status,
    int page = 1,
    int limit = 10,
  }) {
    return runApiRequest(
      () => _repository.listTasks(
        assignedToId: assignedToId,
        status: status,
        page: page,
        limit: limit,
      ),
    );
  }

  Future<ApiResponse<dynamic>?> createEmployeeTask(Map<String, dynamic> body) {
    return runApiRequest(() => _repository.createEmployeeTask(body));
  }

  Future<ApiResponse<dynamic>?> updateEmployeeTask({
    required String taskId,
    required Map<String, dynamic> body,
  }) {
    return runApiRequest(
      () => _repository.updateEmployeeTask(taskId: taskId, body: body),
    );
  }

  Future<ApiResponse<dynamic>?> fetchCallLogs({
    String? leadId,
    String? dateFrom,
    String? dateTo,
  }) {
    return runApiRequest(
      () => _repository.listCallLogs(
        leadId: leadId,
        dateFrom: dateFrom,
        dateTo: dateTo,
      ),
    );
  }

  Future<ApiResponse<dynamic>?> createCallLog(Map<String, dynamic> body) {
    return runApiRequest(() => _repository.createCallLog(body));
  }
}
