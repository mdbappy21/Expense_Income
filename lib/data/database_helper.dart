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
      version: 3,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _onCreate,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
            'ALTER TABLE notifications ADD COLUMN is_read INTEGER NOT NULL DEFAULT 0',
          );
        }

        if (oldVersion < 3) {
          await _createPaymentHistoryTable(db);
        }
      },
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
      CREATE TABLE payables (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        amount REAL NOT NULL,
        payable_date TEXT NOT NULL,
        return_date TEXT,
        description TEXT,
        is_returned INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE receivables (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        source TEXT NOT NULL,
        amount REAL NOT NULL,
        expected_date TEXT NOT NULL,
        description TEXT,
        is_received INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE notifications(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        reference_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        body TEXT NOT NULL,
        type TEXT NOT NULL,
        created_at TEXT NOT NULL,
        is_read INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await _createPaymentHistoryTable(db);
  }

  Future<void> _createPaymentHistoryTable(DatabaseExecutor db) async {
    await db.execute('''
      CREATE TABLE payment_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        reference_type TEXT NOT NULL,
        reference_id INTEGER NOT NULL,
        amount REAL NOT NULL CHECK(amount > 0),
        payment_date TEXT NOT NULL,
        note TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_payment_history_reference
      ON payment_history(reference_type, reference_id)
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

  // -------------------- payable --------------------

  Future<int> insertPayable({
    required String name,
    required double amount,
    required DateTime payableDate,
    DateTime? returnDate,
    String? description,
  }) async {
    final db = await database;

    return await db.insert('payables', {
      'name': name,
      'amount': amount,
      'payable_date': payableDate.toIso8601String(),
      'return_date': returnDate?.toIso8601String(),
      'description': description,
      'is_returned': 0,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getPayables() async {
    final db = await database;
    return await db.query('payables', orderBy: 'payable_date DESC');
  }

  Future<int> updatePayablePaid(int id, bool isReturned) async {
    final db = await database;

    return await db.update(
      'payables',
      {'is_returned': isReturned ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deletePayable(int id) async {
    final db = await database;
    return db.transaction((txn) async {
      await txn.delete(
        'payment_history',
        where: 'reference_type = ? AND reference_id = ?',
        whereArgs: ['payable', id],
      );
      await txn.delete(
        'notifications',
        where: 'reference_id = ? AND type = ?',
        whereArgs: [id, 'payable'],
      );
      return txn.delete('payables', where: 'id = ?', whereArgs: [id]);
    });
  }

  //----------------------receivable--------------------
  Future<int> insertReceivable({
    required String source,
    required double amount,
    required DateTime expectedDate,
    String? description,
  }) async {
    final db = await database;

    return await db.insert('receivables', {
      'source': source,
      'amount': amount,
      'expected_date': expectedDate.toIso8601String(),
      'description': description,
      'is_received': 0,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getReceivables() async {
    final db = await database;

    return await db.query('receivables', orderBy: 'expected_date DESC');
  }

  Future<int> updateReceivableReceived(int id, bool isReceived) async {
    final db = await database;

    return await db.update(
      'receivables',
      {'is_received': isReceived ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteReceivable(int id) async {
    final db = await database;

    return db.transaction((txn) async {
      await txn.delete(
        'payment_history',
        where: 'reference_type = ? AND reference_id = ?',
        whereArgs: ['receivable', id],
      );
      await txn.delete(
        'notifications',
        where: 'reference_id = ? AND type = ?',
        whereArgs: [id, 'receivable'],
      );
      return txn.delete('receivables', where: 'id = ?', whereArgs: [id]);
    });
  }

  Future<double> getReceivableTotal() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT COALESCE(SUM(
        MAX(0, r.amount - COALESCE((
          SELECT SUM(ph.amount)
          FROM payment_history ph
          WHERE ph.reference_type = 'receivable'
            AND ph.reference_id = r.id
        ), 0))
      ), 0) AS total
      FROM receivables r
      WHERE r.is_received = 0
    ''');
    return (result.first['total'] as num).toDouble();
  }

  // -------------------- Payment history --------------------

  Future<double> getPayablePaidTotal(int payableId) async {
    final db = await database;
    final result = await db.rawQuery(
      '''
      SELECT COALESCE(SUM(amount), 0) AS total
      FROM payment_history
      WHERE reference_type = ? AND reference_id = ?
      ''',
      ['payable', payableId],
    );
    return (result.first['total'] as num).toDouble();
  }

  Future<double> getReceivableReceivedTotal(int receivableId) async {
    final db = await database;
    final result = await db.rawQuery(
      '''
      SELECT COALESCE(SUM(amount), 0) AS total
      FROM payment_history
      WHERE reference_type = ? AND reference_id = ?
      ''',
      ['receivable', receivableId],
    );
    return (result.first['total'] as num).toDouble();
  }

  Future<double> getPayableRemainingBalance(int payableId) async {
    final db = await database;
    final rows = await db.query(
      'payables',
      where: 'id = ?',
      whereArgs: [payableId],
      limit: 1,
    );
    if (rows.isEmpty || rows.first['is_returned'] == 1) return 0;

    final original = (rows.first['amount'] as num).toDouble();
    final paid = await getPayablePaidTotal(payableId);
    return (original - paid).clamp(0.0, original).toDouble();
  }

  Future<double> getReceivableRemainingBalance(int receivableId) async {
    final db = await database;
    final rows = await db.query(
      'receivables',
      where: 'id = ?',
      whereArgs: [receivableId],
      limit: 1,
    );
    if (rows.isEmpty || rows.first['is_received'] == 1) return 0;

    final original = (rows.first['amount'] as num).toDouble();
    final received = await getReceivableReceivedTotal(receivableId);
    return (original - received).clamp(0.0, original).toDouble();
  }

  Future<List<Map<String, dynamic>>> getPayablePaymentHistory(
      int payableId,
      ) async {
    final db = await database;
    return db.query(
      'payment_history',
      where: 'reference_type = ? AND reference_id = ?',
      whereArgs: ['payable', payableId],
      orderBy: 'payment_date DESC, id DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getReceivablePaymentHistory(
      int receivableId,
      ) async {
    final db = await database;
    return db.query(
      'payment_history',
      where: 'reference_type = ? AND reference_id = ?',
      whereArgs: ['receivable', receivableId],
      orderBy: 'payment_date DESC, id DESC',
    );
  }

  /// Updates the in-app notification for an outstanding record without
  /// changing its read/unread state or original creation timestamp.
  Future<void> _updateOutstandingNotification(
      DatabaseExecutor txn, {
        required int referenceId,
        required String type,
        required String body,
      }) async {
    await txn.update(
      'notifications',
      {'body': body},
      where: 'reference_id = ? AND type = ?',
      whereArgs: [referenceId, type],
    );
  }

  String _formatNotificationAmount(double amount) =>
      '৳${amount.toStringAsFixed(2)}';

  /// Records one payment toward a payable and creates the matching expense.
  /// Returns the outstanding balance after this payment.
  Future<double> recordPayablePayment({
    required int payableId,
    required double amount,
    required DateTime paymentDate,
    String? note,
    DateTime? nextReturnDate,
  }) async {
    if (!amount.isFinite || amount <= 0) {
      throw ArgumentError.value(amount, 'amount', 'Must be greater than zero.');
    }

    final db = await database;
    return db.transaction((txn) async {
      final rows = await txn.query(
        'payables',
        where: 'id = ?',
        whereArgs: [payableId],
        limit: 1,
      );
      if (rows.isEmpty) throw StateError('Payable not found.');

      final payable = rows.first;
      if (payable['is_returned'] == 1) {
        throw StateError('This payable has already been settled.');
      }

      final original = (payable['amount'] as num).toDouble();
      final paidRows = await txn.rawQuery(
        '''
        SELECT COALESCE(SUM(amount), 0) AS total
        FROM payment_history
        WHERE reference_type = ? AND reference_id = ?
        ''',
        ['payable', payableId],
      );
      final paid = (paidRows.first['total'] as num).toDouble();
      final remaining = (original - paid).clamp(0.0, original).toDouble();

      if (amount > remaining + 0.000001) {
        throw StateError(
          'Payment exceeds the remaining balance of $remaining.',
        );
      }

      final now = DateTime.now().toIso8601String();
      await txn.insert('payment_history', {
        'reference_type': 'payable',
        'reference_id': payableId,
        'amount': amount,
        'payment_date': paymentDate.toIso8601String(),
        'note': note?.trim().isEmpty == true ? null : note?.trim(),
        'created_at': now,
      });

      await txn.insert('expenses', {
        'name': 'Payment to ${payable['name']}',
        'amount': amount,
        'date': paymentDate.toIso8601String(),
        'description': note?.trim().isNotEmpty == true
            ? note!.trim()
            : payable['description'],
        'created_at': now,
      });

      final newRemaining = (remaining - amount).clamp(0.0, original).toDouble();
      final isSettled = newRemaining <= 0.000001;

      final updateValues = <String, Object?>{
        'is_returned': isSettled ? 1 : 0,
      };
      if (!isSettled && nextReturnDate != null) {
        updateValues['return_date'] = nextReturnDate.toIso8601String();
      }

      await txn.update(
        'payables',
        updateValues,
        where: 'id = ?',
        whereArgs: [payableId],
      );

      if (isSettled) {
        await txn.delete(
          'notifications',
          where: 'reference_id = ? AND type = ?',
          whereArgs: [payableId, 'payable'],
        );
      } else {
        final updatedDueDate = nextReturnDate ??
            (payable['return_date'] == null
                ? null
                : DateTime.tryParse(payable['return_date'].toString()));
        final dateText = updatedDueDate == null
            ? ''
            : ' Next due date: ${updatedDueDate.toIso8601String().split('T').first}.';
        await _updateOutstandingNotification(
          txn,
          referenceId: payableId,
          type: 'payable',
          body: 'Remaining amount: ${_formatNotificationAmount(newRemaining)}.$dateText',
        );
      }

      return newRemaining;
    });
  }

  /// Records one collection toward a receivable and creates the matching income.
  /// Returns the outstanding balance after this collection.
  Future<double> recordReceivablePayment({
    required int receivableId,
    required double amount,
    required DateTime paymentDate,
    String? note,
    DateTime? nextExpectedDate,
  }) async {
    if (!amount.isFinite || amount <= 0) {
      throw ArgumentError.value(amount, 'amount', 'Must be greater than zero.');
    }

    final db = await database;
    return db.transaction((txn) async {
      final rows = await txn.query(
        'receivables',
        where: 'id = ?',
        whereArgs: [receivableId],
        limit: 1,
      );
      if (rows.isEmpty) throw StateError('Receivable not found.');

      final receivable = rows.first;
      if (receivable['is_received'] == 1) {
        throw StateError('This receivable has already been settled.');
      }

      final original = (receivable['amount'] as num).toDouble();
      final receivedRows = await txn.rawQuery(
        '''
        SELECT COALESCE(SUM(amount), 0) AS total
        FROM payment_history
        WHERE reference_type = ? AND reference_id = ?
        ''',
        ['receivable', receivableId],
      );
      final received = (receivedRows.first['total'] as num).toDouble();
      final remaining = (original - received).clamp(0.0, original).toDouble();

      if (amount > remaining + 0.000001) {
        throw StateError(
          'Collection exceeds the remaining balance of $remaining.',
        );
      }

      final now = DateTime.now().toIso8601String();
      await txn.insert('payment_history', {
        'reference_type': 'receivable',
        'reference_id': receivableId,
        'amount': amount,
        'payment_date': paymentDate.toIso8601String(),
        'note': note?.trim().isEmpty == true ? null : note?.trim(),
        'created_at': now,
      });

      await txn.insert('incomes', {
        'category': 'Received from ${receivable['source']}',
        'amount': amount,
        'date': paymentDate.toIso8601String(),
        'description': note?.trim().isNotEmpty == true
            ? note!.trim()
            : receivable['description'],
        'created_at': now,
      });

      final newRemaining = (remaining - amount).clamp(0.0, original).toDouble();
      final isSettled = newRemaining <= 0.000001;

      final updateValues = <String, Object?>{
        'is_received': isSettled ? 1 : 0,
      };
      if (!isSettled && nextExpectedDate != null) {
        updateValues['expected_date'] = nextExpectedDate.toIso8601String();
      }

      await txn.update(
        'receivables',
        updateValues,
        where: 'id = ?',
        whereArgs: [receivableId],
      );

      if (isSettled) {
        await txn.delete(
          'notifications',
          where: 'reference_id = ? AND type = ?',
          whereArgs: [receivableId, 'receivable'],
        );
      } else {
        final updatedExpectedDate = nextExpectedDate ??
            DateTime.tryParse(receivable['expected_date'].toString());
        final dateText = updatedExpectedDate == null
            ? ''
            : ' Expected date: ${updatedExpectedDate.toIso8601String().split('T').first}.';
        await _updateOutstandingNotification(
          txn,
          referenceId: receivableId,
          type: 'receivable',
          body: 'Remaining amount: ${_formatNotificationAmount(newRemaining)}.$dateText',
        );
      }

      return newRemaining;
    });
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

  //---------------------transaction history and summary total ----------------
  Future<double> getIncomeTotal() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM incomes',
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<double> getExpenseTotal() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM expenses',
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<double> getPayableTotal() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT COALESCE(SUM(
        MAX(0, p.amount - COALESCE((
          SELECT SUM(ph.amount)
          FROM payment_history ph
          WHERE ph.reference_type = 'payable'
            AND ph.reference_id = p.id
        ), 0))
      ), 0) AS total
      FROM payables p
      WHERE p.is_returned = 0
    ''');
    return (result.first['total'] as num).toDouble();
  }

  Future<List<Map<String, dynamic>>> getAllTransactions() async {
    final db = await database;

    final incomes = await db.rawQuery('''
    SELECT id, category as title, amount, date, description, 'income' as type
    FROM incomes
  ''');

    final expenses = await db.rawQuery('''
    SELECT id, name as title, amount, date, description, 'expense' as type
    FROM expenses
  ''');

    final payables = await db.rawQuery('''
    SELECT id, name as title, amount, payable_date as date, description, is_returned,'payable' as type
    FROM payables
  ''');

    final receivables = await db.rawQuery('''
  SELECT
  id,
  source as title,
  amount,
  expected_date as date,
  description,
  is_received,
  'receivable' as type
  FROM receivables
''');

    final transactions = [...incomes, ...expenses, ...payables, ...receivables];

    transactions.sort((a, b) {
      final dateA = DateTime.parse(a['date'] as String);
      final dateB = DateTime.parse(b['date'] as String);
      return dateB.compareTo(dateA);
    });

    return transactions;
  }

  Future<List<Map<String, dynamic>>> getTransactionsByTypeAndPeriod({
    required String type,
    required String period,
  }) async {
    final db = await database;

    final now = DateTime.now();
    late DateTime startDate;

    if (period == 'Day') {
      startDate = DateTime(now.year, now.month, now.day);
    } else if (period == 'Week') {
      startDate = now.subtract(Duration(days: now.weekday - 1));
      startDate = DateTime(startDate.year, startDate.month, startDate.day);
    } else if (period == 'Month') {
      startDate = DateTime(now.year, now.month, 1);
    } else {
      startDate = DateTime(now.year, 1, 1);
    }

    final start = startDate.toIso8601String();

    if (type == 'Income') {
      return await db.rawQuery(
        '''
      SELECT id, category as title, amount, date, description, 'Income' as type
      FROM incomes
      WHERE date >= ?
      ORDER BY amount DESC
    ''',
        [start],
      );
    } else if (type == 'Expense') {
      return await db.rawQuery(
        '''
      SELECT id, name as title, amount, date, description, 'Expense' as type
      FROM expenses
      WHERE date >= ?
      ORDER BY amount DESC
    ''',
        [start],
      );
    } else if (type == 'Receivable') {
      return await db.rawQuery(
        '''
    SELECT
    id,
    source as title,
    amount,
    expected_date as date,
    description,
    'Receivable' as type
    FROM receivables
    WHERE expected_date >= ?
    ORDER BY amount DESC
  ''',
        [start],
      );
    } else {
      return await db.rawQuery(
        '''
      SELECT id, name as title, amount, payable_date as date, description, 'Payable' as type
      FROM payables
      WHERE payable_date >= ?
      ORDER BY amount DESC
    ''',
        [start],
      );
    }
  }

  Future<Map<String, dynamic>?> getTransactionDetail({
    required String type,
    required int id,
  }) async {
    final db = await database;

    switch (type) {
      case 'income':
        final result = await db.query(
          'incomes',
          where: 'id=?',
          whereArgs: [id],
        );
        return result.isEmpty ? null : result.first;

      case 'expense':
        final result = await db.query(
          'expenses',
          where: 'id=?',
          whereArgs: [id],
        );
        return result.isEmpty ? null : result.first;

      case 'payable':
        final result = await db.query(
          'payables',
          where: 'id=?',
          whereArgs: [id],
        );
        return result.isEmpty ? null : result.first;

      case 'receivable':
        final result = await db.query(
          'receivables',
          where: 'id=?',
          whereArgs: [id],
        );
        return result.isEmpty ? null : result.first;

      default:
        return null;
    }
  }

  //------------------note---------------------------------
  Future<Map<String, dynamic>?> getNoteById(int id) async {
    final db = await database;

    final result = await db.query(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return result.first;
  }

  Future<int> updateTextNote({
    required int id,
    required String title,
    required String content,
  }) async {
    final db = await database;

    return await db.update(
      'notes',
      {'title': title, 'content': content},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> updateListNote({
    required int noteId,
    required String title,
    required List<Map<String, dynamic>> items,
  }) async {
    final db = await database;

    return await db.transaction((txn) async {
      await txn.update(
        'notes',
        {'title': title},
        where: 'id = ?',
        whereArgs: [noteId],
      );

      await txn.delete('note_items', where: 'note_id = ?', whereArgs: [noteId]);

      for (final item in items) {
        await txn.insert('note_items', {
          'note_id': noteId,
          'text': item['text'],
          'is_checked': item['is_checked'] ? 1 : 0,
        });
      }

      return noteId;
    });
  }

  //-----------------notification-------------------

  Future<int> insertNotification({
    required int referenceId,
    required String title,
    required String body,
    required String type,
  }) async {
    final db = await database;

    return await db.insert('notifications', {
      'reference_id': referenceId,
      'title': title,
      'body': body,
      'type': type,
      'created_at': DateTime.now().toIso8601String(),
      'is_read': 0,
    });
  }

  Future<List<Map<String, dynamic>>> getNotifications() async {
    final db = await database;

    return await db.query('notifications', orderBy: 'created_at DESC');
  }

  /// Number of notifications that have not been read by the user.
  Future<int> getUnreadNotificationsCount() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) AS total FROM notifications WHERE is_read = 0',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> markNotificationRead(int id) async {
    final db = await database;
    return db.update(
      'notifications',
      {'is_read': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> markNotificationUnread(int id) async {
    final db = await database;

    return db.update(
      'notifications',
      {'is_read': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> getPendingPayablesCount() async {
    final db = await database;

    final result = await db.rawQuery('''
    SELECT COUNT(*)
    FROM payables
    WHERE is_returned = 0
    ''');

    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> getPendingReceivablesCount() async {
    final db = await database;

    final result = await db.rawQuery('''
    SELECT COUNT(*)
    FROM receivables
    WHERE is_received = 0
    ''');

    return Sqflite.firstIntValue(result) ?? 0;
  }

  //----------------------Notification Action--------------

  /// Notification action means settle the entire remaining payable balance.
  Future<void> markPayablePaid(int payableId) async {
    final remaining = await getPayableRemainingBalance(payableId);
    if (remaining <= 0) return;

    await recordPayablePayment(
      payableId: payableId,
      amount: remaining,
      paymentDate: DateTime.now(),
      note: 'Settled from notification',
    );
  }

  /// Notification action means collect the entire remaining receivable balance.
  Future<void> markReceivableReceived(int receivableId) async {
    final remaining = await getReceivableRemainingBalance(receivableId);
    if (remaining <= 0) return;

    await recordReceivablePayment(
      receivableId: receivableId,
      amount: remaining,
      paymentDate: DateTime.now(),
      note: 'Settled from notification',
    );
  }

  // -------------------- Close DB --------------------

  Future<void> closeDatabase() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
