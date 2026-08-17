import 'package:flutter/foundation.dart';

import 'package:truerealtycrm/data/api/api_exception.dart';
import 'package:truerealtycrm/data/models/api_response.dart';

abstract class ApiProviderBase extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  Object? _errorBody;
  int? _errorStatusCode;
  ApiResponse<dynamic>? _lastResponse;

  bool get isLoading => _isLoading;
  String? get error => _error;
  Object? get errorBody => _errorBody;
  int? get errorStatusCode => _errorStatusCode;
  ApiResponse<dynamic>? get lastResponse => _lastResponse;
  bool get hasError => _error != null;
  bool get hasSuccess => _lastResponse?.isSuccess ?? false;

  @protected
  Future<ApiResponse<T>?> runApiRequest<T>(
    Future<ApiResponse<T>> Function() request,
  ) async {
    final providerName = runtimeType.toString();
    debugPrint('🔵 [$providerName] API request started');
    _isLoading = true;
    _error = null;
    _errorBody = null;
    _errorStatusCode = null;
    notifyListeners();

    try {
      final response = await request();
      _lastResponse = response;
      debugPrint(
        '🟢 🐛 [$providerName] API response success: '
        'status=${response.statusCode}, message=${response.message ?? '-'}',
      );
      return response;
    } on ApiException catch (exception) {
      _error = exception.message;
      _errorBody = exception.body;
      _errorStatusCode = exception.statusCode;
      debugPrint(
        '🔴 🐛 [$providerName] API request failed: '
        'type=${exception.type.name}, status=${exception.statusCode ?? '-'}, '
        'message=${exception.message}',
      );
      if (exception.body != null) {
        debugPrint('🔴 📦 [$providerName] API error body: ${exception.body}');
      }
      return null;
    } catch (error) {
      _error = 'Unexpected error: $error';
      debugPrint('🔴 💥 [$providerName] API request unexpected error: $error');
      return null;
    } finally {
      _isLoading = false;
      debugPrint('⚪ [$providerName] API request finished');
      notifyListeners();
    }
  }

  void clearApiState() {
    _error = null;
    _errorBody = null;
    _errorStatusCode = null;
    _lastResponse = null;
    notifyListeners();
  }
}
