import 'package:truerealtycrm/data/models/api_response.dart';
import 'package:truerealtycrm/data/repositories/contact_lead_repository.dart';
import 'package:truerealtycrm/provider/api_provider_base.dart';

class ContactLeadProvider extends ApiProviderBase {
  ContactLeadProvider({ContactLeadRepository? repository})
    : _repository = repository ?? ContactLeadRepository();

  final ContactLeadRepository _repository;

  Future<ApiResponse<dynamic>?> fetchContactLeads({
    String search = '',
    int page = 1,
    int limit = 10,
  }) {
    return runApiRequest(
      () => _repository.listContactLeads(
        search: search,
        page: page,
        limit: limit,
      ),
    );
  }

  Future<ApiResponse<dynamic>?> createContactLead(Map<String, dynamic> body) {
    return runApiRequest(() => _repository.createContactLead(body));
  }

  Future<ApiResponse<dynamic>?> updateContactLead({
    required String contactLeadId,
    required Map<String, dynamic> body,
  }) {
    return runApiRequest(
      () => _repository.updateContactLead(
        contactLeadId: contactLeadId,
        body: body,
      ),
    );
  }

  Future<ApiResponse<dynamic>?> markInterested(String contactLeadId) {
    return runApiRequest(() => _repository.markInterested(contactLeadId));
  }

  Future<ApiResponse<dynamic>?> unarchiveContactLead(String contactLeadId) {
    return runApiRequest(() => _repository.unarchiveContactLead(contactLeadId));
  }

  Future<ApiResponse<dynamic>?> convertContactLead(String contactLeadId) {
    return runApiRequest(() => _repository.convertContactLead(contactLeadId));
  }

  Future<ApiResponse<dynamic>?> archiveContactLead(String contactLeadId) {
    return runApiRequest(() => _repository.archiveContactLead(contactLeadId));
  }
}
