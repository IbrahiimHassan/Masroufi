import '../../../core/database/tables.dart';

/// The signed-in account (never contains the password hash).
class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.defaultCurrency,
    required this.monthlyIncome,
    required this.paydayDay,
  });

  final int id;
  final String name;
  final String email;
  final String defaultCurrency;
  final double monthlyIncome;

  /// Day of month (1–31) the salary arrives.
  final int paydayDay;

  factory AppUser.fromMap(Map<String, Object?> map) => AppUser(
    id: map[UsersTable.id] as int,
    name: map[UsersTable.name] as String,
    email: (map[UsersTable.email] as String?) ?? '',
    defaultCurrency: map[UsersTable.defaultCurrency] as String,
    monthlyIncome: (map[UsersTable.monthlyIncome] as num).toDouble(),
    paydayDay: map[UsersTable.paydayDay] as int,
  );
}
