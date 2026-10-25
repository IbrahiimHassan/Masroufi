import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/foundation.dart';

import '../../../core/firebase/firestore_cache.dart';
import '../data/app_user.dart';
import '../data/auth_repository.dart';

/// Who is signed in. Firebase Auth keeps the session on the device; the
/// profile (users/{uid}) is streamed so edits show up everywhere at once.
class AuthProvider extends ChangeNotifier {
  AuthProvider(this._repository);

  final AuthRepository _repository;

  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<Synced<AppUser?>>? _profileSubscription;

  AppUser? _user;
  bool _isRestoring = true;

  AppUser? get user => _user;
  bool get isLoggedIn => _user != null;

  /// True until the saved session has been checked (show a splash).
  bool get isRestoring => _isRestoring;

  void restoreSession() {
    _authSubscription ??= _repository.authStateChanges().listen(_onAuthChanged);
  }

  void _onAuthChanged(User? firebaseUser) {
    _profileSubscription?.cancel();
    _profileSubscription = null;

    if (firebaseUser == null) {
      _user = null;
      _isRestoring = false;
      notifyListeners();
      return;
    }

    _profileSubscription = _repository
        .watchProfile(firebaseUser.uid)
        .listen(
          (snapshot) {
            final profile = snapshot.data;
            // "Not in the cache" doesn't mean "doesn't exist": wait for the
            // server before falling back to a placeholder.
            if (profile == null && snapshot.isFromCache) return;
            _user =
                profile ??
                AppUser.placeholder(
                  id: firebaseUser.uid,
                  name: firebaseUser.displayName ?? '',
                  email: firebaseUser.email ?? '',
                );
            _isRestoring = false;
            notifyListeners();
          },
          onError: (Object e) {
            debugPrint('Profile stream failed: $e');
            _user = AppUser.placeholder(id: firebaseUser.uid);
            _isRestoring = false;
            notifyListeners();
          },
        );
  }

  /// Throws [AuthException] with a user-friendly code on failure.
  /// On success the auth stream signs the user in.
  Future<void> login({required String email, required String password}) =>
      _repository.login(email, password);

  Future<void> register({
    required String name,
    required String email,
    required String password,
    double monthlyIncome = 0,
    int paydayDay = 1,
  }) => _repository.register(
    name: name,
    email: email,
    password: password,
    monthlyIncome: monthlyIncome,
    paydayDay: paydayDay,
  );

  Future<void> logout() => _repository.logout();

  void updateProfile({String? name, double? monthlyIncome, int? paydayDay}) {
    final current = _user;
    if (current == null) return;
    _repository.updateProfile(
      current.id,
      name: name,
      monthlyIncome: monthlyIncome,
      paydayDay: paydayDay,
    );
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _profileSubscription?.cancel();
    super.dispose();
  }
}
