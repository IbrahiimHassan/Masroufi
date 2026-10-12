import '../../../core/database/app_database.dart';
import '../../../core/database/tables.dart';
import 'user_profile.dart';

/// MVP has a single local user (id = 1). When you add real accounts,
/// pass the signed-in user id in here.
class ProfileRepository {
  ProfileRepository(this._appDb);

  final AppDatabase _appDb;

  static const _localUserId = 1;

  Future<UserProfile?> get() async {
    final db = await _appDb.database;
    final rows = await db.query(
      UsersTable.table,
      where: '${UsersTable.id} = ?',
      whereArgs: [_localUserId],
      limit: 1,
    );
    return rows.isEmpty ? null : UserProfile.fromMap(rows.first);
  }

  Future<void> update({
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
    if (values.isEmpty) return;
    await db.update(
      UsersTable.table,
      values,
      where: '${UsersTable.id} = ?',
      whereArgs: [_localUserId],
    );
  }
}
