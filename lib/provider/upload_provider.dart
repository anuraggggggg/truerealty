import 'package:truerealtycrm/data/models/api_response.dart';
import 'package:truerealtycrm/data/repositories/upload_repository.dart';
import 'package:truerealtycrm/provider/api_provider_base.dart';

class UploadProvider extends ApiProviderBase {
  UploadProvider({UploadRepository? repository})
    : _repository = repository ?? UploadRepository();

  final UploadRepository _repository;

  Future<ApiResponse<dynamic>?> uploadImage(String filePath) {
    return runApiRequest(() => _repository.uploadImage(filePath));
  }

  Future<ApiResponse<dynamic>?> uploadProjectBrochure(String filePath) {
    return runApiRequest(() => _repository.uploadProjectBrochure(filePath));
  }
}
