import 'package:truerealtycrm/data/api/api_client.dart';
import 'package:truerealtycrm/data/models/api_response.dart';

class UploadRepository {
  UploadRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<ApiResponse<dynamic>> uploadImage(String filePath) {
    return _apiClient.uploadFile('/uploads/images', filePath: filePath);
  }

  Future<ApiResponse<dynamic>> uploadProjectBrochure(String filePath) {
    return _apiClient.uploadFile(
      '/uploads/project-brochures',
      filePath: filePath,
    );
  }
}
