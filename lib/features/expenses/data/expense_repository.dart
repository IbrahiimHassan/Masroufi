import '../../../core/database/app_database.dart';
import '../../../core/database/tables.dart';
import '../../categories/data/category.dart';
import 'expense.dart';

/// All SQL for expenses lives here — the UI never touches the database.
/// Every query is scoped to [_userId], so accounts never see each other's data.
class ExpenseRepository {
  ExpenseRepository(this._appDb, this._userId);

  final AppDatabase _appDb;
  final int _userId;

  static const _selectWithCategory =
      '''
    SELECT e.*, ${Category.joinColumns}
    FROM ${ExpensesTable.table} e
    JOIN ${CategoriesTable.table} c
      ON c.${CategoriesTable.id} = e.${ExpensesTable.categoryId}
  ''';

  Future<List<Expense>> getAll() async {
    final db = await _appDb.database;
    final rows = await db.rawQuery(
      '$_selectWithCategory '
      'WHERE e.${ExpensesTable.userId} = ? '
      'ORDER BY e.${ExpensesTable.expenseDate} DESC, e.${ExpensesTable.id} DESC',
      [_userId],
    );
    return rows.map(Expense.fromMap).toList();
  }

  Future<int> add(Expense expense) async {
    final db = await _appDb.database;
    final now = DateTime.now().millisecondsSinceEpoch;
    return db.insert(ExpensesTable.table, {
      ...expense.toMap(),
      ExpensesTable.userId: _userId,
      ExpensesTable.createdAt: now,
      ExpensesTable.updatedAt: now,
    });
  }

  Future<void> update(Expense expense) async {
    final db = await _appDb.database;
    await db.update(
      ExpensesTable.table,
      {
        ...expense.toMap(),
        ExpensesTable.updatedAt: DateTime.now().millisecondsSinceEpoch,
      },
      where: '${ExpensesTable.id} = ? AND ${ExpensesTable.userId} = ?',
      whereArgs: [expense.id, _userId],
    );
  }

  Future<void> delete(int id) async {
    final db = await _appDb.database;
    await db.delete(
      ExpensesTable.table,
      where: '${ExpensesTable.id} = ? AND ${ExpensesTable.userId} = ?',
      whereArgs: [id, _userId],
    );
  }
}
