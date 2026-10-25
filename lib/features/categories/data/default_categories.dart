import 'category.dart';

/// Categories every account gets. They live in code (not Firestore), so they
/// are available instantly, offline, and cost no reads. Names are stored in
/// English and translated on screen (see AppStrings.categoryName).
abstract final class DefaultCategories {
  static const transport = Category(
    id: 'transport',
    name: 'Transport',
    iconKey: 'car',
    colorValue: 0xFF17B77D,
    isDefault: true,
  );
  static const bills = Category(
    id: 'bills',
    name: 'Bills',
    iconKey: 'receipt',
    colorValue: 0xFFF3B438,
    isDefault: true,
  );
  static const shopping = Category(
    id: 'shopping',
    name: 'Shopping',
    iconKey: 'bag',
    colorValue: 0xFF7CA0F7,
    isDefault: true,
  );
  static const entertainment = Category(
    id: 'entertainment',
    name: 'Entertainment',
    iconKey: 'movie',
    colorValue: 0xFFED6A56,
    isDefault: true,
  );
  static const groceries = Category(
    id: 'groceries',
    name: 'Groceries',
    iconKey: 'bag',
    colorValue: 0xFF64A66A,
    isDefault: true,
  );
  static const other = Category(
    id: 'other',
    name: 'Other',
    iconKey: 'payments',
    colorValue: 0xFF8B8178,
    isDefault: true,
  );

  static const all = [
    transport,
    bills,
    shopping,
    entertainment,
    groceries,
    other,
  ];
}
