import 'package:flutter/foundation.dart';

enum UserRole { owner, telecaller, fieldExecutive }

class AuthProvider extends ChangeNotifier {
  UserRole _role = UserRole.owner;

  UserRole get role => _role;

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
}
