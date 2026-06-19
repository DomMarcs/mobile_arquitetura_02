import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/user.dart';

class SessionManager {
  static const String _sessionKey = 'user_session';
  User? _user;

  User? get user => _user;
  bool get isAuthenticated => _user != null;

  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_sessionKey);
      if (userJson != null) {
        final Map<String, dynamic> userMap = jsonDecode(userJson) as Map<String, dynamic>;
        _user = User.fromJson(userMap);
      }
    } catch (_) {
      // Fail silently and keep _user as null
    }
  }

  Future<void> saveSession(User user) async {
    _user = user;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_sessionKey, jsonEncode(user.toJson()));
    } catch (_) {
      // Fail silently
    }
  }

  Future<void> clearSession() async {
    _user = null;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_sessionKey);
    } catch (_) {
      // Fail silently
    }
  }
}
