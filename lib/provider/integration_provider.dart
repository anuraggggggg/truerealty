import 'package:truerealtycrm/data/models/api_response.dart';
import 'package:truerealtycrm/data/repositories/integration_repository.dart';
import 'package:truerealtycrm/provider/api_provider_base.dart';

class IntegrationProvider extends ApiProviderBase {
  IntegrationProvider({IntegrationRepository? repository})
    : _repository = repository ?? IntegrationRepository();

  final IntegrationRepository _repository;

  Future<ApiResponse<dynamic>?> fetchLeadImports({
    int page = 1,
    int limit = 10,
  }) {
    return runApiRequest(
      () => _repository.listLeadImports(page: page, limit: limit),
    );
  }

  Future<ApiResponse<dynamic>?> createLeadImport(Map<String, dynamic> body) {
    return runApiRequest(() => _repository.createLeadImport(body));
  }

  Future<ApiResponse<dynamic>?> fetchMagicBricksConfig() {
    return runApiRequest(_repository.getMagicBricksConfig);
  }

  Future<ApiResponse<dynamic>?> saveMagicBricksConfig(
    Map<String, dynamic> body,
  ) {
    return runApiRequest(() => _repository.saveMagicBricksConfig(body));
  }

  Future<ApiResponse<dynamic>?> generateMagicBricksApiKey() {
    return runApiRequest(_repository.generateMagicBricksApiKey);
  }

  Future<ApiResponse<dynamic>?> saveMagicBricksFieldMapping(
    Map<String, dynamic> body,
  ) {
    return runApiRequest(() => _repository.saveMagicBricksFieldMapping(body));
  }

  Future<ApiResponse<dynamic>?> testMagicBricksIntegration(
    Map<String, dynamic> body,
  ) {
    return runApiRequest(() => _repository.testMagicBricksIntegration(body));
  }

  Future<ApiResponse<dynamic>?> magicBricksPublicWebhook({
    required String apiKey,
    required Map<String, dynamic> body,
  }) {
    return runApiRequest(
      () => _repository.magicBricksPublicWebhook(apiKey: apiKey, body: body),
    );
  }
}
