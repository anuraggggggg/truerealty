import 'package:truerealtycrm/data/api/api_client.dart';
import 'package:truerealtycrm/data/models/api_response.dart';

class LeadRepository {
  LeadRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<ApiResponse<dynamic>> listLeads({
    String? search,
    int page = 1,
    int limit = 10,
    String? source,
    String? status,
    String? leadType,
    String? configuration,
    String? project,
    String? propertyType,
    String? assignedTo,
    String? team,
    String? area,
    String? slaStatus,
    String? dateFrom,
    String? dateTo,
  }) {
    return _apiClient.get(
      '/leads',
      queryParameters: {
        'search': search,
        'page': page,
        'limit': limit,
        'source': source,
        'status': status,
        'leadType': leadType,
        'configuration': configuration,
        'project': project,
        'propertyType': propertyType,
        'assignedTo': assignedTo,
        'team': team,
        'area': area,
        'slaStatus': slaStatus,
        'dateFrom': dateFrom,
        'dateTo': dateTo,
      },
      headers: const {'Cache-Control': 'no-cache', 'Pragma': 'no-cache'},
    );
  }

  Future<ApiResponse<dynamic>> listDeletedLeads({
    String search = '',
    int page = 1,
    int limit = 10,
  }) {
    return _apiClient.get(
      '/leads/deleted',
      queryParameters: {'search': search, 'page': page, 'limit': limit},
    );
  }

  Future<ApiResponse<dynamic>> getLead(String leadId) {
    return _apiClient.get(
      '/leads/$leadId',
      queryParameters: {'_ts': DateTime.now().millisecondsSinceEpoch},
      headers: const {'Cache-Control': 'no-cache', 'Pragma': 'no-cache'},
    );
  }

  Future<ApiResponse<dynamic>> createLead(Map<String, dynamic> body) {
    return _apiClient.post('/leads', body: body);
  }

  Future<ApiResponse<dynamic>> updateLead({
    required String leadId,
    required Map<String, dynamic> body,
  }) {
    return _apiClient.patch('/leads/$leadId', body: body);
  }

  Future<ApiResponse<dynamic>> deleteLead({
    required String leadId,
    String? deleteReason,
  }) {
    return _apiClient.delete(
      '/leads/$leadId',
      body: deleteReason == null ? null : {'deleteReason': deleteReason},
    );
  }

  Future<ApiResponse<dynamic>> restoreLead(String deletedLeadId) {
    return _apiClient.patch('/leads/$deletedLeadId/restore');
  }

  Future<ApiResponse<dynamic>> assignLead({
    required String leadId,
    required Map<String, dynamic> body,
  }) {
    return _apiClient.post('/leads/$leadId/assign', body: body);
  }

  Future<ApiResponse<dynamic>> bulkAssignLeads(Map<String, dynamic> body) {
    return _apiClient.post('/leads/bulk-assign', body: body);
  }

  Future<ApiResponse<dynamic>> bulkUpdateSource(Map<String, dynamic> body) {
    return _apiClient.patch('/leads/bulk/source', body: body);
  }

  Future<ApiResponse<dynamic>> moveLeadInPipeline({
    required String leadId,
    required Map<String, dynamic> body,
  }) {
    return _apiClient.post('/leads/$leadId/pipeline-move', body: body);
  }

  Future<ApiResponse<dynamic>> leadPipeline({
    String search = '',
    String teamId = 'all',
    int? limitPerColumn,
  }) {
    return _apiClient.get(
      '/leads/pipeline',
      queryParameters: {
        'search': search,
        'teamId': teamId,
        'limitPerColumn': limitPerColumn,
      },
    );
  }

  Future<ApiResponse<dynamic>> listFollowUps({
    int page = 1,
    int limit = 10,
    String? due,
    String? status,
    String? type,
  }) {
    return _apiClient.get(
      '/leads/follow-ups',
      queryParameters: {
        'page': page,
        'limit': limit,
        'due': due,
        'status': status,
        'type': type,
      },
      headers: const {'Cache-Control': 'no-cache', 'Pragma': 'no-cache'},
    );
  }

  Future<ApiResponse<dynamic>> myFollowUps() {
    return _apiClient.get('/leads/my-follow-ups');
  }

  Future<ApiResponse<dynamic>> fieldExecutiveFollowUps() {
    return _apiClient.get('/leads/field-executive/follow-ups');
  }

  Future<ApiResponse<dynamic>> createFollowUp({
    required String leadId,
    required Map<String, dynamic> body,
  }) {
    return _apiClient.post('/leads/$leadId/follow-ups', body: body);
  }

  Future<ApiResponse<dynamic>> updateFollowUp({
    required String leadId,
    required String followUpId,
    required Map<String, dynamic> body,
  }) {
    return _apiClient.patch(
      '/leads/$leadId/follow-ups/$followUpId',
      body: body,
    );
  }

  Future<ApiResponse<dynamic>> listLeadBookings(String leadId) {
    return _apiClient.get('/leads/$leadId/bookings');
  }

  Future<ApiResponse<dynamic>> createLeadBooking({
    required String leadId,
    required Map<String, dynamic> body,
  }) {
    return _apiClient.post('/leads/$leadId/bookings', body: body);
  }

  Future<ApiResponse<dynamic>> updateLeadBooking({
    required String leadId,
    required String bookingId,
    required Map<String, dynamic> body,
  }) {
    return _apiClient.patch('/leads/$leadId/bookings/$bookingId', body: body);
  }

  Future<ApiResponse<dynamic>> leadTimeline(String leadId) {
    return _apiClient.get('/leads/$leadId/timeline');
  }

  Future<ApiResponse<dynamic>> createLeadTask({
    required String leadId,
    required Map<String, dynamic> body,
  }) {
    return _apiClient.post('/leads/$leadId/tasks', body: body);
  }

  Future<ApiResponse<dynamic>> updateLeadTask({
    required String leadId,
    required String taskId,
    required Map<String, dynamic> body,
  }) {
    return _apiClient.patch('/leads/$leadId/tasks/$taskId', body: body);
  }

  Future<ApiResponse<dynamic>> createLeadNote({
    required String leadId,
    required Map<String, dynamic> body,
  }) {
    return _apiClient.post('/leads/$leadId/notes', body: body);
  }
}
