import 'package:truerealtycrm/data/models/api_response.dart';
import 'package:truerealtycrm/data/repositories/lead_master_repository.dart';
import 'package:truerealtycrm/provider/api_provider_base.dart';

class LeadMasterProvider extends ApiProviderBase {
  LeadMasterProvider({LeadMasterRepository? repository})
    : _repository = repository ?? LeadMasterRepository();

  final LeadMasterRepository _repository;

  Future<ApiResponse<dynamic>?> fetchMasterValues({
    required String masterCategory,
    bool activeOnly = true,
    String search = '',
  }) {
    return runApiRequest(
      () => _repository.listMasterValues(
        masterCategory: masterCategory,
        activeOnly: activeOnly,
        search: search,
      ),
    );
  }

  Future<ApiResponse<dynamic>?> createMasterValue({
    required String masterCategory,
    required Map<String, dynamic> body,
  }) {
    return runApiRequest(
      () => _repository.createMasterValue(
        masterCategory: masterCategory,
        body: body,
      ),
    );
  }

  Future<ApiResponse<dynamic>?> createProjectWhatsappTemplate(
    Map<String, dynamic> body,
  ) {
    return runApiRequest(() => _repository.createProjectWhatsappTemplate(body));
  }

  Future<ApiResponse<dynamic>?> updateMasterValue({
    required String masterCategory,
    required String masterValueId,
    required Map<String, dynamic> body,
  }) {
    return runApiRequest(
      () => _repository.updateMasterValue(
        masterCategory: masterCategory,
        masterValueId: masterValueId,
        body: body,
      ),
    );
  }

  Future<ApiResponse<dynamic>?> deleteMasterValue({
    required String masterCategory,
    required String masterValueId,
  }) {
    return runApiRequest(
      () => _repository.deleteMasterValue(
        masterCategory: masterCategory,
        masterValueId: masterValueId,
      ),
    );
  }

  Future<ApiResponse<dynamic>?> fetchLeadListColumns() {
    return runApiRequest(_repository.getLeadListColumns);
  }

  Future<ApiResponse<dynamic>?> updateLeadListColumns(List<String> columns) {
    return runApiRequest(() => _repository.updateLeadListColumns(columns));
  }
}
