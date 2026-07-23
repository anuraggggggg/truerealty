import 'package:truerealtycrm/data/models/api_response.dart';
import 'package:truerealtycrm/data/repositories/auto_assignment_repository.dart';
import 'package:truerealtycrm/provider/api_provider_base.dart';

class AutoAssignmentProvider extends ApiProviderBase {
  AutoAssignmentProvider({AutoAssignmentRepository? repository})
    : _repository = repository ?? AutoAssignmentRepository();

  final AutoAssignmentRepository _repository;

  Future<ApiResponse<dynamic>?> fetchRules() {
    return runApiRequest(_repository.listRules);
  }

  Future<ApiResponse<dynamic>?> createRule(Map<String, dynamic> body) {
    return runApiRequest(() => _repository.createRule(body));
  }

  Future<ApiResponse<dynamic>?> updateRule({
    required String autoAssignmentRuleId,
    required Map<String, dynamic> body,
  }) {
    return runApiRequest(
      () => _repository.updateRule(
        autoAssignmentRuleId: autoAssignmentRuleId,
        body: body,
      ),
    );
  }

  Future<ApiResponse<dynamic>?> deleteRule(String autoAssignmentRuleId) {
    return runApiRequest(() => _repository.deleteRule(autoAssignmentRuleId));
  }

  Future<ApiResponse<dynamic>?> fetchEvents({
    int page = 1,
    int limit = 20,
    String? ruleId,
  }) {
    return runApiRequest(
      () => _repository.listEvents(page: page, limit: limit, ruleId: ruleId),
    );
  }
}
