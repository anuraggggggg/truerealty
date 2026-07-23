import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'package:truerealtycrm/data/api/api_constants.dart';
import 'package:truerealtycrm/data/api/api_exception.dart';
import 'package:truerealtycrm/data/local/auth_token_store.dart';
import 'package:truerealtycrm/data/models/api_response.dart';

class ApiClient {
  ApiClient({
    http.Client? httpClient,
    AuthTokenStore? tokenStore,
    String baseUrl = ApiConstants.baseUrl,
  }) : _httpClient = httpClient ?? http.Client(),
       _tokenStore = tokenStore ?? AuthTokenStore(),
       _baseUrl = _resolveBaseUrl(baseUrl) {
    _debugLog('Base URL: $_baseUrl');
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

    _debugLog('--> $method $uri');
    _debugLog('requiresAuth: $requiresAuth');
    _debugLog('headers: ${_sanitizeHeaders(requestHeaders)}');
    if (body != null) {
      _debugLog('body: ${_sanitizeBody(body)}');
    }

    try {
      final response = await _send(
        method,
        uri,
        requestHeaders,
        body,
      ).timeout(ApiConstants.requestTimeout);
      stopwatch.stop();
      _debugLog(
        '<-- ${response.statusCode} $method $uri (${stopwatch.elapsedMilliseconds}ms)',
      );
      _debugLog('response: ${_truncateForLog(response.body)}');
      return _parseResponse(response);
    } on TimeoutException catch (error) {
      stopwatch.stop();
      _debugLog(
        'TIMEOUT $method $uri (${stopwatch.elapsedMilliseconds}ms): $error',
      );
      throw ApiException(
        type: ApiExceptionType.timeout,
        message:
            'Request timed out while connecting to $uri. Please check whether the API server is running.',
      );
    } on SocketException catch (error) {
      stopwatch.stop();
      _debugLog(
        'SOCKET ERROR $method $uri (${stopwatch.elapsedMilliseconds}ms): $error',
      );
      throw ApiException(
        type: ApiExceptionType.noInternet,
        message:
            'Could not reach the API server at $uri. Please check your connection and API base URL.',
      );
    } on ApiException catch (error) {
      stopwatch.stop();
      _debugLog(
        'API ERROR $method $uri (${stopwatch.elapsedMilliseconds}ms): '
        '${error.statusCode ?? '-'} ${error.message}',
      );
      if (error.body != null) {
        _debugLog('error body: ${_sanitizeBody(error.body)}');
      }
      rethrow;
    } catch (error) {
      stopwatch.stop();
      _debugLog(
        'UNEXPECTED ERROR $method $uri (${stopwatch.elapsedMilliseconds}ms): $error',
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
    final request = http.MultipartRequest('POST', uri);
    final requestHeaders = await _buildHeaders(headers, requiresAuth);
    requestHeaders.remove(HttpHeaders.contentTypeHeader);
    request.headers.addAll(requestHeaders);
    final stopwatch = Stopwatch()..start();

    _debugLog('--> POST $uri');
    _debugLog('upload file: $filePath');
    _debugLog('fields: ${_sanitizeBody(fields ?? <String, Object?>{})}');
    _debugLog('headers: ${_sanitizeHeaders(requestHeaders)}');

    for (final entry in (fields ?? <String, Object?>{}).entries) {
      if (entry.value != null) {
        request.fields[entry.key] = entry.value.toString();
      }
    }
    request.files.add(await http.MultipartFile.fromPath(fieldName, filePath));

    try {
      final streamed = await request.send().timeout(
        ApiConstants.requestTimeout,
      );
      final response = await http.Response.fromStream(streamed);
      stopwatch.stop();
      _debugLog(
        '<-- ${response.statusCode} POST $uri (${stopwatch.elapsedMilliseconds}ms)',
      );
      _debugLog('response: ${_truncateForLog(response.body)}');
      return _parseResponse(response);
    } on TimeoutException catch (error) {
      stopwatch.stop();
      _debugLog(
        'UPLOAD TIMEOUT POST $uri (${stopwatch.elapsedMilliseconds}ms): $error',
      );
      throw ApiException(
        type: ApiExceptionType.timeout,
        message:
            'Upload timed out while connecting to $uri. Please check whether the API server is running.',
      );
    } on SocketException catch (error) {
      stopwatch.stop();
      _debugLog(
        'UPLOAD SOCKET ERROR POST $uri (${stopwatch.elapsedMilliseconds}ms): $error',
      );
      throw ApiException(
        type: ApiExceptionType.noInternet,
        message:
            'Could not reach the API server at $uri. Please check your connection and API base URL.',
      );
    } on ApiException catch (error) {
      stopwatch.stop();
      _debugLog(
        'UPLOAD API ERROR POST $uri (${stopwatch.elapsedMilliseconds}ms): '
        '${error.statusCode ?? '-'} ${error.message}',
      );
      if (error.body != null) {
        _debugLog('error body: ${_sanitizeBody(error.body)}');
      }
      rethrow;
    } catch (error) {
      stopwatch.stop();
      _debugLog(
        'UPLOAD UNEXPECTED ERROR POST $uri (${stopwatch.elapsedMilliseconds}ms): $error',
      );
      throw ApiException(
        type: ApiExceptionType.unexpected,
        message: 'Unexpected upload error: $error',
      );
    }
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
    if (response.statusCode >= 200 && response.statusCode < 300) {
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

  static void _debugLog(String message) {
    if (kDebugMode) {
      debugPrint('[API] $message');
    }
  }
}
