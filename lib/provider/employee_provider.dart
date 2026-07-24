import 'package:flutter/foundation.dart';
import 'package:truerealtycrm/data/models/api_response.dart';
import 'package:truerealtycrm/data/repositories/employee_repository.dart';
import 'package:truerealtycrm/provider/api_provider_base.dart';

class EmployeeProvider extends ApiProviderBase {
  EmployeeProvider({EmployeeRepository? repository})
    : _repository = repository ?? EmployeeRepository();

  final EmployeeRepository _repository;
  Map<String, dynamic>? _currentEmployee;

  Map<String, dynamic>? get currentEmployee => _currentEmployee;

  Future<ApiResponse<dynamic>?> fetchEmployees({
    String search = '',
    String role = 'all',
    String teamId = 'all',
    String? status = 'Active',
    int page = 1,
    int limit = 10,
  }) {
    return runApiRequest(
      () => _repository.listEmployees(
        search: search,
        role: role,
        teamId: teamId,
        status: status,
        page: page,
        limit: limit,
      ),
    );
  }

  Future<ApiResponse<dynamic>?> fetchCurrentEmployee() async {
    debugPrint('[EmployeeProvider] Loading current employee profile');
    final response = await runApiRequest(_repository.currentEmployee);
    if (response?.data is Map) {
      _currentEmployee = Map<String, dynamic>.from(response!.data as Map);
      debugPrint(
        '[EmployeeProvider] Current employee loaded: '
        'id=${_currentEmployee?['id'] ?? '-'}',
      );
      notifyListeners();
    }
    return response;
  }

  Future<ApiResponse<dynamic>?> fetchEmployee(String employeeId) {
    return runApiRequest(() => _repository.getEmployee(employeeId));
  }

  Future<ApiResponse<dynamic>?> createEmployee(Map<String, dynamic> body) {
    return runApiRequest(() => _repository.createEmployee(body));
  }

  Future<ApiResponse<dynamic>?> updateEmployee({
    required String employeeId,
    required Map<String, dynamic> body,
  }) async {
    debugPrint(
      '[EmployeeProvider] Updating employee $employeeId '
      'fields=${body.keys.join(',')}',
    );
    final response = await runApiRequest(
      () => _repository.updateEmployee(employeeId: employeeId, body: body),
    );
    if (response?.data is Map) {
      _currentEmployee = Map<String, dynamic>.from(response!.data as Map);
      debugPrint('[EmployeeProvider] Employee update completed successfully');
      notifyListeners();
    }
    return response;
  }

  Future<ApiResponse<dynamic>?> fetchTeams() {
    return runApiRequest(_repository.listTeams);
  }

  Future<ApiResponse<dynamic>?> fetchTeam(String teamId) {
    return runApiRequest(() => _repository.getTeam(teamId));
  }

  Future<ApiResponse<dynamic>?> createTeam(Map<String, dynamic> body) {
    return runApiRequest(() => _repository.createTeam(body));
  }

  Future<ApiResponse<dynamic>?> updateTeam({
    required String teamId,
    required Map<String, dynamic> body,
  }) {
    return runApiRequest(
      () => _repository.updateTeam(teamId: teamId, body: body),
    );
  }

  Future<ApiResponse<dynamic>?> addTeamMember({
    required String teamId,
    required String memberUserId,
  }) {
    return runApiRequest(
      () =>
          _repository.addTeamMember(teamId: teamId, memberUserId: memberUserId),
    );
  }

  Future<ApiResponse<dynamic>?> removeTeamMember({
    required String teamId,
    required String employeeId,
  }) {
    return runApiRequest(
      () =>
          _repository.removeTeamMember(teamId: teamId, employeeId: employeeId),
    );
  }
}
