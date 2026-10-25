import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:first_app/core/firebase/collections.dart';
import 'package:first_app/features/auth/data/app_user.dart';
import 'package:first_app/features/auth/data/user_seeder.dart';
import 'package:first_app/features/budget/data/budget_repository.dart';
import 'package:first_app/features/categories/data/default_categories.dart';
import 'package:first_app/features/expenses/data/expense.dart';
import 'package:first_app/features/expenses/data/expense_repository.dart';
import 'package:first_app/features/expenses/presentation/expense_provider.dart';
import 'package:first_app/features/savings/data/savings_repository.dart';

void main() {
  const uid = 'user-1';
  late FakeFirebaseFirestore firestore;

  setUp(() => firestore = FakeFirebaseFirestore());

  Expense expense(String title, double amount, DateTime date) => Expense(
    title: title,
    category: DefaultCategories.groceries,
    merchant: '',
    amount: amount,
    date: date,
  );

  group('UserSeeder', () {
    test('creates the profile, split budgets, and a savings jar', () async {
      await UserSeeder(firestore).seed(
        uid: uid,
        name: ' Ibrahim ',
        email: 'Me@Example.com',
        monthlyIncome: 10000,
        paydayDay: 25,
      );

      final profile = AppUser.fromFirestore(
        await firestore.collection(UsersCollection.name).doc(uid).get(),
      );
      expect(profile.name, 'Ibrahim');
      expect(profile.email, 'me@example.com');
      expect(profile.paydayDay, 25);

      final budgets = await BudgetRepository(firestore, uid).watchAll().first;
      expect(budgets.first.id, BudgetsCollection.overallId);
      expect(budgets.first.category, isNull);
      expect(budgets.first.amount, 10000);
      expect(budgets, hasLength(1 + DefaultCategories.all.length));
      final groceries = budgets.firstWhere((b) => b.id == 'groceries');
      expect(groceries.category!.name, 'Groceries');
      expect(groceries.amount, 2500);

      final goal = await SavingsRepository(
        firestore,
        uid,
      ).watchMainGoal().first;
      expect(goal!.targetAmount, 10000);
      expect(goal.currentAmount, 0);
    });
  });

  group('ExpenseRepository', () {
    test('round-trips expenses newest first, scoped to the user', () async {
      final repository = ExpenseRepository(firestore, uid);
      repository.add(expense('Older', 50, DateTime(2026, 9, 1)));
      repository.add(expense('Newer', 120.5, DateTime(2026, 10, 3)));
      ExpenseRepository(
        firestore,
        'someone-else',
      ).add(expense('Not mine', 999, DateTime(2026, 10, 4)));

      final list = await repository.watchAll().firstWhere(
        (s) => s.data.length == 2,
      );
      expect(list.data.map((e) => e.title), ['Newer', 'Older']);
      expect(list.data.first.amount, 120.5);
      expect(list.data.first.category.id, 'groceries');
      expect(list.data.first.date, DateTime(2026, 10, 3));
    });

    test('updates and deletes', () async {
      final repository = ExpenseRepository(firestore, uid);
      final id = repository.add(expense('Coffee', 40, DateTime(2026, 10, 1)));
      await repository.watchAll().firstWhere((s) => s.data.isNotEmpty);

      repository.update(
        Expense(
          id: id,
          title: 'Coffee beans',
          category: DefaultCategories.shopping,
          merchant: 'Cafe',
          amount: 80,
          date: DateTime(2026, 10, 1),
        ),
      );
      final updated = await repository.watchAll().firstWhere(
        (s) => s.data.single.title == 'Coffee beans',
      );
      expect(updated.data.single.category.id, 'shopping');
      expect(updated.data.single.amount, 80);

      repository.delete(id);
      await repository.watchAll().firstWhere((s) => s.data.isEmpty);
    });
  });

  test('savings contributions add up atomically', () async {
    await UserSeeder(firestore).seed(uid: uid, name: 'A', email: 'a@b.c');
    final repository = SavingsRepository(firestore, uid);
    final goal = (await repository.watchMainGoal().first)!;

    repository.addContribution(goal.id, 100);
    repository.addContribution(goal.id, 50.5);

    final updated = await repository.watchMainGoal().firstWhere(
      (g) => g!.currentAmount == 150.5,
    );
    expect(updated!.currentAmount, 150.5);
  });

  test('ExpenseProvider recomputes cached month totals on new data', () async {
    final repository = ExpenseRepository(firestore, uid);
    final provider = ExpenseProvider(repository)..listen();
    final october = DateTime(2026, 10);

    repository.add(expense('A', 100, DateTime(2026, 10, 2)));
    await repository.watchAll().firstWhere((s) => s.data.length == 1);
    await pumpEventQueue();
    expect(provider.spentInMonth(october), 100);

    repository.add(expense('B', 25, DateTime(2026, 10, 5)));
    await repository.watchAll().firstWhere((s) => s.data.length == 2);
    await pumpEventQueue();
    expect(provider.spentInMonth(october), 125);
    expect(provider.spentByCategoryInMonth(october), {'groceries': 125});

    provider.dispose();
  });

  test('Expense stores a copy of its category and a Timestamp', () {
    final map = expense('Bread', 15, DateTime(2026, 10, 1)).toFirestore();
    expect(map[ExpensesCollection.categoryId], 'groceries');
    expect(map[ExpensesCollection.expenseDate], isA<Timestamp>());
    expect(
      (map[ExpensesCollection.category] as Map)['name'],
      DefaultCategories.groceries.name,
    );
  });
}
