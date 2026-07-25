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

  test('credential and selected designation mismatch rejects login', () async {
    final repository = _FakeAuthRepository(
      const AuthSession(accessToken: 'token', user: {'role': 'SALES_AGENT'}),
    );
    final provider = AuthProvider(repository: repository);

    final response = await provider.login(
      email: 'field@example.com',
      password: 'password',
      expectedRole: UserRole.telecaller,
    );

    expect(response, isNull);
    expect(provider.isAuthenticated, isFalse);
    expect(provider.role, UserRole.telecaller);
    expect(provider.loginError, contains('select Field Executive'));
    expect(repository.didClearSession, isTrue);
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
  _FakeAuthRepository(this.session);

  final AuthSession session;
  bool didClearSession = false;

  @override
  Future<ApiResponse<AuthSession>> login(LoginRequest request) async {
    return ApiResponse(statusCode: 200, data: session);
  }

  @override
  Future<void> saveRole(String role) async {}

  @override
  Future<void> clearSession() async {
    didClearSession = true;
  }
}
