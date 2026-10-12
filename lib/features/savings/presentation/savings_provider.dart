import 'package:flutter/foundation.dart';

import '../data/savings_goal.dart';
import '../data/savings_repository.dart';

class SavingsProvider extends ChangeNotifier {
  SavingsProvider(this._repository);

  final SavingsRepository _repository;

  SavingsGoal? _goal;
  SavingsGoal? get goal => _goal;

  Future<void> load() async {
    _goal = await _repository.getMainGoal();
    notifyListeners();
  }

  Future<void> addContribution(double amount) async {
    final goal = _goal;
    if (goal == null) return;
    await _repository.addContribution(goal.id, amount);
    await load();
  }

  Future<void> updateTarget(double target) async {
    final goal = _goal;
    if (goal == null) return;
    await _repository.updateTarget(goal.id, target);
    await load();
  }
}
