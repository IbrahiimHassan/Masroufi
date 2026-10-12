import '../../../core/database/tables.dart';
import '../../categories/data/category.dart';

class Budget {
  const Budget({required this.id, required this.amount, this.category});

  final int id;
  final double amount;

  /// null = the overall monthly budget.
  final Category? category;

  factory Budget.fromMap(Map<String, Object?> map) {
    final categoryId = map[BudgetsTable.categoryId] as int?;
    return Budget(
      id: map[BudgetsTable.id] as int,
      amount: (map[BudgetsTable.amount] as num).toDouble(),
      category: categoryId == null
          ? null
          : Category.fromJoinedMap(map, id: categoryId),
    );
  }
}
