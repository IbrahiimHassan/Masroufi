import '../../../core/database/app_database.dart';
import '../../../core/database/tables.dart';
import '../../categories/data/category.dart';
import 'budget.dart';

class BudgetRepository {
  BudgetRepository(this._appDb, this._userId);

  final AppDatabase _appDb;
  final int _userId;

  Future<List<Budget>> getAll() async {
    final db = await _appDb.database;
    final rows = await db.rawQuery(
      '''
      SELECT b.*, ${Category.joinColumns}
      FROM ${BudgetsTable.table} b
      LEFT JOIN ${CategoriesTable.table} c
        ON c.${CategoriesTable.id} = b.${BudgetsTable.categoryId}
      WHERE b.${BudgetsTable.userId} = ?
      ORDER BY b.${BudgetsTable.id}
    ''',
      [_userId],
    );
    return rows.map(Budget.fromMap).toList();
  }

  Future<void> updateAmount(int id, double amount) async {
    final db = await _appDb.database;
    await db.update(
      BudgetsTable.table,
      {BudgetsTable.amount: amount},
      where: '${BudgetsTable.id} = ? AND ${BudgetsTable.userId} = ?',
      whereArgs: [id, _userId],
    );
  }
}
