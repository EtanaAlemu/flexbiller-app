import 'dart:convert';
import 'package:sqflite_sqlcipher/sqflite.dart';
import '../../features/accounts/data/models/account_invoice_payment_model.dart';

class AccountInvoicePaymentDao {
  static const String tableName = 'account_invoice_payments';

  static const String createTableSQL = '''
    CREATE TABLE $tableName (
      id TEXT PRIMARY KEY,
      accountId TEXT NOT NULL,
      invoiceId TEXT NOT NULL,
      invoiceNumber TEXT NOT NULL,
      amount REAL NOT NULL,
      currency TEXT NOT NULL,
      paymentMethod TEXT NOT NULL,
      status TEXT NOT NULL,
      paymentDate TEXT NOT NULL,
      processedDate TEXT,
      transactionId TEXT,
      notes TEXT,
      metadata TEXT,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL
    )
  ''';

  static Map<String, dynamic> toMap(AccountInvoicePaymentModel payment) {
    final now = DateTime.now().toIso8601String();
    return {
      'id': payment.id,
      'accountId': payment.accountId,
      'invoiceId': payment.invoiceId,
      'invoiceNumber': payment.invoiceNumber,
      'amount': payment.amount,
      'currency': payment.currency,
      'paymentMethod': payment.paymentMethod,
      'status': payment.status,
      'paymentDate': payment.paymentDate.toIso8601String(),
      'processedDate': payment.processedDate?.toIso8601String(),
      'transactionId': payment.transactionId,
      'notes': payment.notes,
      'metadata': payment.metadata != null ? jsonEncode(payment.metadata) : null,
      'created_at': now,
      'updated_at': now,
    };
  }

  static AccountInvoicePaymentModel fromMap(Map<String, dynamic> map) {
    return AccountInvoicePaymentModel(
      id: map['id'] as String,
      accountId: map['accountId'] as String,
      invoiceId: map['invoiceId'] as String,
      invoiceNumber: map['invoiceNumber'] as String,
      amount: map['amount'] as double,
      currency: map['currency'] as String,
      paymentMethod: map['paymentMethod'] as String,
      status: map['status'] as String,
      paymentDate: DateTime.parse(map['paymentDate'] as String),
      processedDate: map['processedDate'] != null
          ? DateTime.parse(map['processedDate'] as String)
          : null,
      transactionId: map['transactionId'] as String?,
      notes: map['notes'] as String?,
      metadata: map['metadata'] != null
          ? jsonDecode(map['metadata'] as String) as Map<String, dynamic>
          : null,
    );
  }

  // Insert or update an invoice payment
  static Future<void> insertOrUpdate(
    dynamic db,
    AccountInvoicePaymentModel payment,
  ) async {
    final map = toMap(payment);
    await db.insert(
      tableName,
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Insert multiple invoice payments
  static Future<void> insertMultiple(
    dynamic db,
    List<AccountInvoicePaymentModel> payments,
  ) async {
    await db.transaction((txn) async {
      for (final payment in payments) {
        await insertOrUpdate(txn, payment);
      }
    });
  }

  // Get all invoice payments for a specific account
  static Future<List<AccountInvoicePaymentModel>> getByAccountId(
    dynamic db,
    String accountId,
  ) async {
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'accountId = ?',
      whereArgs: [accountId],
      orderBy: 'paymentDate DESC',
    );

    return List.generate(maps.length, (i) => fromMap(maps[i]));
  }

  // Get a specific invoice payment by ID
  static Future<AccountInvoicePaymentModel?> getById(
    dynamic db,
    String id,
  ) async {
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return fromMap(maps.first);
    }
    return null;
  }

  // Get invoice payments by status
  static Future<List<AccountInvoicePaymentModel>> getByStatus(
    dynamic db,
    String accountId,
    String status,
  ) async {
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'accountId = ? AND status = ?',
      whereArgs: [accountId, status],
      orderBy: 'paymentDate DESC',
    );

    return List.generate(maps.length, (i) => fromMap(maps[i]));
  }

  // Get invoice payments by date range
  static Future<List<AccountInvoicePaymentModel>> getByDateRange(
    dynamic db,
    String accountId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'accountId = ? AND paymentDate BETWEEN ? AND ?',
      whereArgs: [
        accountId,
        startDate.toIso8601String(),
        endDate.toIso8601String(),
      ],
      orderBy: 'paymentDate DESC',
    );

    return List.generate(maps.length, (i) => fromMap(maps[i]));
  }

  // Get invoice payments by payment method
  static Future<List<AccountInvoicePaymentModel>> getByPaymentMethod(
    dynamic db,
    String accountId,
    String paymentMethod,
  ) async {
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'accountId = ? AND paymentMethod = ?',
      whereArgs: [accountId, paymentMethod],
      orderBy: 'paymentDate DESC',
    );

    return List.generate(maps.length, (i) => fromMap(maps[i]));
  }

  // Get invoice payments by invoice number
  static Future<List<AccountInvoicePaymentModel>> getByInvoiceNumber(
    dynamic db,
    String accountId,
    String invoiceNumber,
  ) async {
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'accountId = ? AND invoiceNumber = ?',
      whereArgs: [accountId, invoiceNumber],
      orderBy: 'paymentDate DESC',
    );

    return List.generate(maps.length, (i) => fromMap(maps[i]));
  }

  // Get invoice payments with pagination
  static Future<List<AccountInvoicePaymentModel>> getWithPagination(
    dynamic db,
    String accountId,
    int page,
    int pageSize,
  ) async {
    final offset = page * pageSize;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'accountId = ?',
      whereArgs: [accountId],
      orderBy: 'paymentDate DESC',
      limit: pageSize,
      offset: offset,
    );

    return List.generate(maps.length, (i) => fromMap(maps[i]));
  }

  // Get all invoice payments
  static Future<List<AccountInvoicePaymentModel>> getAll(dynamic db) async {
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      orderBy: 'paymentDate DESC',
    );

    return List.generate(maps.length, (i) => fromMap(maps[i]));
  }

  // Update an invoice payment
  static Future<int> update(
    dynamic db,
    AccountInvoicePaymentModel payment,
  ) async {
    final map = toMap(payment);
    map['updated_at'] = DateTime.now().toIso8601String();

    return await db.update(
      tableName,
      map,
      where: 'id = ?',
      whereArgs: [payment.id],
    );
  }

  // Delete an invoice payment
  static Future<int> delete(dynamic db, String id) async {
    return await db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete invoice payments by account ID
  static Future<int> deleteByAccountId(dynamic db, String accountId) async {
    return await db.delete(
      tableName,
      where: 'accountId = ?',
      whereArgs: [accountId],
    );
  }

  // Delete all invoice payments
  static Future<int> deleteAll(dynamic db) async {
    return await db.delete(tableName);
  }

  // Get count of invoice payments for a specific account
  static Future<int> getCountByAccountId(
    dynamic db,
    String accountId,
  ) async {
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $tableName WHERE accountId = ?',
      [accountId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Get count by status for a specific account
  static Future<int> getCountByStatus(
    dynamic db,
    String accountId,
    String status,
  ) async {
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $tableName WHERE accountId = ? AND status = ?',
      [accountId, status],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Get total count of all invoice payments
  static Future<int> getTotalCount(dynamic db) async {
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $tableName',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Get total amount by status for a specific account
  static Future<double> getTotalAmountByStatus(
    dynamic db,
    String accountId,
    String status,
  ) async {
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM $tableName WHERE accountId = ? AND status = ?',
      [accountId, status],
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  // Get total amount for a specific account
  static Future<double> getTotalAmountByAccountId(
    dynamic db,
    String accountId,
  ) async {
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM $tableName WHERE accountId = ?',
      [accountId],
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  // Check if an invoice payment exists
  static Future<bool> exists(dynamic db, String id) async {
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $tableName WHERE id = ?',
      [id],
    );
    return (Sqflite.firstIntValue(result) ?? 0) > 0;
  }

  // Search invoice payments by notes
  static Future<List<AccountInvoicePaymentModel>> searchByNotes(
    dynamic db,
    String accountId,
    String searchTerm,
  ) async {
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'accountId = ? AND notes LIKE ?',
      whereArgs: [accountId, '%$searchTerm%'],
      orderBy: 'paymentDate DESC',
    );

    return List.generate(maps.length, (i) => fromMap(maps[i]));
  }

  // Get invoice payments by transaction ID
  static Future<AccountInvoicePaymentModel?> getByTransactionId(
    dynamic db,
    String transactionId,
  ) async {
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'transactionId = ?',
      whereArgs: [transactionId],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return fromMap(maps.first);
    }
    return null;
  }
}
