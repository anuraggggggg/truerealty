import 'package:truerealtycrm/data/api/api_client.dart';
import 'package:truerealtycrm/data/models/api_response.dart';

class SiteVisitRepository {
  SiteVisitRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<ApiResponse<dynamic>> listSiteVisits({
    String? search,
    String? status,
    String? dateFrom,
    String? dateTo,
    String? fieldExecutiveId,
    int limit = 100,
    int page = 1,
  }) {
    return _apiClient.get(
      '/site-visits',
      queryParameters: {
        'search': search,
        'status': status,
        'dateFrom': dateFrom,
        'dateTo': dateTo,
        'fieldExecutiveId': fieldExecutiveId,
        'limit': limit,
        'page': page,
        '_ts': DateTime.now().millisecondsSinceEpoch,
      },
      headers: const {'Cache-Control': 'no-cache', 'Pragma': 'no-cache'},
    );
  }

  Future<ApiResponse<dynamic>> siteVisitOptions() {
    return _apiClient.get('/site-visits/options');
  }

  Future<ApiResponse<dynamic>> createSiteVisit(Map<String, dynamic> body) {
    return _apiClient.post('/site-visits', body: body);
  }

  Future<ApiResponse<dynamic>> getSiteVisit(String siteVisitId) {
    return _apiClient.get('/site-visits/$siteVisitId');
  }

  Future<ApiResponse<dynamic>> updateSiteVisit({
    required String siteVisitId,
    required Map<String, dynamic> body,
  }) {
    return _apiClient.patch('/site-visits/$siteVisitId', body: body);
  }

  Future<ApiResponse<dynamic>> checkIn({
    required String siteVisitId,
    required Map<String, dynamic> body,
  }) {
    return _apiClient.post('/site-visits/$siteVisitId/check-in', body: body);
  }

  Future<ApiResponse<dynamic>> checkOut({
    required String siteVisitId,
    required Map<String, dynamic> body,
  }) {
    return _apiClient.post('/site-visits/$siteVisitId/check-out', body: body);
  }

  Future<ApiResponse<dynamic>> trackingPing(Map<String, dynamic> body) {
    return _apiClient.post('/site-visits/tracking/ping', body: body);
  }

  Future<ApiResponse<dynamic>> stopTracking() {
    return _apiClient.post('/site-visits/tracking/stop');
  }

  Future<ApiResponse<dynamic>> liveTracking() {
    return _apiClient.get('/site-visits/tracking/live');
  }
}
