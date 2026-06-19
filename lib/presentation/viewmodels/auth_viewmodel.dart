import 'package:flutter/foundation.dart';

import '../../core/errors/failure.dart';
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
      await session.saveSession(loggedUser);
      _isLoading = false;
      notifyListeners();
      return true;
    } on AuthenticationException catch (_) {
      _error = 'Usuário ou senha inválidos. Verifique seus dados e tente novamente.';
    } on ServerException catch (_) {
      _error = 'Erro no servidor. Tente novamente mais tarde.';
    } on NetworkException catch (_) {
      _error = 'Problema de conexão. Confira sua internet e tente novamente.';
    } catch (_) {
      _error = 'Não foi possível efetuar o login. Tente novamente mais tarde.';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  void logout() {
    session.clearSession();
    notifyListeners();
  }
}
