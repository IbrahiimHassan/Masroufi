import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/firebase/collections.dart';
import '../../categories/data/category.dart';
import '../../categories/data/default_categories.dart';

/// Creates the profile + starter budgets + savings jar for a brand-new
/// account in ONE batch: either all of it is written, or none of it.
class UserSeeder {
  UserSeeder(this._firestore);

  final FirebaseFirestore _firestore;

  /// (category, share of the monthly budget) — shares add up to 100%.
  static const budgetShares = <(Category, double)>[
    (DefaultCategories.groceries, 0.25),
    (DefaultCategories.transport, 0.19),
    (DefaultCategories.bills, 0.22),
    (DefaultCategories.shopping, 0.19),
    (DefaultCategories.entertainment, 0.10),
    (DefaultCategories.other, 0.05),
  ];

  /// With an income, the budget is split across the default categories;
  /// without one everything starts at 0 and the user sets limits by tapping.
  Future<void> seed({
    required String uid,
    required String name,
    required String email,
    double monthlyIncome = 0,
    int paydayDay = 1,
  }) {
    final user = _firestore.collection(UsersCollection.name).doc(uid);
    final budgets = user.collection(BudgetsCollection.name);
    final now = Timestamp.now();
    final batch = _firestore.batch();

    batch.set(user, {
      UsersCollection.displayName: name.trim(),
      UsersCollection.email: email.trim().toLowerCase(),
      UsersCollection.defaultCurrency: 'EGP',
      UsersCollection.monthlyIncome: monthlyIncome,
      UsersCollection.paydayDay: paydayDay,
      UsersCollection.createdAt: now,
    });

    batch.set(budgets.doc(BudgetsCollection.overallId), {
      BudgetsCollection.categoryId: null,
      BudgetsCollection.category: null,
      BudgetsCollection.amount: monthlyIncome,
      BudgetsCollection.period: 'monthly',
      BudgetsCollection.order: 0,
    });

    for (final (index, (category, share)) in budgetShares.indexed) {
      batch.set(budgets.doc(category.id), {
        BudgetsCollection.categoryId: category.id,
        BudgetsCollection.category: category.toEmbedded(),
        BudgetsCollection.amount: (monthlyIncome * share).roundToDouble(),
        BudgetsCollection.period: 'monthly',
        BudgetsCollection.order: index + 1,
      });
    }

    batch.set(user.collection(SavingsGoalsCollection.name).doc(), {
      SavingsGoalsCollection.goalName: 'Savings jar',
      SavingsGoalsCollection.targetAmount: monthlyIncome > 0
          ? monthlyIncome
          : 1000.0,
      SavingsGoalsCollection.currentAmount: 0.0,
      SavingsGoalsCollection.monthlyContribution: 0.0,
      SavingsGoalsCollection.jarCharacter: 'hamster',
      SavingsGoalsCollection.createdAt: now,
    });

    return batch.commit();
  }
}
