class LoginRequest {
  const LoginRequest({required this.email, required this.password});

  final String email;
  final String password;

  Map<String, dynamic> toJson() {
    return {'email': email, 'password': password};
  }

  LoginRequest copyWith({String? email, String? password}) {
    return LoginRequest(
      email: email ?? this.email,
      password: password ?? this.password,
    );
  }
}

class AuthSession {
  const AuthSession({this.accessToken, this.refreshToken, this.user, this.raw});

  final String? accessToken;
  final String? refreshToken;
  final Map<String, dynamic>? user;
  final Object? raw;

  factory AuthSession.fromJson(Object? json) {
    final root = json is Map<String, dynamic> ? json : <String, dynamic>{};
    final data = root['data'] is Map<String, dynamic>
        ? root['data'] as Map<String, dynamic>
        : root;

    return AuthSession(
      accessToken: _findString(data, const [
        'accessToken',
        'access_token',
        'token',
        'jwt',
      ]),
      refreshToken: _findString(data, const ['refreshToken', 'refresh_token']),
      user: data['user'] is Map<String, dynamic>
          ? data['user'] as Map<String, dynamic>
          : null,
      raw: json,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'user': user,
      'raw': raw,
    };
  }

  AuthSession copyWith({
    String? accessToken,
    String? refreshToken,
    Map<String, dynamic>? user,
    Object? raw,
  }) {
    return AuthSession(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      user: user ?? this.user,
      raw: raw ?? this.raw,
    );
  }

  static String? _findString(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value != null && value.toString().isNotEmpty) {
        return value.toString();
      }
    }
    return null;
  }
}
