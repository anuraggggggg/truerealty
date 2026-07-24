import 'package:truerealtycrm/data/api/api_client.dart';
import 'package:truerealtycrm/data/models/api_response.dart';

class NotificationRepository {
  NotificationRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<ApiResponse<dynamic>> listNotifications({
    int page = 1,
    int limit = 20,
    bool unreadOnly = false,
  }) {
    return _apiClient.get(
      '/notifications',
      queryParameters: {'page': page, 'limit': limit, 'unreadOnly': unreadOnly},
      headers: const {'Cache-Control': 'no-cache', 'Pragma': 'no-cache'},
    );
  }

  Future<ApiResponse<dynamic>> markNotificationRead(String notificationId) {
    return _apiClient.patch('/notifications/$notificationId/read');
  }

  Future<ApiResponse<dynamic>> markAllNotificationsRead() {
    return _apiClient.patch('/notifications/mark-all-read');
  }

  Future<ApiResponse<dynamic>> registerDeviceToken(Map<String, dynamic> body) {
    return _apiClient.post('/notifications/device-tokens', body: body);
  }

  Future<ApiResponse<dynamic>> unregisterDeviceToken(String token) {
    return _apiClient.delete(
      '/notifications/device-tokens',
      body: {'token': token},
    );
  }
}
