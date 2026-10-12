import '../../../core/database/tables.dart';

class UserProfile {
  const UserProfile({
    required this.id,
    required this.name,
    required this.defaultCurrency,
    required this.monthlyIncome,
    required this.paydayDay,
  });

  /// Shown for the split second before the database answers.
  const UserProfile.placeholder()
    : id = 1,
      name = '',
      defaultCurrency = 'EGP',
      monthlyIncome = 0,
      paydayDay = 1;

  final int id;
  final String name;
  final String defaultCurrency;
  final double monthlyIncome;

  /// Day of month (1–31) the salary arrives.
  final int paydayDay;

  factory UserProfile.fromMap(Map<String, Object?> map) => UserProfile(
    id: map[UsersTable.id] as int,
    name: map[UsersTable.name] as String,
    defaultCurrency: map[UsersTable.defaultCurrency] as String,
    monthlyIncome: (map[UsersTable.monthlyIncome] as num).toDouble(),
    paydayDay: map[UsersTable.paydayDay] as int,
  );
}
