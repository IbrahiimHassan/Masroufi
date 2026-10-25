import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/firebase/collections.dart';

/// The signed-in account: the Firebase Auth uid plus the profile document
/// stored at users/{uid}. (Passwords are handled by Firebase Auth only.)
class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.defaultCurrency,
    required this.monthlyIncome,
    required this.paydayDay,
  });

  /// Used when the account exists but its profile hasn't been downloaded yet.
  const AppUser.placeholder({required this.id, this.name = '', this.email = ''})
    : defaultCurrency = 'EGP',
      monthlyIncome = 0,
      paydayDay = 1;

  /// Firebase Auth uid (also the id of the profile document).
  final String id;
  final String name;
  final String email;
  final String defaultCurrency;
  final double monthlyIncome;

  /// Day of month (1–31) the salary arrives.
  final int paydayDay;

  factory AppUser.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final map = doc.data()!;
    return AppUser(
      id: doc.id,
      name: map[UsersCollection.displayName] as String,
      email: (map[UsersCollection.email] as String?) ?? '',
      defaultCurrency:
          (map[UsersCollection.defaultCurrency] as String?) ?? 'EGP',
      monthlyIncome: (map[UsersCollection.monthlyIncome] as num).toDouble(),
      paydayDay: (map[UsersCollection.paydayDay] as num).toInt(),
    );
  }
}
