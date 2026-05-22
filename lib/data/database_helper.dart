import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  DatabaseHelper._internal();

  static final DatabaseHelper instance = DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final String dbPath = await getDatabasesPath();
    final String path = join(dbPath, 'expense_income.db');

    return await openDatabase(
      path,
      version: 1,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE notes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT,
        type TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE note_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        note_id INTEGER NOT NULL,
        text TEXT NOT NULL,
        is_checked INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (note_id) REFERENCES notes(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE incomes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category TEXT NOT NULL,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        description TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE expenses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        description TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE borrows (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        amount REAL NOT NULL,
        borrow_date TEXT NOT NULL,
        return_date TEXT,
        description TEXT,
        is_returned INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');
  }

  // -------------------- Income --------------------

  Future<int> insertIncome({
    required String category,
    required double amount,
    required DateTime date,
    String? description,
  }) async {
    final db = await database;

    return await db.insert('incomes', {
      'category': category,
      'amount': amount,
      'date': date.toIso8601String(),
      'description': description,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getIncomes() async {
    final db = await database;
    return await db.query('incomes', orderBy: 'date DESC');
  }

  Future<int> deleteIncome(int id) async {
    final db = await database;
    return await db.delete('incomes', where: 'id = ?', whereArgs: [id]);
  }

  // -------------------- Expense --------------------

  Future<int> insertExpense({
    required String name,
    required double amount,
    required DateTime date,
    String? description,
  }) async {
    final db = await database;

    return await db.insert('expenses', {
      'name': name,
      'amount': amount,
      'date': date.toIso8601String(),
      'description': description,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getExpenses() async {
    final db = await database;
    return await db.query('expenses', orderBy: 'date DESC');
  }

  Future<int> deleteExpense(int id) async {
    final db = await database;
    return await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }

  // -------------------- Borrow --------------------

  Future<int> insertBorrow({
    required String name,
    required double amount,
    required DateTime borrowDate,
    DateTime? returnDate,
    String? description,
  }) async {
    final db = await database;

    return await db.insert('borrows', {
      'name': name,
      'amount': amount,
      'borrow_date': borrowDate.toIso8601String(),
      'return_date': returnDate?.toIso8601String(),
      'description': description,
      'is_returned': 0,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getBorrows() async {
    final db = await database;
    return await db.query('borrows', orderBy: 'borrow_date DESC');
  }

  Future<int> updateBorrowReturned(int id, bool isReturned) async {
    final db = await database;

    return await db.update(
      'borrows',
      {'is_returned': isReturned ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteBorrow(int id) async {
    final db = await database;
    return await db.delete('borrows', where: 'id = ?', whereArgs: [id]);
  }

  // -------------------- Text Note --------------------

  Future<int> insertTextNote({
    required String title,
    required String content,
  }) async {
    final db = await database;

    return await db.insert('notes', {
      'title': title,
      'content': content,
      'type': 'text',
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  // -------------------- List Note --------------------

  Future<int> insertListNote({
    required String title,
    required List<Map<String, dynamic>> items,
  }) async {
    final db = await database;

    return await db.transaction((txn) async {
      final noteId = await txn.insert('notes', {
        'title': title,
        'content': null,
        'type': 'list',
        'created_at': DateTime.now().toIso8601String(),
      });

      for (final item in items) {
        await txn.insert('note_items', {
          'note_id': noteId,
          'text': item['text'],
          'is_checked': item['is_checked'] == true ? 1 : 0,
        });
      }

      return noteId;
    });
  }

  Future<List<Map<String, dynamic>>> getNotes() async {
    final db = await database;
    return await db.query('notes', orderBy: 'created_at DESC');
  }

  Future<List<Map<String, dynamic>>> getNoteItems(int noteId) async {
    final db = await database;

    return await db.query(
      'note_items',
      where: 'note_id = ?',
      whereArgs: [noteId],
    );
  }

  Future<int> deleteNote(int id) async {
    final db = await database;
    return await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }

  // -------------------- Close DB --------------------

  Future<void> closeDatabase() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}