import 'package:truerealtycrm/data/api/api_client.dart';
import 'package:truerealtycrm/data/models/api_response.dart';

class LeadMasterRepository {
  LeadMasterRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<ApiResponse<dynamic>> listMasterValues({
    required String masterCategory,
    bool activeOnly = true,
    String search = '',
  }) {
    return _apiClient.get(
      '/lead-masters/$masterCategory',
      queryParameters: {'activeOnly': activeOnly, 'search': search},
    );
  }

  Future<ApiResponse<dynamic>> createMasterValue({
    required String masterCategory,
    required Map<String, dynamic> body,
  }) {
    return _apiClient.post('/lead-masters/$masterCategory', body: body);
  }

  Future<ApiResponse<dynamic>> createProjectWhatsappTemplate(
    Map<String, dynamic> body,
  ) {
    return _apiClient.post(
      '/lead-masters/project_whatsapp_template',
      body: body,
    );
  }

  Future<ApiResponse<dynamic>> updateMasterValue({
    required String masterCategory,
    required String masterValueId,
    required Map<String, dynamic> body,
  }) {
    return _apiClient.patch(
      '/lead-masters/$masterCategory/$masterValueId',
      body: body,
    );
  }

  Future<ApiResponse<dynamic>> deleteMasterValue({
    required String masterCategory,
    required String masterValueId,
  }) {
    return _apiClient.delete('/lead-masters/$masterCategory/$masterValueId');
  }

  Future<ApiResponse<dynamic>> getLeadListColumns() {
    return _apiClient.get('/lead-list-columns');
  }

  Future<ApiResponse<dynamic>> updateLeadListColumns(List<String> columns) {
    return _apiClient.patch(
      '/lead-list-columns',
      body: {'visibleColumns': columns},
    );
  }
}
