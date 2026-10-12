import 'package:flutter/foundation.dart';

import '../data/budget.dart';
import '../data/budget_repository.dart';

class BudgetProvider extends ChangeNotifier {
  BudgetProvider(this._repository);

  final BudgetRepository _repository;

  List<Budget> _budgets = const [];

  Budget? get overall => _budgets.where((b) => b.category == null).firstOrNull;

  double get overallAmount => overall?.amount ?? 0;

  List<Budget> get categoryBudgets =>
      _budgets.where((b) => b.category != null).toList();

  Future<void> load() async {
    _budgets = await _repository.getAll();
    notifyListeners();
  }

  Future<void> updateAmount(Budget budget, double amount) async {
    await _repository.updateAmount(budget.id, amount);
    await load();
  }
}
