import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/app_user.dart';
import '../data/auth_repository.dart';

/// Who is signed in. The session (just the user id) is kept in
/// SharedPreferences so the user stays logged in after closing the app.
class AuthProvider extends ChangeNotifier {
  AuthProvider(this._repository, this._prefs);

  static const _sessionKey = 'session_user_id';

  final AuthRepository _repository;
  final SharedPreferences _prefs;

  AppUser? _user;
  bool _isRestoring = true;

  AppUser? get user => _user;
  bool get isLoggedIn => _user != null;

  /// True until the saved session has been checked (show a splash).
  bool get isRestoring => _isRestoring;

  Future<void> restoreSession() async {
    try {
      final id = _prefs.getInt(_sessionKey);
      if (id != null) {
        final user = await _repository.getById(id);
        if (user != null) {
          _user = user;
        } else {
          await _prefs.remove(_sessionKey);
        }
      }
    } finally {
      _isRestoring = false;
      notifyListeners();
    }
  }

  /// Throws [AuthException] with a user-friendly message on failure.
  Future<void> login({required String email, required String password}) async {
    final user = await _repository.login(email, password);
    await _startSession(user);
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    double monthlyIncome = 0,
    int paydayDay = 1,
  }) async {
    final user = await _repository.register(
      name: name,
      email: email,
      password: password,
      monthlyIncome: monthlyIncome,
      paydayDay: paydayDay,
    );
    await _startSession(user);
  }

  Future<void> logout() async {
    await _prefs.remove(_sessionKey);
    _user = null;
    notifyListeners();
  }

  Future<void> updateProfile({
    String? name,
    double? monthlyIncome,
    int? paydayDay,
  }) async {
    final current = _user;
    if (current == null) return;
    _user = await _repository.updateProfile(
      current.id,
      name: name,
      monthlyIncome: monthlyIncome,
      paydayDay: paydayDay,
    );
    notifyListeners();
  }

  Future<void> _startSession(AppUser user) async {
    await _prefs.setInt(_sessionKey, user.id);
    _user = user;
    notifyListeners();
  }
}
