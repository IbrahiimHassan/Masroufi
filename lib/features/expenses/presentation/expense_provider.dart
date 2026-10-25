import 'dart:async';

import 'package:flutter/foundation.dart' hide Category;

import '../../../core/firebase/firestore_cache.dart';
import '../../../core/firebase/sync_status.dart';
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

class ExpenseProvider extends ChangeNotifier with SyncStatus {
  ExpenseProvider(this._repository);

  final ExpenseRepository _repository;
  StreamSubscription<Synced<List<Expense>>>? _subscription;

  List<Expense> _expenses = const [];
  bool _isLoading = true;

  /// Newest first.
  List<Expense> get expenses => _expenses;
  bool get isLoading => _isLoading;

  // ───────── Firestore ─────────

  /// Starts listening. Adds, edits and deletes (from this device or another)
  /// arrive through the stream, so nothing has to reload by hand.
  void listen() {
    _subscription ??= _repository.watchAll().listen(
      (snapshot) {
        _setExpenses(snapshot.data);
        updateSyncStatus(snapshot);
        _isLoading = false;
        notifyListeners();
      },
      onError: (Object e) {
        debugPrint('Expenses stream failed: $e');
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  void add(Expense expense) => _repository.add(expense);

  void edit(Expense expense) => _repository.update(expense);

  /// Removes from the list first so a swiped Dismissible leaves the tree
  /// immediately; the stream then confirms the delete.
  void remove(String id) {
    _setExpenses(_expenses.where((e) => e.id != id).toList());
    notifyListeners();
    _repository.delete(id);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  // ───────── derived numbers ─────────

  /// Month totals are asked for many times per frame (dashboard, budget,
  /// reports, the 12-month trend), so they are cached until the list changes.
  final _monthTotalCache = <int, double>{};

  void _setExpenses(List<Expense> expenses) {
    _expenses = expenses;
    _monthTotalCache.clear();
  }

  Iterable<Expense> _inMonth(DateTime month) => _expenses.where(
    (e) => e.date.year == month.year && e.date.month == month.month,
  );

  double _sum(Iterable<Expense> items) =>
      items.fold<double>(0, (sum, e) => sum + e.amount);

  double spentInMonth(DateTime month) => _monthTotalCache.putIfAbsent(
    month.year * 12 + month.month,
    () => _sum(_inMonth(month)),
  );

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
  Map<String, double> spentByCategoryInMonth(DateTime month) {
    final totals = <String, double>{};
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
