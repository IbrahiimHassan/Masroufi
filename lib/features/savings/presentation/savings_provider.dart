import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/savings_goal.dart';
import '../data/savings_repository.dart';

class SavingsProvider extends ChangeNotifier {
  SavingsProvider(this._repository);

  final SavingsRepository _repository;
  StreamSubscription<SavingsGoal?>? _subscription;

  SavingsGoal? _goal;
  SavingsGoal? get goal => _goal;

  void listen() {
    _subscription ??= _repository.watchMainGoal().listen((goal) {
      _goal = goal;
      notifyListeners();
    }, onError: (Object e) => debugPrint('Savings stream failed: $e'));
  }

  void addContribution(double amount) {
    final goal = _goal;
    if (goal == null) return;
    _repository.addContribution(goal.id, amount);
  }

  void updateTarget(double target) {
    final goal = _goal;
    if (goal == null) return;
    _repository.updateTarget(goal.id, target);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
