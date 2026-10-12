import '../../../core/database/app_database.dart';
import '../../../core/database/tables.dart';
import 'savings_goal.dart';

class SavingsRepository {
  SavingsRepository(this._appDb, this._userId);

  final AppDatabase _appDb;
  final int _userId;

  /// The main jar (first goal). The schema allows several goals later.
  Future<SavingsGoal?> getMainGoal() async {
    final db = await _appDb.database;
    final rows = await db.query(
      SavingsGoalsTable.table,
      where: '${SavingsGoalsTable.userId} = ?',
      whereArgs: [_userId],
      orderBy: SavingsGoalsTable.id,
      limit: 1,
    );
    return rows.isEmpty ? null : SavingsGoal.fromMap(rows.first);
  }

  /// Done in SQL (`current_amount = current_amount + ?`) so the addition is
  /// atomic and can't use a stale value from memory.
  Future<void> addContribution(int goalId, double amount) async {
    final db = await _appDb.database;
    await db.rawUpdate(
      'UPDATE ${SavingsGoalsTable.table} '
      'SET ${SavingsGoalsTable.currentAmount} = '
      '${SavingsGoalsTable.currentAmount} + ? '
      'WHERE ${SavingsGoalsTable.id} = ? '
      'AND ${SavingsGoalsTable.userId} = ?',
      [amount, goalId, _userId],
    );
  }

  Future<void> updateTarget(int goalId, double target) async {
    final db = await _appDb.database;
    await db.update(
      SavingsGoalsTable.table,
      {SavingsGoalsTable.targetAmount: target},
      where: '${SavingsGoalsTable.id} = ? AND ${SavingsGoalsTable.userId} = ?',
      whereArgs: [goalId, _userId],
    );
  }
}
