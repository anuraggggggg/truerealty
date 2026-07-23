import 'package:truerealtycrm/data/api/api_client.dart';
import 'package:truerealtycrm/data/models/api_response.dart';

class IntegrationRepository {
  IntegrationRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<ApiResponse<dynamic>> listLeadImports({int page = 1, int limit = 10}) {
    return _apiClient.get(
      '/lead-imports',
      queryParameters: {'page': page, 'limit': limit},
    );
  }

  Future<ApiResponse<dynamic>> createLeadImport(Map<String, dynamic> body) {
    return _apiClient.post('/lead-imports', body: body);
  }

  Future<ApiResponse<dynamic>> getMagicBricksConfig() {
    return _apiClient.get('/integrations/magicbricks');
  }

  Future<ApiResponse<dynamic>> saveMagicBricksConfig(
    Map<String, dynamic> body,
  ) {
    return _apiClient.patch('/integrations/magicbricks', body: body);
  }

  Future<ApiResponse<dynamic>> generateMagicBricksApiKey() {
    return _apiClient.post('/integrations/magicbricks/generate-api-key');
  }

  Future<ApiResponse<dynamic>> saveMagicBricksFieldMapping(
    Map<String, dynamic> body,
  ) {
    return _apiClient.patch(
      '/integrations/magicbricks/field-mapping',
      body: body,
    );
  }

  Future<ApiResponse<dynamic>> testMagicBricksIntegration(
    Map<String, dynamic> body,
  ) {
    return _apiClient.post('/integrations/magicbricks/test', body: body);
  }

  Future<ApiResponse<dynamic>> magicBricksPublicWebhook({
    required String apiKey,
    required Map<String, dynamic> body,
  }) {
    return _apiClient.post(
      '/integrations/magicbricks/leads',
      body: body,
      headers: {'x-api-key': apiKey},
      requiresAuth: false,
    );
  }
}
