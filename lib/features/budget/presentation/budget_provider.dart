import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/budget.dart';
import '../data/budget_repository.dart';

class BudgetProvider extends ChangeNotifier {
  BudgetProvider(this._repository);

  final BudgetRepository _repository;
  StreamSubscription<List<Budget>>? _subscription;

  List<Budget> _budgets = const [];

  Budget? get overall => _budgets.where((b) => b.category == null).firstOrNull;

  double get overallAmount => overall?.amount ?? 0;

  List<Budget> get categoryBudgets =>
      _budgets.where((b) => b.category != null).toList();

  void listen() {
    _subscription ??= _repository.watchAll().listen((budgets) {
      _budgets = budgets;
      notifyListeners();
    }, onError: (Object e) => debugPrint('Budgets stream failed: $e'));
  }

  void updateAmount(Budget budget, double amount) =>
      _repository.updateAmount(budget.id, amount);

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
