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

  UserRole get role => _role;
  AuthSession? get session => _session;
  bool get isAuthenticated => _session?.accessToken?.isNotEmpty ?? false;
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

  Future<ApiResponse<AuthSession>?> login({
    required String email,
    required String password,
    UserRole? expectedRole,
  }) async {
    _loginValidationError = null;
    final response = await runApiRequest(
      () => _repository.login(LoginRequest(email: email, password: password)),
    );
    _session = response?.data;
    final authenticatedRole = _roleFromSession();
    if (authenticatedRole != null &&
        expectedRole != null &&
        authenticatedRole != expectedRole) {
      await _repository.clearSession();
      _session = null;
      _role = expectedRole;
      _loginValidationError =
          'These credentials belong to ${_roleLabel(authenticatedRole)}. '
          'Please select ${_roleLabel(authenticatedRole)} and try again.';
      notifyListeners();
      return null;
    }
    if (authenticatedRole != null) {
      _role = authenticatedRole;
      await _repository.saveRole(_role.name);
    }
    notifyListeners();
    return response;
  }

  Future<ApiResponse<AuthSession>?> refreshSession() async {
    final response = await runApiRequest(_repository.refresh);
    _session = response?.data;
    if (_syncRoleFromSession()) {
      await _repository.saveRole(_role.name);
    }
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

  String _roleLabel(UserRole role) {
    switch (role) {
      case UserRole.owner:
        return 'Owner';
      case UserRole.telecaller:
        return 'Telecaller';
      case UserRole.fieldExecutive:
        return 'Field Executive';
    }
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
    notifyListeners();
  }
}
