import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/firebase/collections.dart';
import '../../categories/data/category.dart';

class Budget {
  const Budget({required this.id, required this.amount, this.category});

  /// 'overall' or the category id.
  final String id;
  final double amount;

  /// null = the overall monthly budget.
  final Category? category;

  factory Budget.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final map = doc.data()!;
    final category = map[BudgetsCollection.category] as Map?;
    return Budget(
      id: doc.id,
      amount: (map[BudgetsCollection.amount] as num).toDouble(),
      category: category == null
          ? null
          : Category.fromEmbedded(
              Map<String, dynamic>.from(category),
              id: map[BudgetsCollection.categoryId] as String,
            ),
    );
  }
}
