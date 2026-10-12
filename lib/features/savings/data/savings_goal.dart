import '../../../core/database/tables.dart';

class SavingsGoal {
  const SavingsGoal({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    required this.monthlyContribution,
    required this.jarCharacter,
  });

  final int id;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final double monthlyContribution;
  final String jarCharacter;

  double get progress =>
      targetAmount <= 0 ? 0.0 : (currentAmount / targetAmount).clamp(0.0, 1.0);

  factory SavingsGoal.fromMap(Map<String, Object?> map) => SavingsGoal(
    id: map[SavingsGoalsTable.id] as int,
    name: map[SavingsGoalsTable.name] as String,
    targetAmount: (map[SavingsGoalsTable.targetAmount] as num).toDouble(),
    currentAmount: (map[SavingsGoalsTable.currentAmount] as num).toDouble(),
    monthlyContribution: (map[SavingsGoalsTable.monthlyContribution] as num)
        .toDouble(),
    jarCharacter: map[SavingsGoalsTable.jarCharacter] as String,
  );
}
