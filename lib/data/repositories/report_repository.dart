import 'package:truerealtycrm/data/api/api_client.dart';
import 'package:truerealtycrm/data/models/api_response.dart';

class ReportRepository {
  ReportRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<ApiResponse<dynamic>> listDuplicates() {
    return _apiClient.get('/duplicates');
  }

  Future<ApiResponse<dynamic>> sourceAnalytics() {
    return _apiClient.get('/reports/source-analytics');
  }

  Future<ApiResponse<dynamic>> conversionAnalytics({
    String? dateFrom,
    String? dateTo,
  }) {
    return _apiClient.get(
      '/reports/conversion-analytics',
      queryParameters: {'dateFrom': dateFrom, 'dateTo': dateTo},
    );
  }
}
