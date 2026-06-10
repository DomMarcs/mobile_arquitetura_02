import '../../domain/entities/user.dart';

class SessionManager {
  User? _user;

  User? get user => _user;
  bool get isAuthenticated => _user != null;

  void saveSession(User user) {
    _user = user;
  }

  void clearSession() {
    _user = null;
  }
}
