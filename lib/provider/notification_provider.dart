import 'package:truerealtycrm/data/models/api_response.dart';
import 'package:truerealtycrm/data/repositories/notification_repository.dart';
import 'package:truerealtycrm/provider/api_provider_base.dart';

class NotificationProvider extends ApiProviderBase {
  NotificationProvider({NotificationRepository? repository})
    : _repository = repository ?? NotificationRepository();

  final NotificationRepository _repository;

  Future<ApiResponse<dynamic>?> fetchNotifications({
    int page = 1,
    int limit = 20,
    bool unreadOnly = false,
  }) {
    return runApiRequest(
      () => _repository.listNotifications(
        page: page,
        limit: limit,
        unreadOnly: unreadOnly,
      ),
    );
  }

  Future<ApiResponse<dynamic>?> markNotificationRead(String notificationId) {
    return runApiRequest(
      () => _repository.markNotificationRead(notificationId),
    );
  }

  Future<ApiResponse<dynamic>?> markAllNotificationsRead() {
    return runApiRequest(_repository.markAllNotificationsRead);
  }

  Future<ApiResponse<dynamic>?> registerDeviceToken(Map<String, dynamic> body) {
    return runApiRequest(() => _repository.registerDeviceToken(body));
  }

  Future<ApiResponse<dynamic>?> unregisterDeviceToken(String token) {
    return runApiRequest(() => _repository.unregisterDeviceToken(token));
  }
}
