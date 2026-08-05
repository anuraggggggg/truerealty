import 'package:truerealtycrm/data/models/api_response.dart';
import 'package:truerealtycrm/data/models/auth_models.dart';
import 'package:truerealtycrm/data/repositories/auth_repository.dart';
import 'package:truerealtycrm/provider/api_provider_base.dart';

enum UserRole { owner, telecaller, fieldExecutive }

class AuthProvider extends ApiProviderBase {
  AuthProvider({AuthRepository? repository})
    : _repository = repository ?? AuthRepository();

  final AuthRepository _repository;
  UserRole _role = UserRole.telecaller;
  AuthSession? _session;
  String? _loginValidationError;
  OtpChallenge? _otpChallenge;
  LoginRequest? _pendingLoginRequest;

  UserRole get role => _role;
  AuthSession? get session => _session;
  OtpChallenge? get otpChallenge => _otpChallenge;
  bool get isAuthenticated => _session?.hasTokens ?? false;
  bool get requiresOtp => _otpChallenge != null;
  String? get loginError => _loginValidationError ?? error;

  bool canViewModule(String moduleKey) {
    final normalizedModuleKey = moduleKey.trim().toLowerCase();
    final permissions = _session?.user?['permissions'];
    if (permissions is List) {
      for (final permission in permissions) {
        if (permission is! Map) continue;
        final key = permission['moduleKey']?.toString().trim().toLowerCase();
        if (key == normalizedModuleKey) {
          return permission['canView'] == true;
        }
      }
      return false;
    }

    // A restored token does not currently contain its permission payload.
    // Keep restricted administration modules hidden for field executives.
    if (_role == UserRole.fieldExecutive &&
        const {
          'employees',
          'teams',
          'lead_masters',
        }.contains(normalizedModuleKey)) {
      return false;
    }
    return true;
  }

  String get roleName {
    switch (_role) {
      case UserRole.owner:
        return 'Owner';
      case UserRole.telecaller:
        return 'Telecaller';
      case UserRole.fieldExecutive:
        return 'Field Executive';
    }
  }

  void setRole(UserRole newRole) {
    _role = newRole;
    notifyListeners();
  }

  /// Login with email+password or mobile+password.
  /// Backend decides whether OTP is required.
  Future<ApiResponse<AuthSession>?> login({
    String? email,
    String? mobile,
    required String password,
  }) async {
    _loginValidationError = null;
    final identifier = (email ?? mobile ?? '').trim();
    if (identifier.isEmpty || password.isEmpty) {
      _loginValidationError = 'Please enter your email/mobile and password.';
      notifyListeners();
      return null;
    }

    final request = _buildLoginRequest(
      identifier: identifier,
      password: password,
    );

    final response = await runApiRequest(() => _repository.login(request));
    final session = response?.data;
    if (session == null) {
      notifyListeners();
      return null;
    }

    if (session.requiresOtp) {
      _pendingLoginRequest = request;
      _otpChallenge = session.otpChallenge ??
          OtpChallenge(
            identifier: request.email ?? request.mobile ?? identifier,
            deliveryTarget: 'your registered phone',
            expiresInSeconds: 300,
            resendAfterSeconds: 60,
            message: response?.message,
          );
      _session = null;
      notifyListeners();
      return response;
    }

    await _completeAuthenticatedSession(session);
    return response;
  }

  Future<ApiResponse<AuthSession>?> verifyOtp({required String otp}) async {
    _loginValidationError = null;
    final challenge = _otpChallenge;
    final identifier = challenge?.identifier.trim() ?? '';
    if (identifier.isEmpty) {
      _loginValidationError = 'OTP session expired. Please login again.';
      notifyListeners();
      return null;
    }
    if (otp.trim().length != 6) {
      _loginValidationError = 'Please enter the 6-digit OTP.';
      notifyListeners();
      return null;
    }

    final response = await runApiRequest(
      () => _repository.verifyOtp(
        VerifyOtpRequest(identifier: identifier, otp: otp.trim()),
      ),
    );
    final session = response?.data;
    if (session == null || !session.hasTokens) {
      notifyListeners();
      return null;
    }

    _otpChallenge = null;
    _pendingLoginRequest = null;
    await _completeAuthenticatedSession(session);
    return response;
  }

  Future<ApiResponse<AuthSession>?> resendOtp() async {
    _loginValidationError = null;
    final pending = _pendingLoginRequest;
    if (pending == null) {
      _loginValidationError = 'OTP session expired. Please login again.';
      notifyListeners();
      return null;
    }

    final response = await runApiRequest(() => _repository.resendOtp(pending));
    final session = response?.data;
    if (session == null) {
      notifyListeners();
      return null;
    }

    if (session.requiresOtp) {
      _otpChallenge = session.otpChallenge ??
          OtpChallenge(
            identifier: pending.email ?? pending.mobile ?? '',
            deliveryTarget:
                _otpChallenge?.deliveryTarget ?? 'your registered phone',
            expiresInSeconds: 300,
            resendAfterSeconds: 60,
            message: response?.message,
          );
      notifyListeners();
      return response;
    }

    // Rare case: backend issues tokens on resend/login.
    if (session.hasTokens) {
      _otpChallenge = null;
      _pendingLoginRequest = null;
      await _completeAuthenticatedSession(session);
    }
    return response;
  }

  void clearOtpChallenge() {
    _otpChallenge = null;
    _pendingLoginRequest = null;
    _loginValidationError = null;
    notifyListeners();
  }

  LoginRequest _buildLoginRequest({
    required String identifier,
    required String password,
  }) {
    if (_looksLikeEmail(identifier)) {
      return LoginRequest(email: identifier, password: password);
    }
    return LoginRequest(
      mobile: identifier.replaceAll(RegExp(r'\s+'), ''),
      password: password,
    );
  }

  bool _looksLikeEmail(String value) {
    return value.contains('@');
  }

  Future<void> _completeAuthenticatedSession(AuthSession session) async {
    _session = session;
    final authenticatedRole = _roleFromSession();
    if (authenticatedRole != null) {
      _role = authenticatedRole;
      await _repository.saveRole(_role.name);
    }
    notifyListeners();
  }

  Future<ApiResponse<AuthSession>?> refreshSession() async {
    final response = await runApiRequest(_repository.refresh);
    _session = response?.data;
    if (_syncRoleFromSession()) {
      await _repository.saveRole(_role.name);
    }
    notifyListeners();
    return response;
  }

  bool _syncRoleFromSession() {
    final resolvedRole = _roleFromSession();
    if (resolvedRole != null) {
      _role = resolvedRole;
      return true;
    }
    return false;
  }

  UserRole? _roleFromSession() {
    final sessionRole = _findRole(_session?.user) ?? _findRole(_session?.raw);
    return _parseRole(sessionRole);
  }

  String? _findRole(Object? value, [int depth = 0]) {
    if (value == null || depth > 5) return null;
    if (value is Map) {
      const roleKeys = [
        'role',
        'roleName',
        'role_name',
        'userRole',
        'user_role',
        'employeeRole',
        'employee_role',
      ];
      for (final key in roleKeys) {
        final role = value[key];
        if (role is String && role.trim().isNotEmpty) return role;
        if (role is Map) {
          final name = role['name'] ?? role['title'] ?? role['slug'];
          if (name != null && name.toString().trim().isNotEmpty) {
            return name.toString();
          }
        }
      }
      for (final nestedKey in const [
        'user',
        'employee',
        'profile',
        'data',
        'result',
      ]) {
        final role = _findRole(value[nestedKey], depth + 1);
        if (role != null) return role;
      }
    }
    return null;
  }

  UserRole? _parseRole(String? value) {
    final normalized = value?.trim().toLowerCase().replaceAll(
      RegExp(r'[^a-z0-9]'),
      '',
    );
    switch (normalized) {
      case 'owner':
      case 'admin':
      case 'administrator':
        return UserRole.owner;
      case 'telecaller':
      case 'telecalling':
      case 'caller':
        return UserRole.telecaller;
      case 'fieldexecutive':
      case 'fieldagent':
      case 'salesagent':
      case 'salesexecutive':
      case 'executive':
        return UserRole.fieldExecutive;
      default:
        return null;
    }
  }

  Future<ApiResponse<dynamic>?> logout() async {
    final response = await runApiRequest(_repository.logout);
    _session = null;
    _otpChallenge = null;
    _pendingLoginRequest = null;
    notifyListeners();
    return response;
  }

  Future<void> loadSavedSession() async {
    final results = await Future.wait([
      _repository.getAccessToken(),
      _repository.getRole(),
    ]);
    final token = results[0];
    if (token == null || token.isEmpty) {
      return;
    }
    _role = _parseRole(results[1]) ?? _role;
    _session = AuthSession(accessToken: token);
    notifyListeners();
  }

  Future<void> clearSession() async {
    await _repository.clearSession();
    _session = null;
    _otpChallenge = null;
    _pendingLoginRequest = null;
    notifyListeners();
  }
}
