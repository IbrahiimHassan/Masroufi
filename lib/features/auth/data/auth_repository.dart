import 'package:sqflite/sqflite.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/tables.dart';
import 'app_user.dart';
import 'password_hasher.dart';

enum AuthError { invalidCredentials, emailTaken }

/// A problem the user can fix. It carries a code, not text, so the screen can
/// show it in the user's language.
class AuthException implements Exception {
  const AuthException(this.error);
  final AuthError error;

  @override
  String toString() => 'AuthException($error)';
}

class AuthRepository {
  AuthRepository(this._appDb);

  final AppDatabase _appDb;

  static const _badLogin = AuthException(AuthError.invalidCredentials);

  Future<AppUser?> getById(int id) async {
    final db = await _appDb.database;
    final rows = await db.query(
      UsersTable.table,
      where: '${UsersTable.id} = ?',
      whereArgs: [id],
      limit: 1,
    );
    return rows.isEmpty ? null : AppUser.fromMap(rows.first);
  }

  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
    double monthlyIncome = 0,
    int paydayDay = 1,
  }) async {
    final db = await _appDb.database;
    final normalizedEmail = email.trim().toLowerCase();
    final salt = PasswordHasher.generateSalt();
    final hash = PasswordHasher.hash(password, salt);
    final now = DateTime.now().millisecondsSinceEpoch;

    try {
      // One transaction: either the account AND its starter data are created,
      // or nothing is.
      final id = await db.transaction<int>((txn) async {
        final existing = await txn.query(
          UsersTable.table,
          columns: [UsersTable.id],
          where: '${UsersTable.email} = ?',
          whereArgs: [normalizedEmail],
          limit: 1,
        );
        if (existing.isNotEmpty) {
          throw const AuthException(AuthError.emailTaken);
        }

        final userId = await txn.insert(UsersTable.table, {
          UsersTable.name: name.trim(),
          UsersTable.email: normalizedEmail,
          UsersTable.passwordHash: hash,
          UsersTable.passwordSalt: salt,
          UsersTable.defaultCurrency: 'EGP',
          UsersTable.monthlyIncome: monthlyIncome,
          UsersTable.paydayDay: paydayDay,
          UsersTable.createdAt: now,
        });
        await _seedUserData(txn, userId, monthlyIncome, now);
        return userId;
      });
      return (await getById(id))!;
    } on DatabaseException catch (e) {
      if (e.isUniqueConstraintError()) {
        throw const AuthException(AuthError.emailTaken);
      }
      rethrow;
    }
  }

  Future<AppUser> login(String email, String password) async {
    final db = await _appDb.database;
    final rows = await db.query(
      UsersTable.table,
      where: '${UsersTable.email} = ?',
      whereArgs: [email.trim().toLowerCase()],
      limit: 1,
    );
    if (rows.isEmpty) throw _badLogin;

    final row = rows.first;
    final hash = row[UsersTable.passwordHash] as String?;
    final salt = row[UsersTable.passwordSalt] as String?;
    if (hash == null ||
        salt == null ||
        !PasswordHasher.verify(password, salt, hash)) {
      throw _badLogin;
    }
    return AppUser.fromMap(row);
  }

  Future<AppUser> updateProfile(
    int userId, {
    String? name,
    double? monthlyIncome,
    int? paydayDay,
  }) async {
    final db = await _appDb.database;
    final values = <String, Object?>{
      if (name != null) UsersTable.name: name,
      if (monthlyIncome != null) UsersTable.monthlyIncome: monthlyIncome,
      if (paydayDay != null) UsersTable.paydayDay: paydayDay,
    };
    if (values.isNotEmpty) {
      await db.update(
        UsersTable.table,
        values,
        where: '${UsersTable.id} = ?',
        whereArgs: [userId],
      );
    }
    return (await getById(userId))!;
  }

  /// Starter budgets + savings jar for a brand-new account.
  /// With an income, the budget is split across the default categories;
  /// without one everything starts at 0 and the user sets limits by tapping.
  Future<void> _seedUserData(
    Transaction txn,
    int userId,
    double income,
    int now,
  ) async {
    final batch = txn.batch();

    batch.insert(BudgetsTable.table, {
      BudgetsTable.userId: userId,
      BudgetsTable.categoryId: null,
      BudgetsTable.amount: income,
    });

    // (categoryId, share of the monthly budget) — shares add up to 100%.
    const shares = [
      (5, 0.25), // Groceries
      (1, 0.19), // Transport
      (2, 0.22), // Bills
      (3, 0.19), // Shopping
      (4, 0.10), // Entertainment
      (6, 0.05), // Other
    ];
    for (final (categoryId, share) in shares) {
      batch.insert(BudgetsTable.table, {
        BudgetsTable.userId: userId,
        BudgetsTable.categoryId: categoryId,
        BudgetsTable.amount: (income * share).roundToDouble(),
      });
    }

    batch.insert(SavingsGoalsTable.table, {
      SavingsGoalsTable.userId: userId,
      SavingsGoalsTable.name: 'Savings jar',
      SavingsGoalsTable.targetAmount: income > 0 ? income : 1000.0,
      SavingsGoalsTable.currentAmount: 0.0,
      SavingsGoalsTable.monthlyContribution: 0.0,
      SavingsGoalsTable.jarCharacter: 'hamster',
      SavingsGoalsTable.createdAt: now,
    });

    await batch.commit(noResult: true);
  }
}
