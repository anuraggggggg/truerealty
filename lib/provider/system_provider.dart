import 'package:truerealtycrm/data/models/api_response.dart';
import 'package:truerealtycrm/data/repositories/system_repository.dart';
import 'package:truerealtycrm/provider/api_provider_base.dart';

class SystemProvider extends ApiProviderBase {
  SystemProvider({SystemRepository? repository})
    : _repository = repository ?? SystemRepository();

  final SystemRepository _repository;

  Future<ApiResponse<dynamic>?> rootHealth() {
    return runApiRequest(_repository.rootHealth);
  }

  Future<ApiResponse<dynamic>?> hello() {
    return runApiRequest(_repository.hello);
  }

  Future<ApiResponse<dynamic>?> health() {
    return runApiRequest(_repository.health);
  }

  Future<ApiResponse<dynamic>?> liveness() {
    return runApiRequest(_repository.liveness);
  }

  Future<ApiResponse<dynamic>?> readiness() {
    return runApiRequest(_repository.readiness);
  }
}
