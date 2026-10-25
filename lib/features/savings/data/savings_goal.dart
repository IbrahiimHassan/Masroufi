import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/firebase/collections.dart';

class SavingsGoal {
  const SavingsGoal({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    required this.monthlyContribution,
    required this.jarCharacter,
  });

  final String id;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final double monthlyContribution;
  final String jarCharacter;

  double get progress =>
      targetAmount <= 0 ? 0.0 : (currentAmount / targetAmount).clamp(0.0, 1.0);

  factory SavingsGoal.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final map = doc.data()!;
    return SavingsGoal(
      id: doc.id,
      name: map[SavingsGoalsCollection.goalName] as String,
      targetAmount: (map[SavingsGoalsCollection.targetAmount] as num)
          .toDouble(),
      currentAmount: (map[SavingsGoalsCollection.currentAmount] as num)
          .toDouble(),
      monthlyContribution:
          (map[SavingsGoalsCollection.monthlyContribution] as num).toDouble(),
      jarCharacter: map[SavingsGoalsCollection.jarCharacter] as String,
    );
  }
}
