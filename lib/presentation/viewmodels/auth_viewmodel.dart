import 'package:flutter/foundation.dart';

import '../../core/session/session_manager.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository repository;
  final SessionManager session;

  bool _isLoading = false;
  String? _error;

  AuthViewModel({required this.repository, required this.session});

  bool get isLoading => _isLoading;
  String? get error => _error;
  User? get user => session.user;
  bool get isAuthenticated => session.isAuthenticated;

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final loggedUser = await repository.login(username, password);
      session.saveSession(loggedUser);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Falha no login. Verifique usuário e senha.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void logout() {
    session.clearSession();
    notifyListeners();
  }
}
