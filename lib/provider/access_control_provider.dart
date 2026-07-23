import 'package:truerealtycrm/data/models/api_response.dart';
import 'package:truerealtycrm/data/repositories/access_control_repository.dart';
import 'package:truerealtycrm/provider/api_provider_base.dart';

class AccessControlProvider extends ApiProviderBase {
  AccessControlProvider({AccessControlRepository? repository})
    : _repository = repository ?? AccessControlRepository();

  final AccessControlRepository _repository;

  Future<ApiResponse<dynamic>?> fetchModules() {
    return runApiRequest(_repository.listModules);
  }

  Future<ApiResponse<dynamic>?> fetchTemplates() {
    return runApiRequest(_repository.listTemplates);
  }

  Future<ApiResponse<dynamic>?> updateRoleTemplate({
    required String role,
    required Map<String, dynamic> body,
  }) {
    return runApiRequest(
      () => _repository.updateRoleTemplate(role: role, body: body),
    );
  }

  Future<ApiResponse<dynamic>?> fetchUserAccess(String employeeId) {
    return runApiRequest(() => _repository.getUserAccess(employeeId));
  }

  Future<ApiResponse<dynamic>?> updateUserAccess({
    required String employeeId,
    required Map<String, dynamic> body,
  }) {
    return runApiRequest(
      () => _repository.updateUserAccess(employeeId: employeeId, body: body),
    );
  }

  Future<ApiResponse<dynamic>?> resetUserAccess(String employeeId) {
    return runApiRequest(() => _repository.resetUserAccess(employeeId));
  }
}
