// Firestore collection and field names used by the repositories and models.
//
// Layout (every document lives under the signed-in user, so the security
// rules in firestore.rules can simply say "only the owner"):
//
//   users/{uid}                       profile (name, income, payday, ...)
//   users/{uid}/expenses/{id}
//   users/{uid}/budgets/{id}          id = 'overall' or a category id
//   users/{uid}/savingsGoals/{id}
//   users/{uid}/categories/{id}       custom categories (defaults are in code)

abstract final class UsersCollection {
  static const name = 'users';
  static const displayName = 'name';
  static const email = 'email';
  static const defaultCurrency = 'defaultCurrency';
  static const monthlyIncome = 'monthlyIncome';
  static const paydayDay = 'paydayDay';
  static const createdAt = 'createdAt';
}

abstract final class CategoriesCollection {
  static const name = 'categories';
  static const id = 'id';
  static const categoryName = 'name';
  static const iconKey = 'iconKey';
  static const color = 'color';
  static const isDefault = 'isDefault';
}

abstract final class ExpensesCollection {
  static const name = 'expenses';
  static const categoryId = 'categoryId';

  /// A copy of the category (name / icon / color) so a list of expenses can
  /// be drawn without a second read — Firestore has no JOIN.
  static const category = 'category';
  static const title = 'title';
  static const merchant = 'merchant';
  static const amount = 'amount';
  static const expenseDate = 'expenseDate';
  static const paymentMethod = 'paymentMethod';
  static const createdAt = 'createdAt';
  static const updatedAt = 'updatedAt';
}

abstract final class BudgetsCollection {
  static const name = 'budgets';

  /// Document id of the overall monthly budget.
  static const overallId = 'overall';
  static const categoryId = 'categoryId';
  static const category = 'category';
  static const amount = 'amount';
  static const period = 'period';

  /// Display order (overall first, then the categories).
  static const order = 'order';
}

abstract final class SavingsGoalsCollection {
  static const name = 'savingsGoals';
  static const goalName = 'name';
  static const targetAmount = 'targetAmount';
  static const currentAmount = 'currentAmount';
  static const monthlyContribution = 'monthlyContribution';
  static const jarCharacter = 'jarCharacter';
  static const createdAt = 'createdAt';
}
