import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/firebase/collections.dart';
import '../../../core/firebase/firestore_cache.dart';
import 'app_user.dart';
import 'user_seeder.dart';

enum AuthError {
  invalidCredentials,
  emailTaken,
  weakPassword,
  network,
  tooManyAttempts,
  unknown,
}

/// A problem the user can fix. It carries a code, not text, so the screen can
/// show it in the user's language.
class AuthException implements Exception {
  const AuthException(this.error);
  final AuthError error;

  @override
  String toString() => 'AuthException($error)';
}

/// Firebase Auth for sign-in, Firestore (users/{uid}) for the profile.
/// Firebase Auth also remembers the session, so the user stays logged in
/// after closing the app.
class AuthRepository {
  AuthRepository(this._auth, this._firestore);

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _profile(String uid) =>
      _firestore.collection(UsersCollection.name).doc(uid);

  /// The signed-in Firebase user, or null. Emits once at startup with the
  /// saved session (works offline).
  Stream<User?> authStateChanges() => _auth.authStateChanges();

  /// The profile document; null while it doesn't exist.
  Stream<Synced<AppUser?>> watchProfile(String uid) => _profile(uid)
      .snapshots()
      .map(
        (doc) => Synced(
          doc.exists ? AppUser.fromFirestore(doc) : null,
          doc.metadata,
        ),
      );

  Future<void> register({
    required String name,
    required String email,
    required String password,
    double monthlyIncome = 0,
    int paydayDay = 1,
  }) async {
    final credential = await _guard(
      () => _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      ),
    );
    final user = credential.user!;
    await user.updateDisplayName(name.trim());
    await UserSeeder(_firestore).seed(
      uid: user.uid,
      name: name,
      email: email,
      monthlyIncome: monthlyIncome,
      paydayDay: paydayDay,
    );
  }

  Future<void> login(String email, String password) async {
    final credential = await _guard(
      () => _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      ),
    );
    // Accounts created outside the app (e.g. in the Firebase console) have
    // no profile yet: give them the same starter data as a new sign-up.
    final user = credential.user!;
    final profile = await _profile(user.uid).get();
    if (!profile.exists) {
      await UserSeeder(_firestore).seed(
        uid: user.uid,
        name: user.displayName ?? user.email?.split('@').first ?? '',
        email: user.email ?? email,
      );
    }
  }

  Future<void> logout() => _auth.signOut();

  void updateProfile(
    String uid, {
    String? name,
    double? monthlyIncome,
    int? paydayDay,
  }) {
    final values = <String, Object?>{
      UsersCollection.displayName: ?name,
      UsersCollection.monthlyIncome: ?monthlyIncome,
      UsersCollection.paydayDay: ?paydayDay,
    };
    if (values.isEmpty) return;
    sendInBackground(_profile(uid).update(values));
  }

  /// Turns Firebase's error codes into the few cases the UI explains.
  static Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on FirebaseAuthException catch (e) {
      throw AuthException(switch (e.code) {
        'invalid-credential' ||
        'invalid-email' ||
        'user-not-found' ||
        'wrong-password' ||
        'user-disabled' => AuthError.invalidCredentials,
        'email-already-in-use' => AuthError.emailTaken,
        'weak-password' => AuthError.weakPassword,
        'network-request-failed' => AuthError.network,
        'too-many-requests' => AuthError.tooManyAttempts,
        _ => AuthError.unknown,
      });
    }
  }
}
