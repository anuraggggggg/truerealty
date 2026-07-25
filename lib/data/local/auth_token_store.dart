import 'package:shared_preferences/shared_preferences.dart';

class AuthTokenStore {
  static const String _accessTokenKey = 'truroot_access_token';
  static const String _refreshTokenKey = 'truroot_refresh_token';
  static const String _roleKey = 'truroot_user_role';

  Future<String?> getAccessToken() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(_accessTokenKey);
  }

  Future<String?> getRefreshToken() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(_refreshTokenKey);
  }

  Future<String?> getCookieHeader() async {
    final accessToken = await getAccessToken();
    final refreshToken = await getRefreshToken();
    final cookies = <String>[];

    if (accessToken != null && accessToken.isNotEmpty) {
      cookies.add('accessToken=$accessToken');
    }
    if (refreshToken != null && refreshToken.isNotEmpty) {
      cookies.add('refreshToken=$refreshToken');
    }

    return cookies.isEmpty ? null : cookies.join('; ');
  }

  Future<void> saveTokens({String? accessToken, String? refreshToken}) async {
    final preferences = await SharedPreferences.getInstance();
    if (accessToken != null && accessToken.isNotEmpty) {
      await preferences.setString(_accessTokenKey, accessToken);
    }
    if (refreshToken != null && refreshToken.isNotEmpty) {
      await preferences.setString(_refreshTokenKey, refreshToken);
    }
  }

  Future<void> saveRole(String role) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_roleKey, role);
  }

  Future<String?> getRole() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(_roleKey);
  }

  Future<void> clear() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_accessTokenKey);
    await preferences.remove(_refreshTokenKey);
    await preferences.remove(_roleKey);
  }
}
