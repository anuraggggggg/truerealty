import 'package:flutter_test/flutter_test.dart';
import 'package:truerealtycrm/data/models/api_response.dart';
import 'package:truerealtycrm/data/models/auth_models.dart';
import 'package:truerealtycrm/data/repositories/auth_repository.dart';
import 'package:truerealtycrm/provider/auth_provider.dart';

void main() {
  test('field executive API role selects the field dashboard role', () async {
    final provider = AuthProvider(
      repository: _FakeAuthRepository(
        const AuthSession(
          accessToken: 'token',
          user: {'role': 'Field Executive'},
        ),
      ),
    );

    await provider.login(email: 'field@example.com', password: 'password');

    expect(provider.role, UserRole.fieldExecutive);
    expect(provider.isAuthenticated, isTrue);
  });

  test('nested field-agent alias is normalized', () async {
    final provider = AuthProvider(
      repository: _FakeAuthRepository(
        const AuthSession(
          accessToken: 'token',
          raw: {
            'data': {
              'employee': {'user_role': 'field_agent'},
            },
          },
        ),
      ),
    );

    await provider.login(email: 'field@example.com', password: 'password');

    expect(provider.role, UserRole.fieldExecutive);
  });

  test('SALES_AGENT is treated as a field executive', () async {
    final provider = AuthProvider(
      repository: _FakeAuthRepository(
        const AuthSession(accessToken: 'token', user: {'role': 'SALES_AGENT'}),
      ),
    );

    await provider.login(email: 'field@example.com', password: 'password');

    expect(provider.role, UserRole.fieldExecutive);
  });

  test('backend OTP challenge does not authenticate until verify', () async {
    final repository = _FakeAuthRepository(
      AuthSession(
        requiresOtp: true,
        otpChallenge: const OtpChallenge(
          identifier: 'telecaller@gmail.com',
          deliveryTarget: 'registered phone ending 9748',
          expiresInSeconds: 300,
          resendAfterSeconds: 60,
        ),
      ),
      verifySession: const AuthSession(
        accessToken: 'verified-token',
        user: {'role': 'telecaller'},
      ),
    );
    final provider = AuthProvider(repository: repository);

    final loginResponse = await provider.login(
      email: 'telecaller@gmail.com',
      password: 'password',
    );

    expect(loginResponse, isNotNull);
    expect(provider.requiresOtp, isTrue);
    expect(provider.isAuthenticated, isFalse);
    expect(provider.otpChallenge?.deliveryTarget, contains('9748'));

    final verifyResponse = await provider.verifyOtp(otp: '123456');

    expect(verifyResponse, isNotNull);
    expect(provider.isAuthenticated, isTrue);
    expect(provider.requiresOtp, isFalse);
    expect(provider.role, UserRole.telecaller);
  });

  test('mobile identifier is sent as mobile login', () async {
    final repository = _FakeAuthRepository(
      const AuthSession(accessToken: 'token', user: {'role': 'telecaller'}),
    );
    final provider = AuthProvider(repository: repository);

    await provider.login(mobile: '9876543210', password: 'password');

    expect(repository.lastLoginRequest?.mobile, '9876543210');
    expect(repository.lastLoginRequest?.email, isNull);
    expect(provider.isAuthenticated, isTrue);
  });

  test('API module permissions hide forbidden employee access', () async {
    final provider = AuthProvider(
      repository: _FakeAuthRepository(
        const AuthSession(
          accessToken: 'token',
          user: {
            'role': 'SALES_AGENT',
            'permissions': [
              {'moduleKey': 'leads', 'canView': true},
              {'moduleKey': 'employees', 'canView': false},
              {'moduleKey': 'teams', 'canView': false},
            ],
          },
        ),
      ),
    );

    await provider.login(email: 'field@example.com', password: 'password');

    expect(provider.canViewModule('leads'), isTrue);
    expect(provider.canViewModule('employees'), isFalse);
    expect(provider.canViewModule('teams'), isFalse);
  });

  test('demo role remains a fallback when API omits role', () async {
    final provider = AuthProvider(
      repository: _FakeAuthRepository(const AuthSession(accessToken: 'token')),
    )..setRole(UserRole.fieldExecutive);

    await provider.login(email: 'field@example.com', password: 'password');

    expect(provider.role, UserRole.fieldExecutive);
  });
}

class _FakeAuthRepository extends AuthRepository {
  _FakeAuthRepository(this.session, {this.verifySession});

  final AuthSession session;
  final AuthSession? verifySession;
  LoginRequest? lastLoginRequest;
  bool didClearSession = false;

  @override
  Future<ApiResponse<AuthSession>> login(LoginRequest request) async {
    lastLoginRequest = request;
    return ApiResponse(statusCode: 200, data: session);
  }

  @override
  Future<ApiResponse<AuthSession>> verifyOtp(VerifyOtpRequest request) async {
    return ApiResponse(
      statusCode: 200,
      data: verifySession ?? session,
    );
  }

  @override
  Future<ApiResponse<AuthSession>> resendOtp(LoginRequest request) {
    return login(request);
  }

  @override
  Future<void> saveRole(String role) async {}

  @override
  Future<void> clearSession() async {
    didClearSession = true;
  }
}
