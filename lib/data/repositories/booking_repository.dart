import 'package:truerealtycrm/data/api/api_client.dart';
import 'package:truerealtycrm/data/models/api_response.dart';

class BookingRepository {
  BookingRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();
  final ApiClient _apiClient;

  Future<ApiResponse<dynamic>> listBookings({
    required int page,
    required int limit,
  }) => _apiClient.get(
    '/bookings',
    queryParameters: {'page': page, 'limit': limit},
    headers: const {'Cache-Control': 'no-cache', 'Pragma': 'no-cache'},
  );

  Future<ApiResponse<dynamic>> financeReport({
    required String preset,
    required String scope,
    required String search,
    required String projectId,
    required String executiveId,
    required String status,
    required String teamId,
    required String paymentStatus,
    required int page,
    required int limit,
  }) => _apiClient.get(
    '/bookings/finance-report',
    queryParameters: {
      'preset': preset,
      'scope': scope,
      'search': search,
      'projectId': projectId,
      'executiveId': executiveId,
      'status': status,
      'teamId': teamId,
      'paymentStatus': paymentStatus,
      'page': page,
      'limit': limit,
    },
    headers: const {'Cache-Control': 'no-cache', 'Pragma': 'no-cache'},
  );
}
