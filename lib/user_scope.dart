import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'features/budget/data/budget_repository.dart';
import 'features/budget/presentation/budget_provider.dart';
import 'features/categories/data/category_repository.dart';
import 'features/categories/presentation/category_provider.dart';
import 'features/expenses/data/expense_repository.dart';
import 'features/expenses/presentation/expense_provider.dart';
import 'features/savings/data/savings_repository.dart';
import 'features/savings/presentation/savings_provider.dart';

/// Creates the data providers for ONE signed-in user. Each one listens to
/// that user's Firestore collections and cancels its stream when disposed.
/// app.dart gives this widget a key based on the user id, so logging out and
/// into another account throws everything away and rebuilds it from scratch.
class UserScope extends StatelessWidget {
  const UserScope({
    super.key,
    required this.firestore,
    required this.userId,
    required this.child,
  });

  final FirebaseFirestore firestore;
  final String userId;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) =>
              CategoryProvider(CategoryRepository(firestore, userId))..listen(),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              ExpenseProvider(ExpenseRepository(firestore, userId))..listen(),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              BudgetProvider(BudgetRepository(firestore, userId))..listen(),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              SavingsProvider(SavingsRepository(firestore, userId))..listen(),
        ),
      ],
      child: child,
    );
  }
}
