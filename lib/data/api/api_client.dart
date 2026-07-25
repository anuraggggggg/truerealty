import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import 'package:truerealtycrm/data/api/api_constants.dart';
import 'package:truerealtycrm/data/api/api_exception.dart';
import 'package:truerealtycrm/data/local/auth_token_store.dart';
import 'package:truerealtycrm/data/models/api_response.dart';

class ApiClient {
  static final ValueNotifier<int> sessionExpiredNotifier = ValueNotifier<int>(
    0,
  );

  ApiClient({
    http.Client? httpClient,
    AuthTokenStore? tokenStore,
    String baseUrl = ApiConstants.baseUrl,
  }) : _httpClient = httpClient ?? http.Client(),
       _tokenStore = tokenStore ?? AuthTokenStore(),
       _baseUrl = _resolveBaseUrl(baseUrl) {
    _debugLog('⚙️ Base URL: $_baseUrl');
  }

  final http.Client _httpClient;
  final AuthTokenStore _tokenStore;
  final String _baseUrl;

  Future<ApiResponse<dynamic>> get(
    String path, {
    Map<String, Object?>? queryParameters,
    Map<String, String>? headers,
    bool requiresAuth = true,
  }) {
    return request(
      'GET',
      path,
      queryParameters: queryParameters,
      headers: headers,
      requiresAuth: requiresAuth,
    );
  }

  Future<ApiResponse<dynamic>> post(
    String path, {
    Object? body,
    Map<String, Object?>? queryParameters,
    Map<String, String>? headers,
    bool requiresAuth = true,
  }) {
    return request(
      'POST',
      path,
      body: body,
      queryParameters: queryParameters,
      headers: headers,
      requiresAuth: requiresAuth,
    );
  }

  Future<ApiResponse<dynamic>> patch(
    String path, {
    Object? body,
    Map<String, Object?>? queryParameters,
    Map<String, String>? headers,
    bool requiresAuth = true,
  }) {
    return request(
      'PATCH',
      path,
      body: body,
      queryParameters: queryParameters,
      headers: headers,
      requiresAuth: requiresAuth,
    );
  }

  Future<ApiResponse<dynamic>> delete(
    String path, {
    Object? body,
    Map<String, Object?>? queryParameters,
    Map<String, String>? headers,
    bool requiresAuth = true,
  }) {
    return request(
      'DELETE',
      path,
      body: body,
      queryParameters: queryParameters,
      headers: headers,
      requiresAuth: requiresAuth,
    );
  }

  Future<ApiResponse<dynamic>> request(
    String method,
    String path, {
    Object? body,
    Map<String, Object?>? queryParameters,
    Map<String, String>? headers,
    bool requiresAuth = true,
  }) async {
    final uri = _buildUri(path, queryParameters);
    final requestHeaders = await _buildHeaders(headers, requiresAuth);
    final stopwatch = Stopwatch()..start();

    _debugLog('🔵 📤 REQUEST --> $method $uri');
    _debugLog('🔐 requiresAuth: $requiresAuth');
    _debugLog('📋 headers: ${_sanitizeHeaders(requestHeaders)}');
    if (body != null) {
      _debugLog('📦 body: ${_sanitizeBody(body)}');
    }

    try {
      var response = await _send(
        method,
        uri,
        requestHeaders,
        body,
      ).timeout(ApiConstants.requestTimeout);
      if (response.statusCode == HttpStatus.unauthorized &&
          requiresAuth &&
          path != '/auth/refresh') {
        _debugLog(
          '🟠 🔄 Access token rejected; attempting one session refresh',
        );
        final refreshed = await _refreshAccessToken();
        if (refreshed) {
          final retryHeaders = await _buildHeaders(headers, true);
          response = await _send(
            method,
            uri,
            retryHeaders,
            body,
          ).timeout(ApiConstants.requestTimeout);
          _debugLog(
            '${_responseIcon(response.statusCode)} <-- '
            '${response.statusCode} $method $uri '
            '(after session refresh)',
          );
        }
      }
      if (response.statusCode == HttpStatus.unauthorized && requiresAuth) {
        await _expireSession();
      }
      stopwatch.stop();
      _debugLog(
        '${_responseIcon(response.statusCode)} RESPONSE <-- '
        '${response.statusCode} $method $uri '
        '(${stopwatch.elapsedMilliseconds}ms)',
      );
      _debugLog(
        '${_responseIcon(response.statusCode)} body: '
        '${_sanitizeResponseForLog(response.body)}',
      );
      return _parseResponse(response);
    } on TimeoutException catch (error) {
      stopwatch.stop();
      _debugLog(
        '🔴 ⏱️ TIMEOUT $method $uri '
        '(${stopwatch.elapsedMilliseconds}ms): $error',
      );
      throw ApiException(
        type: ApiExceptionType.timeout,
        message:
            'Request timed out while connecting to $uri. Please check whether the API server is running.',
      );
    } on SocketException catch (error) {
      stopwatch.stop();
      _debugLog(
        '🔴 🌐 SOCKET ERROR $method $uri '
        '(${stopwatch.elapsedMilliseconds}ms): $error',
      );
      throw ApiException(
        type: ApiExceptionType.noInternet,
        message:
            'Could not reach the API server at $uri. Please check your connection and API base URL.',
      );
    } on ApiException catch (error) {
      stopwatch.stop();
      _debugLog(
        '🔴 🐛 API ERROR $method $uri '
        '(${stopwatch.elapsedMilliseconds}ms): '
        '${error.statusCode ?? '-'} ${error.message}',
      );
      if (error.body != null) {
        _debugLog('🔴 📦 error body: ${_sanitizeBody(error.body)}');
      }
      rethrow;
    } catch (error) {
      stopwatch.stop();
      _debugLog(
        '🔴 💥 UNEXPECTED ERROR $method $uri '
        '(${stopwatch.elapsedMilliseconds}ms): $error',
      );
      throw ApiException(
        type: ApiExceptionType.unexpected,
        message: 'Unexpected API error: $error',
      );
    }
  }

  Future<ApiResponse<dynamic>> uploadFile(
    String path, {
    required String filePath,
    String fieldName = 'file',
    Map<String, Object?>? fields,
    Map<String, String>? headers,
    bool requiresAuth = true,
  }) async {
    final uri = _buildUri(path, null);
    final stopwatch = Stopwatch()..start();

    _debugLog('🔵 📤 UPLOAD REQUEST --> POST $uri');
    _debugLog('📎 upload file: $filePath');
    _debugLog('📦 fields: ${_sanitizeBody(fields ?? <String, Object?>{})}');

    try {
      var response = await _sendMultipart(
        uri: uri,
        filePath: filePath,
        fieldName: fieldName,
        fields: fields,
        headers: headers,
        requiresAuth: requiresAuth,
      );
      if (response.statusCode == HttpStatus.unauthorized && requiresAuth) {
        _debugLog(
          '🟠 🔄 Upload access token rejected; '
          'attempting one session refresh',
        );
        final refreshed = await _refreshAccessToken();
        if (refreshed) {
          response = await _sendMultipart(
            uri: uri,
            filePath: filePath,
            fieldName: fieldName,
            fields: fields,
            headers: headers,
            requiresAuth: true,
          );
          _debugLog(
            '${_responseIcon(response.statusCode)} <-- '
            '${response.statusCode} POST $uri '
            '(upload after session refresh)',
          );
        }
      }
      if (response.statusCode == HttpStatus.unauthorized && requiresAuth) {
        await _expireSession();
      }
      stopwatch.stop();
      _debugLog(
        '${_responseIcon(response.statusCode)} UPLOAD RESPONSE <-- '
        '${response.statusCode} POST $uri '
        '(${stopwatch.elapsedMilliseconds}ms)',
      );
      _debugLog(
        '${_responseIcon(response.statusCode)} body: '
        '${_sanitizeResponseForLog(response.body)}',
      );
      return _parseResponse(response);
    } on TimeoutException catch (error) {
      stopwatch.stop();
      _debugLog(
        '🔴 ⏱️ UPLOAD TIMEOUT POST $uri '
        '(${stopwatch.elapsedMilliseconds}ms): $error',
      );
      throw ApiException(
        type: ApiExceptionType.timeout,
        message:
            'Upload timed out while connecting to $uri. Please check whether the API server is running.',
      );
    } on SocketException catch (error) {
      stopwatch.stop();
      _debugLog(
        '🔴 🌐 UPLOAD SOCKET ERROR POST $uri '
        '(${stopwatch.elapsedMilliseconds}ms): $error',
      );
      throw ApiException(
        type: ApiExceptionType.noInternet,
        message:
            'Could not reach the API server at $uri. Please check your connection and API base URL.',
      );
    } on ApiException catch (error) {
      stopwatch.stop();
      _debugLog(
        '🔴 🐛 UPLOAD API ERROR POST $uri '
        '(${stopwatch.elapsedMilliseconds}ms): '
        '${error.statusCode ?? '-'} ${error.message}',
      );
      if (error.body != null) {
        _debugLog('🔴 📦 error body: ${_sanitizeBody(error.body)}');
      }
      rethrow;
    } catch (error) {
      stopwatch.stop();
      _debugLog(
        '🔴 💥 UPLOAD UNEXPECTED ERROR POST $uri '
        '(${stopwatch.elapsedMilliseconds}ms): $error',
      );
      throw ApiException(
        type: ApiExceptionType.unexpected,
        message: 'Unexpected upload error: $error',
      );
    }
  }

  Future<http.Response> _sendMultipart({
    required Uri uri,
    required String filePath,
    required String fieldName,
    required Map<String, Object?>? fields,
    required Map<String, String>? headers,
    required bool requiresAuth,
  }) async {
    final request = http.MultipartRequest('POST', uri);
    final requestHeaders = await _buildHeaders(headers, requiresAuth);
    requestHeaders.remove(HttpHeaders.contentTypeHeader);
    request.headers.addAll(requestHeaders);
    _debugLog('📋 headers: ${_sanitizeHeaders(requestHeaders)}');

    for (final entry in (fields ?? <String, Object?>{}).entries) {
      if (entry.value != null) {
        request.fields[entry.key] = entry.value.toString();
      }
    }
    request.files.add(
      await http.MultipartFile.fromPath(
        fieldName,
        filePath,
        contentType: _mediaTypeForFile(filePath),
      ),
    );
    final streamed = await request.send().timeout(ApiConstants.requestTimeout);
    return http.Response.fromStream(streamed);
  }

  MediaType _mediaTypeForFile(String filePath) {
    final normalizedPath = filePath.toLowerCase().split('?').first;
    if (normalizedPath.endsWith('.jpg') ||
        normalizedPath.endsWith('.jpeg') ||
        normalizedPath.endsWith('.jfif')) {
      return MediaType('image', 'jpeg');
    }
    if (normalizedPath.endsWith('.png')) {
      return MediaType('image', 'png');
    }
    if (normalizedPath.endsWith('.webp')) {
      return MediaType('image', 'webp');
    }
    if (normalizedPath.endsWith('.heic')) {
      return MediaType('image', 'heic');
    }
    if (normalizedPath.endsWith('.heif')) {
      return MediaType('image', 'heif');
    }
    if (normalizedPath.endsWith('.gif')) {
      return MediaType('image', 'gif');
    }
    if (normalizedPath.endsWith('.pdf')) {
      return MediaType('application', 'pdf');
    }
    return MediaType('application', 'octet-stream');
  }

  Future<http.Response> _send(
    String method,
    Uri uri,
    Map<String, String> headers,
    Object? body,
  ) {
    final encodedBody = body == null ? null : jsonEncode(body);
    switch (method) {
      case 'GET':
        return _httpClient.get(uri, headers: headers);
      case 'POST':
        return _httpClient.post(uri, headers: headers, body: encodedBody);
      case 'PATCH':
        return _httpClient.patch(uri, headers: headers, body: encodedBody);
      case 'DELETE':
        return _httpClient.delete(uri, headers: headers, body: encodedBody);
      default:
        throw ApiException(
          type: ApiExceptionType.unexpected,
          message: 'Unsupported HTTP method: $method',
        );
    }
  }

  Uri _buildUri(String path, Map<String, Object?>? queryParameters) {
    final configuredBaseUri = Uri.parse(_baseUrl);
    final baseUri = _resolveUriForRuntime(configuredBaseUri);
    final normalizedPath = path.startsWith('/') ? path.substring(1) : path;
    final basePath = baseUri.path.endsWith('/')
        ? baseUri.path.substring(0, baseUri.path.length - 1)
        : baseUri.path;

    if (configuredBaseUri != baseUri) {
      _debugLog('Runtime base URL rewrite: $configuredBaseUri -> $baseUri');
    }

    return baseUri.replace(
      path: [if (basePath.isNotEmpty) basePath, normalizedPath].join('/'),
      queryParameters: _stringifyQuery(queryParameters),
    );
  }

  static String _resolveBaseUrl(String baseUrl) {
    return _resolveUriForRuntime(Uri.parse(baseUrl)).toString();
  }

  static Uri _resolveUriForRuntime(Uri uri) {
    final isLocalhost = uri.host == 'localhost' || uri.host == '127.0.0.1';
    if (isLocalhost) {
      return Uri.parse(ApiConstants.baseUrl);
    }
    return uri;
  }

  Future<Map<String, String>> _buildHeaders(
    Map<String, String>? headers,
    bool requiresAuth,
  ) async {
    final requestHeaders = <String, String>{
      HttpHeaders.acceptHeader: 'application/json',
      HttpHeaders.contentTypeHeader: 'application/json',
      ...?headers,
    };

    if (requiresAuth) {
      final token = await _tokenStore.getAccessToken();
      if (token != null && token.isNotEmpty) {
        requestHeaders[HttpHeaders.authorizationHeader] = 'Bearer $token';
      }

      final cookieHeader = await _tokenStore.getCookieHeader();
      if (cookieHeader != null && cookieHeader.isNotEmpty) {
        requestHeaders[HttpHeaders.cookieHeader] = cookieHeader;
      }
    }

    return requestHeaders;
  }

  Future<bool> _refreshAccessToken() async {
    final refreshToken = await _tokenStore.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      await _tokenStore.clear();
      return false;
    }

    final uri = _buildUri('/auth/refresh', null);
    final response = await _httpClient
        .post(
          uri,
          headers: {
            HttpHeaders.acceptHeader: 'application/json',
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.cookieHeader: 'refreshToken=$refreshToken',
          },
          body: jsonEncode({'refreshToken': refreshToken}),
        )
        .timeout(ApiConstants.requestTimeout);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      _debugLog('Session refresh failed with ${response.statusCode}');
      await _tokenStore.clear();
      return false;
    }

    final decoded = _decodeBody(response.body);
    final data = decoded is Map && decoded['data'] is Map
        ? Map<String, dynamic>.from(decoded['data'] as Map)
        : decoded is Map
        ? Map<String, dynamic>.from(decoded)
        : const <String, dynamic>{};
    final setCookie = response.headers[HttpHeaders.setCookieHeader] ?? '';
    final accessToken =
        _firstString(data, const [
          'accessToken',
          'access_token',
          'token',
          'jwt',
        ]) ??
        _cookieValue(setCookie, 'accessToken');
    final nextRefreshToken =
        _firstString(data, const ['refreshToken', 'refresh_token']) ??
        _cookieValue(setCookie, 'refreshToken') ??
        refreshToken;

    if (accessToken == null || accessToken.isEmpty) {
      await _tokenStore.clear();
      return false;
    }
    await _tokenStore.saveTokens(
      accessToken: accessToken,
      refreshToken: nextRefreshToken,
    );
    _debugLog('Session refreshed successfully');
    return true;
  }

  Future<void> _expireSession() async {
    await _tokenStore.clear();
    sessionExpiredNotifier.value++;
    _debugLog(
      '🔴 🔐 Session expired; cleared credentials and requested logout',
    );
  }

  static String? _firstString(Map<String, dynamic> map, List<String> keys) {
    for (final key in keys) {
      final value = map[key]?.toString().trim();
      if (value != null && value.isNotEmpty) return value;
    }
    return null;
  }

  static String? _cookieValue(String setCookie, String name) {
    final match = RegExp('(?:^|,?\\s*)$name=([^;]+)').firstMatch(setCookie);
    return match?.group(1);
  }

  Map<String, String>? _stringifyQuery(Map<String, Object?>? queryParameters) {
    if (queryParameters == null) {
      return null;
    }

    final entries = queryParameters.entries
        .where((entry) {
          final value = entry.value;
          return value != null && value.toString().isNotEmpty;
        })
        .map((entry) => MapEntry(entry.key, entry.value.toString()));

    final query = Map<String, String>.fromEntries(entries);
    return query.isEmpty ? null : query;
  }

  ApiResponse<dynamic> _parseResponse(http.Response response) {
    final decodedBody = _decodeBody(response.body);
    if ((response.statusCode >= 200 && response.statusCode < 300) ||
        response.statusCode == HttpStatus.notModified) {
      return ApiResponse<dynamic>(
        statusCode: response.statusCode,
        data: decodedBody,
        message: _readMessage(decodedBody),
        headers: response.headers,
      );
    }

    throw ApiException(
      type: _exceptionType(response.statusCode),
      statusCode: response.statusCode,
      message:
          _readMessage(decodedBody) ?? _defaultMessage(response.statusCode),
      body: decodedBody,
    );
  }

  Object? _decodeBody(String body) {
    if (body.isEmpty) {
      return null;
    }

    try {
      return jsonDecode(body);
    } on FormatException {
      return body;
    }
  }

  String? _readMessage(Object? body) {
    if (body is Map<String, dynamic>) {
      final message = body['message'] ?? body['error'] ?? body['detail'];
      return message?.toString();
    }
    return null;
  }

  ApiExceptionType _exceptionType(int statusCode) {
    switch (statusCode) {
      case 401:
        return ApiExceptionType.unauthorized;
      case 403:
        return ApiExceptionType.forbidden;
      case 404:
        return ApiExceptionType.notFound;
    }

    if (statusCode >= 500) {
      return ApiExceptionType.server;
    }
    return ApiExceptionType.badResponse;
  }

  String _defaultMessage(int statusCode) {
    switch (statusCode) {
      case 401:
        return 'Unauthorized. Please log in again.';
      case 403:
        return 'You do not have permission to perform this action.';
      case 404:
        return 'Requested resource was not found.';
    }

    if (statusCode >= 500) {
      return 'Server error. Please try again later.';
    }
    return 'Request failed with status code $statusCode.';
  }

  static Map<String, String> _sanitizeHeaders(Map<String, String> headers) {
    return headers.map((key, value) {
      final lowerKey = key.toLowerCase();
      if (lowerKey == HttpHeaders.authorizationHeader ||
          lowerKey == HttpHeaders.cookieHeader ||
          lowerKey.contains('token') ||
          lowerKey == 'x-api-key') {
        return MapEntry(key, _redacted(value));
      }
      return MapEntry(key, value);
    });
  }

  static Object? _sanitizeBody(Object? body) {
    if (body is Map) {
      return body.map((key, value) {
        final keyText = key.toString().toLowerCase();
        if (keyText.contains('password') ||
            keyText.contains('token') ||
            keyText.contains('apikey') ||
            keyText.contains('api_key')) {
          return MapEntry(key, _redacted(value?.toString() ?? ''));
        }
        return MapEntry(key, _sanitizeBody(value));
      });
    }

    if (body is List) {
      return body.map(_sanitizeBody).toList();
    }

    return body;
  }

  static String _redacted(String value) {
    if (value.isEmpty) {
      return '<empty>';
    }
    return '<redacted:${value.length} chars>';
  }

  static String _truncateForLog(Object? value) {
    final text = value?.toString() ?? 'null';
    const maxLength = 2000;
    if (text.length <= maxLength) {
      return text;
    }
    return '${text.substring(0, maxLength)}... <truncated ${text.length - maxLength} chars>';
  }

  static String _sanitizeResponseForLog(String responseBody) {
    if (responseBody.trim().isEmpty) return '<empty>';
    try {
      return _truncateForLog(_sanitizeBody(jsonDecode(responseBody)));
    } on FormatException {
      return _truncateForLog(responseBody);
    }
  }

  static String _responseIcon(int statusCode) {
    if (statusCode >= 200 && statusCode < 400) {
      return '🟢 🐛';
    }
    if (statusCode >= 400 && statusCode < 500) {
      return '🟠 🐛';
    }
    return '🔴 🐛';
  }

  static void _debugLog(String message) {
    if (kDebugMode) {
      debugPrint('[API] $message');
    }
  }
}
