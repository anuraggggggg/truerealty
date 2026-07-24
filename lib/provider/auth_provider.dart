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

  UserRole get role => _role;
  AuthSession? get session => _session;
  bool get isAuthenticated => _session?.accessToken?.isNotEmpty ?? false;

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
  }) async {
    final response = await runApiRequest(
      () => _repository.login(LoginRequest(email: email, password: password)),
    );
    _session = response?.data;
    return response;
  }

  Future<ApiResponse<AuthSession>?> refreshSession() async {
    final response = await runApiRequest(_repository.refresh);
    _session = response?.data;
    return response;
  }

  Future<ApiResponse<dynamic>?> logout() async {
    final response = await runApiRequest(_repository.logout);
    _session = null;
    return response;
  }

  Future<void> loadSavedSession() async {
    final token = await _repository.getAccessToken();
    if (token == null || token.isEmpty) {
      return;
    }
    _session = AuthSession(accessToken: token);
    notifyListeners();
  }

  Future<void> clearSession() async {
    await _repository.clearSession();
    _session = null;
    notifyListeners();
  }
}
