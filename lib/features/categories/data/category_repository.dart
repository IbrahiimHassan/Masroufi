import '../../../core/database/app_database.dart';
import '../../../core/database/tables.dart';
import 'category.dart';

class CategoryRepository {
  CategoryRepository(this._appDb, this._userId);

  final AppDatabase _appDb;
  final int _userId;

  /// Default categories (user_id IS NULL) + this user's custom ones.
  Future<List<Category>> getAll() async {
    final db = await _appDb.database;
    final rows = await db.query(
      CategoriesTable.table,
      where:
          '${CategoriesTable.userId} IS NULL OR ${CategoriesTable.userId} = ?',
      whereArgs: [_userId],
      orderBy: CategoriesTable.id,
    );
    return rows.map(Category.fromMap).toList();
  }
}
