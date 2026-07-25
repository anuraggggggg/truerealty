import 'package:truerealtycrm/data/api/api_client.dart';
import 'package:truerealtycrm/data/local/auth_token_store.dart';
import 'package:truerealtycrm/data/models/api_response.dart';
import 'package:truerealtycrm/data/models/auth_models.dart';

class AuthRepository {
  AuthRepository({ApiClient? apiClient, AuthTokenStore? tokenStore})
    : _apiClient = apiClient ?? ApiClient(tokenStore: tokenStore),
      _tokenStore = tokenStore ?? AuthTokenStore();

  final ApiClient _apiClient;
  final AuthTokenStore _tokenStore;

  Future<ApiResponse<AuthSession>> login(LoginRequest request) async {
    final response = await _apiClient.post(
      '/auth/login',
      body: request.toJson(),
      requiresAuth: false,
    );
    final session = AuthSession.fromJson(response.data);
    final cookieTokens = _tokensFromSetCookie(response.headers['set-cookie']);
    await _tokenStore.saveTokens(
      accessToken: session.accessToken ?? cookieTokens.accessToken,
      refreshToken: session.refreshToken ?? cookieTokens.refreshToken,
    );
    return response.copyWithData(
      session.copyWith(
        accessToken: session.accessToken ?? cookieTokens.accessToken,
        refreshToken: session.refreshToken ?? cookieTokens.refreshToken,
      ),
    );
  }

  Future<ApiResponse<AuthSession>> refresh() async {
    final refreshToken = await _tokenStore.getRefreshToken();
    final response = await _apiClient.post(
      '/auth/refresh',
      body: refreshToken == null ? null : {'refreshToken': refreshToken},
      requiresAuth: false,
    );
    final session = AuthSession.fromJson(response.data);
    final cookieTokens = _tokensFromSetCookie(response.headers['set-cookie']);
    await _tokenStore.saveTokens(
      accessToken: session.accessToken ?? cookieTokens.accessToken,
      refreshToken: session.refreshToken ?? cookieTokens.refreshToken,
    );
    return response.copyWithData(
      session.copyWith(
        accessToken: session.accessToken ?? cookieTokens.accessToken,
        refreshToken: session.refreshToken ?? cookieTokens.refreshToken,
      ),
    );
  }

  Future<ApiResponse<dynamic>> logout() async {
    try {
      return await _apiClient.post('/auth/logout');
    } finally {
      await _tokenStore.clear();
    }
  }

  Future<String?> getAccessToken() {
    return _tokenStore.getAccessToken();
  }

  Future<void> saveRole(String role) {
    return _tokenStore.saveRole(role);
  }

  Future<String?> getRole() {
    return _tokenStore.getRole();
  }

  Future<void> clearSession() {
    return _tokenStore.clear();
  }

  _CookieTokens _tokensFromSetCookie(String? setCookie) {
    if (setCookie == null || setCookie.isEmpty) {
      return const _CookieTokens();
    }

    return _CookieTokens(
      accessToken: _cookieValue(setCookie, 'accessToken'),
      refreshToken: _cookieValue(setCookie, 'refreshToken'),
    );
  }

  String? _cookieValue(String setCookie, String name) {
    final match = RegExp('(?:^|,\\s*)$name=([^;]+)').firstMatch(setCookie);
    return match?.group(1);
  }
}

class _CookieTokens {
  const _CookieTokens({this.accessToken, this.refreshToken});

  final String? accessToken;
  final String? refreshToken;
}
