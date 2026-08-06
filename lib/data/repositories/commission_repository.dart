import 'package:truerealtycrm/data/api/api_client.dart';
import 'package:truerealtycrm/data/models/api_response.dart';
import 'package:truerealtycrm/data/models/commission_model.dart';

class CommissionRepository {
  CommissionRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();
  final ApiClient _apiClient;

  Future<ApiResponse<CommissionReport>> getMyCommissions({
    required String preset,
    String scope = 'mine',
    int page = 1,
    int limit = 10,
  }) async {
    final response = await _apiClient.get(
      '/bookings/my-commissions',
      queryParameters: {
        'preset': preset,
        'scope': scope,
        'page': page,
        'limit': limit,
      },
    );
    var payload = response.data;
    if (payload is Map && payload['data'] is Map) payload = payload['data'];
    return response.copyWithData(
      CommissionReport.fromJson(Map<String, dynamic>.from(payload as Map)),
    );
  }
}
