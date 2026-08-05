class LoginRequest {
  const LoginRequest({
    this.email,
    this.mobile,
    required this.password,
  }) : assert(
         (email != null && email != '') || (mobile != null && mobile != ''),
         'Either email or mobile is required',
       );

  final String? email;
  final String? mobile;
  final String password;

  bool get isEmailLogin => email != null && email!.trim().isNotEmpty;

  Map<String, dynamic> toJson() {
    final body = <String, dynamic>{'password': password};
    if (isEmailLogin) {
      body['email'] = email!.trim();
    } else {
      body['mobile'] = mobile!.trim();
    }
    return body;
  }
}

class VerifyOtpRequest {
  const VerifyOtpRequest({required this.identifier, required this.otp});

  final String identifier;
  final String otp;

  Map<String, dynamic> toJson() {
    return {'identifier': identifier.trim(), 'otp': otp.trim()};
  }
}

class OtpChallenge {
  const OtpChallenge({
    required this.identifier,
    required this.deliveryTarget,
    required this.expiresInSeconds,
    required this.resendAfterSeconds,
    this.message,
  });

  final String identifier;
  final String deliveryTarget;
  final int expiresInSeconds;
  final int resendAfterSeconds;
  final String? message;

  factory OtpChallenge.fromJson(Map<String, dynamic> json) {
    return OtpChallenge(
      identifier:
          _readString(json, const ['identifier', 'email', 'mobile']) ?? '',
      deliveryTarget:
          _readString(json, const [
            'deliveryTarget',
            'delivery_target',
            'maskedPhone',
            'masked_phone',
          ]) ??
          'your registered phone',
      expiresInSeconds: _readInt(json, const [
        'expiresInSeconds',
        'expires_in_seconds',
        'expiresIn',
      ], 300),
      resendAfterSeconds: _readInt(json, const [
        'resendAfterSeconds',
        'resend_after_seconds',
        'resendIn',
      ], 60),
      message: _readString(json, const ['message']),
    );
  }
}

class AuthSession {
  const AuthSession({
    this.accessToken,
    this.refreshToken,
    this.user,
    this.raw,
    this.requiresOtp = false,
    this.otpChallenge,
  });

  final String? accessToken;
  final String? refreshToken;
  final Map<String, dynamic>? user;
  final Object? raw;
  final bool requiresOtp;
  final OtpChallenge? otpChallenge;

  bool get hasTokens => accessToken != null && accessToken!.isNotEmpty;

  factory AuthSession.fromJson(Object? json) {
    final root = json is Map ? Map<String, dynamic>.from(json) : <String, dynamic>{};
    final data = root['data'] is Map
        ? Map<String, dynamic>.from(root['data'] as Map)
        : root;

    final requiresOtp =
        data['requiresOtp'] == true || root['requiresOtp'] == true;
    final accessToken = _findString(data, const [
      'accessToken',
      'access_token',
      'token',
      'jwt',
    ]);

    return AuthSession(
      accessToken: accessToken,
      refreshToken: _findString(data, const ['refreshToken', 'refresh_token']),
      user: data['user'] is Map
          ? Map<String, dynamic>.from(data['user'] as Map)
          : null,
      raw: json,
      requiresOtp: requiresOtp && (accessToken == null || accessToken.isEmpty),
      otpChallenge: requiresOtp
          ? OtpChallenge.fromJson({...root, ...data})
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'user': user,
      'requiresOtp': requiresOtp,
      'raw': raw,
    };
  }

  AuthSession copyWith({
    String? accessToken,
    String? refreshToken,
    Map<String, dynamic>? user,
    Object? raw,
    bool? requiresOtp,
    OtpChallenge? otpChallenge,
  }) {
    return AuthSession(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      user: user ?? this.user,
      raw: raw ?? this.raw,
      requiresOtp: requiresOtp ?? this.requiresOtp,
      otpChallenge: otpChallenge ?? this.otpChallenge,
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

String? _readString(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value != null && value.toString().trim().isNotEmpty) {
      return value.toString().trim();
    }
  }
  return null;
}

int _readInt(Map<String, dynamic> json, List<String> keys, int fallback) {
  for (final key in keys) {
    final value = json[key];
    if (value is num) return value.toInt();
    if (value is String) {
      final parsed = int.tryParse(value);
      if (parsed != null) return parsed;
    }
  }
  return fallback;
}
