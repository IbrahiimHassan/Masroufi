import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'tables.dart';

/// Single entry point to the SQLite database.
///
/// * Opened once (singleton) and shared by every repository.
/// * `onCreate` builds the schema and seeds the default categories.
/// * `onUpgrade` runs versioned migrations so users keep their data.
///
/// Version history
///   1  first release (single hard-coded user)
///   2  accounts: users.email / password_hash / password_salt
class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();

  static const _fileName = 'masroufi.db';

  /// Bump this whenever the schema changes, then add a step in [_onUpgrade].
  static const _version = 2;

  Future<Database>? _opening;

  /// Caching the Future (not the Database) means two callers asking at the
  /// same moment still share a single open operation.
  Future<Database> get database => _opening ??= _open();

  Future<Database> _open() async {
    final folder = await getDatabasesPath();
    return openDatabase(
      join(folder, _fileName),
      version: _version,
      onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    final batch = db.batch();

    batch.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT,
        password_hash TEXT,
        password_salt TEXT,
        default_currency TEXT NOT NULL DEFAULT 'EGP',
        monthly_income REAL NOT NULL DEFAULT 0,
        payday_day INTEGER NOT NULL DEFAULT 1
          CHECK (payday_day BETWEEN 1 AND 31),
        created_at INTEGER NOT NULL
      )
    ''');
    batch.execute('CREATE UNIQUE INDEX idx_users_email ON users(email)');

    batch.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
        name TEXT NOT NULL,
        icon_key TEXT NOT NULL,
        color INTEGER NOT NULL,
        is_default INTEGER NOT NULL DEFAULT 0
      )
    ''');

    batch.execute('''
      CREATE TABLE expenses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL DEFAULT 1
          REFERENCES users(id) ON DELETE CASCADE,
        category_id INTEGER NOT NULL
          REFERENCES categories(id) ON DELETE RESTRICT,
        title TEXT NOT NULL,
        merchant TEXT NOT NULL DEFAULT '',
        amount REAL NOT NULL CHECK (amount > 0),
        expense_date INTEGER NOT NULL,
        payment_method TEXT NOT NULL DEFAULT 'cash'
          CHECK (payment_method IN ('cash', 'card', 'wallet', 'other')),
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');
    batch.execute('CREATE INDEX idx_expenses_date ON expenses(expense_date)');

    batch.execute('''
      CREATE TABLE budgets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL DEFAULT 1
          REFERENCES users(id) ON DELETE CASCADE,
        category_id INTEGER REFERENCES categories(id) ON DELETE CASCADE,
        amount REAL NOT NULL CHECK (amount >= 0),
        period TEXT NOT NULL DEFAULT 'monthly'
          CHECK (period IN ('weekly', 'monthly', 'pay_cycle'))
      )
    ''');

    batch.execute('''
      CREATE TABLE savings_goals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL DEFAULT 1
          REFERENCES users(id) ON DELETE CASCADE,
        name TEXT NOT NULL,
        target_amount REAL NOT NULL,
        current_amount REAL NOT NULL DEFAULT 0,
        monthly_contribution REAL NOT NULL DEFAULT 0,
        jar_character TEXT NOT NULL DEFAULT 'hamster',
        created_at INTEGER NOT NULL
      )
    ''');

    _seedCategories(batch);
    await batch.commit(noResult: true);
  }

  /// Default categories shared by every account (user_id = NULL).
  /// Budgets and the savings jar are created per account at registration
  /// (see AuthRepository.register).
  void _seedCategories(Batch batch) {
    // (id, name, iconKey, color). Fixed ids so per-user budgets can use them.
    const categories = [
      (1, 'Transport', 'car', 0xFF17B77D),
      (2, 'Bills', 'receipt', 0xFFF3B438),
      (3, 'Shopping', 'bag', 0xFF7CA0F7),
      (4, 'Entertainment', 'movie', 0xFFED6A56),
      (5, 'Groceries', 'bag', 0xFF64A66A),
      (6, 'Other', 'payments', 0xFF8B8178),
    ];
    for (final (id, name, icon, color) in categories) {
      batch.insert(CategoriesTable.table, {
        CategoriesTable.id: id,
        CategoriesTable.name: name,
        CategoriesTable.iconKey: icon,
        CategoriesTable.color: color,
        CategoriesTable.isDefault: 1,
      });
    }
  }

  /// Runs when an existing install has an older version than [_version].
  /// One `if` block per version; never edit an old one.
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // The v1 demo user (id 1) stays in the table but has no credentials,
      // so nobody can log in to it. New accounts get fresh ids.
      await db.execute('ALTER TABLE users ADD COLUMN email TEXT');
      await db.execute('ALTER TABLE users ADD COLUMN password_hash TEXT');
      await db.execute('ALTER TABLE users ADD COLUMN password_salt TEXT');
      await db.execute('CREATE UNIQUE INDEX idx_users_email ON users(email)');
    }
  }
}
