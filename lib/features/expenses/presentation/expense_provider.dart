import 'package:flutter/foundation.dart' hide Category;

import '../../../core/utils/formatters.dart';
import '../../categories/data/category.dart';
import '../data/expense.dart';
import '../data/expense_repository.dart';

class CategorySpend {
  const CategorySpend(this.category, this.total);
  final Category category;
  final double total;
}

class MonthTotal {
  const MonthTotal({required this.month, required this.amount});

  /// First day of the month.
  final DateTime month;
  final double amount;
}

class ExpenseProvider extends ChangeNotifier {
  ExpenseProvider(this._repository);

  final ExpenseRepository _repository;

  List<Expense> _expenses = const [];
  bool _isLoading = true;

  /// Newest first.
  List<Expense> get expenses => _expenses;
  bool get isLoading => _isLoading;

  // ───────── persistence ─────────

  Future<void> load() async {
    _expenses = await _repository.getAll();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> add(Expense expense) async {
    await _repository.add(expense);
    await load();
  }

  Future<void> edit(Expense expense) async {
    await _repository.update(expense);
    await load();
  }

  /// Removes from the list first so a swiped Dismissible leaves the tree
  /// immediately, then deletes from SQLite.
  Future<void> remove(int id) async {
    _expenses = _expenses.where((e) => e.id != id).toList();
    notifyListeners();
    await _repository.delete(id);
  }

  // ───────── derived numbers ─────────

  Iterable<Expense> _inMonth(DateTime month) => _expenses.where(
    (e) => e.date.year == month.year && e.date.month == month.month,
  );

  double _sum(Iterable<Expense> items) =>
      items.fold<double>(0, (sum, e) => sum + e.amount);

  double spentInMonth(DateTime month) => _sum(_inMonth(month));

  double spentOn(DateTime day) =>
      _sum(_expenses.where((e) => isSameDay(e.date, day)));

  double spentLast7Days(DateTime now) =>
      _sum(_expenses.where((e) => now.difference(e.date).inDays < 7));

  List<Expense> recent([int limit = 5]) => _expenses.take(limit).toList();

  /// First day of the month of the oldest expense (null when there are none).
  DateTime? get earliestMonth {
    if (_expenses.isEmpty) return null;
    final oldest = _expenses
        .map((e) => e.date)
        .reduce((a, b) => a.isBefore(b) ? a : b);
    return DateTime(oldest.year, oldest.month);
  }

  /// categoryId -> total spent in [month].
  Map<int, double> spentByCategoryInMonth(DateTime month) {
    final totals = <int, double>{};
    for (final e in _inMonth(month)) {
      totals.update(
        e.category.id!,
        (total) => total + e.amount,
        ifAbsent: () => e.amount,
      );
    }
    return totals;
  }

  /// Totals for [months] months ending at [end] (default: this month),
  /// oldest first.
  List<MonthTotal> monthlyTotals({int months = 6, DateTime? end}) {
    final anchor = end ?? DateTime.now();
    return List.generate(months, (index) {
      final month = DateTime(anchor.year, anchor.month - (months - 1) + index);
      return MonthTotal(month: month, amount: spentInMonth(month));
    });
  }
}
