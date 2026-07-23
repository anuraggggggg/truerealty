import 'package:truerealtycrm/data/api/api_client.dart';
import 'package:truerealtycrm/data/models/api_response.dart';

class ContactLeadRepository {
  ContactLeadRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<ApiResponse<dynamic>> listContactLeads({
    String search = '',
    int page = 1,
    int limit = 10,
  }) {
    return _apiClient.get(
      '/contact-leads',
      queryParameters: {'search': search, 'page': page, 'limit': limit},
    );
  }

  Future<ApiResponse<dynamic>> createContactLead(Map<String, dynamic> body) {
    return _apiClient.post('/contact-leads', body: body);
  }

  Future<ApiResponse<dynamic>> updateContactLead({
    required String contactLeadId,
    required Map<String, dynamic> body,
  }) {
    return _apiClient.patch('/contact-leads/$contactLeadId', body: body);
  }

  Future<ApiResponse<dynamic>> markInterested(String contactLeadId) {
    return _apiClient.patch('/contact-leads/$contactLeadId/interest');
  }

  Future<ApiResponse<dynamic>> unarchiveContactLead(String contactLeadId) {
    return _apiClient.patch('/contact-leads/$contactLeadId/unarchive');
  }

  Future<ApiResponse<dynamic>> convertContactLead(String contactLeadId) {
    return _apiClient.post('/contact-leads/$contactLeadId/convert');
  }

  Future<ApiResponse<dynamic>> archiveContactLead(String contactLeadId) {
    return _apiClient.delete('/contact-leads/$contactLeadId');
  }
}
