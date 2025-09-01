import 'dart:convert';
import 'package:sqflite_sqlcipher/sqflite.dart';
import '../../features/accounts/data/models/account_payment_model.dart';

class AccountPaymentDao {
  static const String tableName = 'account_payments';

  static const String createTableSQL =
      '''
    CREATE TABLE $tableName (
      id TEXT PRIMARY KEY,
      accountId TEXT NOT NULL,
      paymentType TEXT NOT NULL,
      paymentStatus TEXT NOT NULL,
      amount REAL NOT NULL,
      currency TEXT NOT NULL,
      paymentMethodId TEXT NOT NULL,
      paymentMethodName TEXT,
      paymentMethodType TEXT,
      transactionId TEXT,
      referenceNumber TEXT,
      description TEXT,
      notes TEXT,
      paymentDate TEXT NOT NULL,
      processedDate TEXT,
      createdAt TEXT NOT NULL,
      updatedAt TEXT,
      metadata TEXT,
      failureReason TEXT,
      gatewayResponse TEXT,
      isRefunded INTEGER NOT NULL,
      refundedAmount REAL,
      refundedDate TEXT,
      refundReason TEXT,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL
    )
  ''';

  static Map<String, dynamic> toMap(AccountPaymentModel payment) {
    final now = DateTime.now().toIso8601String();
    return {
      'id': payment.id,
      'accountId': payment.accountId,
      'paymentType': payment.paymentType,
      'paymentStatus': payment.paymentStatus,
      'amount': payment.amount,
      'currency': payment.currency,
      'paymentMethodId': payment.paymentMethodId,
      'paymentMethodName': payment.paymentMethodName,
      'paymentMethodType': payment.paymentMethodType,
      'transactionId': payment.transactionId,
      'referenceNumber': payment.referenceNumber,
      'description': payment.description,
      'notes': payment.notes,
      'paymentDate': payment.paymentDate.toIso8601String(),
      'processedDate': payment.processedDate?.toIso8601String(),
      'createdAt': payment.createdAt.toIso8601String(),
      'updatedAt': payment.updatedAt?.toIso8601String(),
      'metadata': payment.metadata != null
          ? jsonEncode(payment.metadata)
          : null,
      'failureReason': payment.failureReason,
      'gatewayResponse': payment.gatewayResponse,
      'isRefunded': payment.isRefunded ? 1 : 0,
      'refundedAmount': payment.refundedAmount,
      'refundedDate': payment.refundedDate?.toIso8601String(),
      'refundReason': payment.refundReason,
      'created_at': now,
      'updated_at': now,
    };
  }

  static AccountPaymentModel fromMap(Map<String, dynamic> map) {
    return AccountPaymentModel(
      id: map['id'] as String,
      accountId: map['accountId'] as String,
      paymentType: map['paymentType'] as String,
      paymentStatus: map['paymentStatus'] as String,
      amount: map['amount'] as double,
      currency: map['currency'] as String,
      paymentMethodId: map['paymentMethodId'] as String,
      paymentMethodName: map['paymentMethodName'] as String?,
      paymentMethodType: map['paymentMethodType'] as String?,
      transactionId: map['transactionId'] as String?,
      referenceNumber: map['referenceNumber'] as String?,
      description: map['description'] as String?,
      notes: map['notes'] as String?,
      paymentDate: DateTime.parse(map['paymentDate'] as String),
      processedDate: map['processedDate'] != null
          ? DateTime.parse(map['processedDate'] as String)
          : null,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'] as String)
          : null,
      metadata: map['metadata'] != null
          ? jsonDecode(map['metadata'] as String) as Map<String, dynamic>
          : null,
      failureReason: map['failureReason'] as String?,
      gatewayResponse: map['gatewayResponse'] as String?,
      isRefunded: (map['isRefunded'] as int) == 1,
      refundedAmount: map['refundedAmount'] as double?,
      refundedDate: map['refundedDate'] != null
          ? DateTime.parse(map['refundedDate'] as String)
          : null,
      refundReason: map['refundReason'] as String?,
    );
  }

  // Insert or update a payment
  static Future<void> insertOrUpdate(
    dynamic db,
    AccountPaymentModel payment,
  ) async {
    final map = toMap(payment);
    await db.insert(
      tableName,
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Insert multiple payments
  static Future<void> insertMultiple(
    dynamic db,
    List<AccountPaymentModel> payments,
  ) async {
    await db.transaction((txn) async {
      for (final payment in payments) {
        await insertOrUpdate(txn, payment);
      }
    });
  }

  // Get all payments for a specific account
  static Future<List<AccountPaymentModel>> getByAccountId(
    dynamic db,
    String accountId,
  ) async {
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'accountId = ?',
      whereArgs: [accountId],
      orderBy: 'paymentDate DESC, createdAt DESC',
    );

    return List.generate(maps.length, (i) => fromMap(maps[i]));
  }

  // Get a specific payment by ID
  static Future<AccountPaymentModel?> getById(dynamic db, String id) async {
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

  // Get payments by status for a specific account
  static Future<List<AccountPaymentModel>> getByStatus(
    dynamic db,
    String accountId,
    String paymentStatus,
  ) async {
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'accountId = ? AND paymentStatus = ?',
      whereArgs: [accountId, paymentStatus],
      orderBy: 'paymentDate DESC, createdAt DESC',
    );

    return List.generate(maps.length, (i) => fromMap(maps[i]));
  }

  // Get payments by type for a specific account
  static Future<List<AccountPaymentModel>> getByType(
    dynamic db,
    String accountId,
    String paymentType,
  ) async {
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'accountId = ? AND paymentType = ?',
      whereArgs: [accountId, paymentType],
      orderBy: 'paymentDate DESC, createdAt DESC',
    );

    return List.generate(maps.length, (i) => fromMap(maps[i]));
  }

  // Get payments by payment method ID
  static Future<List<AccountPaymentModel>> getByPaymentMethodId(
    dynamic db,
    String accountId,
    String paymentMethodId,
  ) async {
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'accountId = ? AND paymentMethodId = ?',
      whereArgs: [accountId, paymentMethodId],
      orderBy: 'paymentDate DESC, createdAt DESC',
    );

    return List.generate(maps.length, (i) => fromMap(maps[i]));
  }

  // Get payments by date range for a specific account
  static Future<List<AccountPaymentModel>> getByDateRange(
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
      orderBy: 'paymentDate DESC, createdAt DESC',
    );

    return List.generate(maps.length, (i) => fromMap(maps[i]));
  }

  // Get payments with pagination
  static Future<List<AccountPaymentModel>> getWithPagination(
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
      orderBy: 'paymentDate DESC, createdAt DESC',
      limit: pageSize,
      offset: offset,
    );

    return List.generate(maps.length, (i) => fromMap(maps[i]));
  }

  // Get all payments
  static Future<List<AccountPaymentModel>> getAll(dynamic db) async {
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      orderBy: 'accountId, paymentDate DESC, createdAt DESC',
    );

    return List.generate(maps.length, (i) => fromMap(maps[i]));
  }

  // Get successful payments for a specific account
  static Future<List<AccountPaymentModel>> getSuccessfulPayments(
    dynamic db,
    String accountId,
  ) async {
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'accountId = ? AND paymentStatus = ?',
      whereArgs: [accountId, 'SUCCESS'],
      orderBy: 'paymentDate DESC, createdAt DESC',
    );

    return List.generate(maps.length, (i) => fromMap(maps[i]));
  }

  // Get failed payments for a specific account
  static Future<List<AccountPaymentModel>> getFailedPayments(
    dynamic db,
    String accountId,
  ) async {
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'accountId = ? AND paymentStatus = ?',
      whereArgs: [accountId, 'FAILED'],
      orderBy: 'paymentDate DESC, createdAt DESC',
    );

    return List.generate(maps.length, (i) => fromMap(maps[i]));
  }

  // Get pending payments for a specific account
  static Future<List<AccountPaymentModel>> getPendingPayments(
    dynamic db,
    String accountId,
  ) async {
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'accountId = ? AND paymentStatus = ?',
      whereArgs: [accountId, 'PENDING'],
      orderBy: 'paymentDate DESC, createdAt DESC',
    );

    return List.generate(maps.length, (i) => fromMap(maps[i]));
  }

  // Get refunded payments for a specific account
  static Future<List<AccountPaymentModel>> getRefundedPayments(
    dynamic db,
    String accountId,
  ) async {
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'accountId = ? AND isRefunded = 1',
      whereArgs: [accountId],
      orderBy: 'refundedDate DESC, createdAt DESC',
    );

    return List.generate(maps.length, (i) => fromMap(maps[i]));
  }

  // Update a payment
  static Future<int> update(dynamic db, AccountPaymentModel payment) async {
    final map = toMap(payment);
    map['updated_at'] = DateTime.now().toIso8601String();

    return await db.update(
      tableName,
      map,
      where: 'id = ?',
      whereArgs: [payment.id],
    );
  }

  // Update payment status
  static Future<int> updatePaymentStatus(
    dynamic db,
    String paymentId,
    String newStatus,
  ) async {
    final now = DateTime.now().toIso8601String();
    return await db.update(
      tableName,
      {'paymentStatus': newStatus, 'updatedAt': now, 'updated_at': now},
      where: 'id = ?',
      whereArgs: [paymentId],
    );
  }

  // Mark payment as processed
  static Future<int> markAsProcessed(
    dynamic db,
    String paymentId,
    DateTime processedDate,
  ) async {
    final now = DateTime.now().toIso8601String();
    return await db.update(
      tableName,
      {
        'processedDate': processedDate.toIso8601String(),
        'updatedAt': now,
        'updated_at': now,
      },
      where: 'id = ?',
      whereArgs: [paymentId],
    );
  }

  // Mark payment as refunded
  static Future<int> markAsRefunded(
    dynamic db,
    String paymentId,
    double refundedAmount,
    DateTime refundedDate,
    String refundReason,
  ) async {
    final now = DateTime.now().toIso8601String();
    return await db.update(
      tableName,
      {
        'isRefunded': 1,
        'refundedAmount': refundedAmount,
        'refundedDate': refundedDate.toIso8601String(),
        'refundReason': refundReason,
        'updatedAt': now,
        'updated_at': now,
      },
      where: 'id = ?',
      whereArgs: [paymentId],
    );
  }

  // Delete a payment
  static Future<int> delete(dynamic db, String id) async {
    return await db.delete(tableName, where: 'id = ?', whereArgs: [id]);
  }

  // Delete payments by account ID
  static Future<int> deleteByAccountId(dynamic db, String accountId) async {
    return await db.delete(
      tableName,
      where: 'accountId = ?',
      whereArgs: [accountId],
    );
  }

  // Delete all payments
  static Future<int> deleteAll(dynamic db) async {
    return await db.delete(tableName);
  }

  // Get count of payments for a specific account
  static Future<int> getCountByAccountId(dynamic db, String accountId) async {
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
    String paymentStatus,
  ) async {
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $tableName WHERE accountId = ? AND paymentStatus = ?',
      [accountId, paymentStatus],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Get count by type for a specific account
  static Future<int> getCountByType(
    dynamic db,
    String accountId,
    String paymentType,
  ) async {
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $tableName WHERE accountId = ? AND paymentType = ?',
      [accountId, paymentType],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Get total count of all payments
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
    String paymentStatus,
  ) async {
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM $tableName WHERE accountId = ? AND paymentStatus = ?',
      [accountId, paymentStatus],
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

  // Get total refunded amount for a specific account
  static Future<double> getTotalRefundedAmountByAccountId(
    dynamic db,
    String accountId,
  ) async {
    final result = await db.rawQuery(
      'SELECT SUM(refundedAmount) as total FROM $tableName WHERE accountId = ? AND isRefunded = 1',
      [accountId],
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  // Check if a payment exists
  static Future<bool> exists(dynamic db, String id) async {
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $tableName WHERE id = ?',
      [id],
    );
    return (Sqflite.firstIntValue(result) ?? 0) > 0;
  }

  // Search payments by description or notes
  static Future<List<AccountPaymentModel>> searchByText(
    dynamic db,
    String accountId,
    String searchTerm,
  ) async {
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'accountId = ? AND (description LIKE ? OR notes LIKE ?)',
      whereArgs: [accountId, '%$searchTerm%', '%$searchTerm%'],
      orderBy: 'paymentDate DESC, createdAt DESC',
    );

    return List.generate(maps.length, (i) => fromMap(maps[i]));
  }

  // Get payments by transaction ID
  static Future<AccountPaymentModel?> getByTransactionId(
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

  // Get payments by reference number
  static Future<List<AccountPaymentModel>> getByReferenceNumber(
    dynamic db,
    String accountId,
    String referenceNumber,
  ) async {
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'accountId = ? AND referenceNumber = ?',
      whereArgs: [accountId, referenceNumber],
      orderBy: 'paymentDate DESC, createdAt DESC',
    );

    return List.generate(maps.length, (i) => fromMap(maps[i]));
  }

  // Get payments by currency for a specific account
  static Future<List<AccountPaymentModel>> getByCurrency(
    dynamic db,
    String accountId,
    String currency,
  ) async {
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'accountId = ? AND currency = ?',
      whereArgs: [accountId, currency],
      orderBy: 'paymentDate DESC, createdAt DESC',
    );

    return List.generate(maps.length, (i) => fromMap(maps[i]));
  }
}
