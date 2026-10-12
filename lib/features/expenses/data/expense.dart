import 'package:flutter/material.dart';

import '../../../core/database/tables.dart';
import '../../categories/data/category.dart';

class Expense {
  const Expense({
    this.id,
    required this.title,
    required this.category,
    required this.merchant,
    required this.amount,
    required this.date,
  });

  /// null until the row has been inserted.
  final int? id;
  final String title;
  final Category category;
  final String merchant;
  final double amount;
  final DateTime date;

  Color get color => category.color;
  IconData get icon => category.icon;

  /// Reads a row produced by ExpenseRepository's JOIN query.
  factory Expense.fromMap(Map<String, Object?> map) {
    final categoryId = map[ExpensesTable.categoryId] as int;
    return Expense(
      id: map[ExpensesTable.id] as int,
      title: map[ExpensesTable.title] as String,
      merchant: (map[ExpensesTable.merchant] as String?) ?? '',
      amount: (map[ExpensesTable.amount] as num).toDouble(),
      date: DateTime.fromMillisecondsSinceEpoch(
        map[ExpensesTable.expenseDate] as int,
      ),
      category: Category.fromJoinedMap(map, id: categoryId),
    );
  }

  /// Only the columns that belong to the expenses table.
  /// (user_id / created_at / updated_at are added by the repository.)
  Map<String, Object?> toMap() => {
    if (id != null) ExpensesTable.id: id,
    ExpensesTable.categoryId: category.id,
    ExpensesTable.title: title,
    ExpensesTable.merchant: merchant,
    ExpensesTable.amount: amount,
    ExpensesTable.expenseDate: date.millisecondsSinceEpoch,
  };
}
