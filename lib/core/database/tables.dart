// Table and column names used in queries and toMap()/fromMap().
// (The CREATE TABLE statements in app_database.dart are written as literal SQL
// on purpose: a migration should be a frozen snapshot that never changes.)

abstract final class UsersTable {
  static const table = 'users';
  static const id = 'id';
  static const name = 'name';
  static const email = 'email';
  static const passwordHash = 'password_hash';
  static const passwordSalt = 'password_salt';
  static const defaultCurrency = 'default_currency';
  static const monthlyIncome = 'monthly_income';
  static const paydayDay = 'payday_day';
  static const createdAt = 'created_at';
}

abstract final class CategoriesTable {
  static const table = 'categories';
  static const id = 'id';
  static const userId = 'user_id';
  static const name = 'name';
  static const iconKey = 'icon_key';
  static const color = 'color';
  static const isDefault = 'is_default';
}

abstract final class ExpensesTable {
  static const table = 'expenses';
  static const id = 'id';
  static const userId = 'user_id';
  static const categoryId = 'category_id';
  static const title = 'title';
  static const merchant = 'merchant';
  static const amount = 'amount';
  static const expenseDate = 'expense_date';
  static const paymentMethod = 'payment_method';
  static const createdAt = 'created_at';
  static const updatedAt = 'updated_at';
}

abstract final class BudgetsTable {
  static const table = 'budgets';
  static const id = 'id';
  static const userId = 'user_id';
  static const categoryId = 'category_id';
  static const amount = 'amount';
  static const period = 'period';
}

abstract final class SavingsGoalsTable {
  static const table = 'savings_goals';
  static const id = 'id';
  static const userId = 'user_id';
  static const name = 'name';
  static const targetAmount = 'target_amount';
  static const currentAmount = 'current_amount';
  static const monthlyContribution = 'monthly_contribution';
  static const jarCharacter = 'jar_character';
  static const createdAt = 'created_at';
}
