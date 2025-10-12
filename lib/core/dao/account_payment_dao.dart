import 'dart:convert';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:logger/logger.dart';
import '../../features/accounts/data/models/account_payment_model.dart';

class AccountPaymentDao {
  static const String tableName = 'account_payments';
  static final Logger _logger = Logger();

  // Column names constants
  static const String columnId = 'id';
  static const String columnAccountId = 'accountId';
  static const String columnPaymentNumber = 'paymentNumber';
  static const String columnPaymentExternalKey = 'paymentExternalKey';
  static const String columnAuthAmount = 'authAmount';
  static const String columnCapturedAmount = 'capturedAmount';
  static const String columnPurchasedAmount = 'purchasedAmount';
  static const String columnRefundedAmount = 'refundedAmount';
  static const String columnCreditedAmount = 'creditedAmount';
  static const String columnCurrency = 'currency';
  static const String columnPaymentMethodId = 'paymentMethodId';
  static const String columnTransactions = 'transactions';
  static const String columnPaymentAttempts = 'paymentAttempts';
  static const String columnAuditLogs = 'auditLogs';
  static const String columnCreatedAt = 'created_at';
  static const String columnUpdatedAt = 'updated_at';
  // Additional columns for extended functionality
  static const String columnPaymentStatus = 'paymentStatus';
  static const String columnPaymentType = 'paymentType';
  static const String columnIsRefunded = 'isRefunded';
  static const String columnRefundedDate = 'refundedDate';
  static const String columnRefundReason = 'refundReason';
  static const String columnProcessedDate = 'processedDate';
  static const String columnDescription = 'description';
  static const String columnNotes = 'notes';
  static const String columnTransactionId = 'transactionId';
  static const String columnReferenceNumber = 'referenceNumber';

  static const String createTableSQL =
      '''
    CREATE TABLE $tableName (
      $columnId TEXT PRIMARY KEY,
      $columnAccountId TEXT NOT NULL,
      $columnPaymentNumber TEXT,
      $columnPaymentExternalKey TEXT,
      $columnAuthAmount REAL NOT NULL,
      $columnCapturedAmount REAL NOT NULL,
      $columnPurchasedAmount REAL NOT NULL,
      $columnRefundedAmount REAL NOT NULL,
      $columnCreditedAmount REAL NOT NULL,
      $columnCurrency TEXT NOT NULL,
      $columnPaymentMethodId TEXT NOT NULL,
      $columnTransactions TEXT NOT NULL,
      $columnPaymentAttempts TEXT,
      $columnAuditLogs TEXT,
      $columnCreatedAt TEXT NOT NULL,
      $columnUpdatedAt TEXT NOT NULL,
      $columnPaymentStatus TEXT,
      $columnPaymentType TEXT,
      $columnIsRefunded INTEGER DEFAULT 0,
      $columnRefundedDate TEXT,
      $columnRefundReason TEXT,
      $columnProcessedDate TEXT,
      $columnDescription TEXT,
      $columnNotes TEXT,
      $columnTransactionId TEXT,
      $columnReferenceNumber TEXT
    )
  ''';

  static Map<String, dynamic> toMap(AccountPaymentModel payment) {
    final now = DateTime.now().toIso8601String();
    return {
      columnId: payment.id,
      columnAccountId: payment.accountId,
      columnPaymentNumber: payment.paymentNumber,
      columnPaymentExternalKey: payment.paymentExternalKey,
      columnAuthAmount: payment.authAmount,
      columnCapturedAmount: payment.capturedAmount,
      columnPurchasedAmount: payment.purchasedAmount,
      columnRefundedAmount: payment.refundedAmount,
      columnCreditedAmount: payment.creditedAmount,
      columnCurrency: payment.currency,
      columnPaymentMethodId: payment.paymentMethodId,
      columnTransactions: jsonEncode(
        payment.transactions.map((t) => t.toJson()).toList(),
      ),
      columnPaymentAttempts: payment.paymentAttempts != null
          ? jsonEncode(payment.paymentAttempts)
          : null,
      columnAuditLogs: payment.auditLogs != null
          ? jsonEncode(payment.auditLogs)
          : null,
      columnCreatedAt: now,
      columnUpdatedAt: now,
    };
  }

  static AccountPaymentModel fromMap(Map<String, dynamic> map) {
    return AccountPaymentModel(
      id: map[columnId] as String,
      accountId: map[columnAccountId] as String,
      paymentNumber: map[columnPaymentNumber] as String?,
      paymentExternalKey: map[columnPaymentExternalKey] as String?,
      authAmount: map[columnAuthAmount] as double,
      capturedAmount: map[columnCapturedAmount] as double,
      purchasedAmount: map[columnPurchasedAmount] as double,
      refundedAmount: map[columnRefundedAmount] as double,
      creditedAmount: map[columnCreditedAmount] as double,
      currency: map[columnCurrency] as String,
      paymentMethodId: map[columnPaymentMethodId] as String,
      transactions: (jsonDecode(map[columnTransactions] as String) as List)
          .map(
            (t) => PaymentTransactionModel.fromJson(t as Map<String, dynamic>),
          )
          .toList(),
      paymentAttempts: map[columnPaymentAttempts] != null
          ? jsonDecode(map[columnPaymentAttempts] as String) as List
          : null,
      auditLogs: map[columnAuditLogs] != null
          ? jsonDecode(map[columnAuditLogs] as String) as List
          : null,
    );
  }

  /// Insert or update a payment
  static Future<void> insertOrUpdate(
    Database db,
    AccountPaymentModel payment,
  ) async {
    try {
      final map = toMap(payment);
      await db.insert(
        tableName,
        map,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      _logger.d('Account payment inserted/updated successfully: ${payment.id}');
    } catch (e) {
      _logger.e('Error inserting account payment: $e');
      rethrow;
    }
  }

  /// Insert multiple payments
  static Future<void> insertMultiple(
    Database db,
    List<AccountPaymentModel> payments,
  ) async {
    try {
      await db.transaction((txn) async {
        for (final payment in payments) {
          final map = toMap(payment);
          await txn.insert(
            tableName,
            map,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      });
      _logger.d('Inserted ${payments.length} account payments successfully');
    } catch (e) {
      _logger.e('Error inserting multiple account payments: $e');
      rethrow;
    }
  }

  /// Get all payments for a specific account
  static Future<List<AccountPaymentModel>> getByAccountId(
    Database db,
    String accountId,
  ) async {
    try {
      _logger.d('Retrieving account payments for accountId: $accountId');
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: '$columnAccountId = ?',
        whereArgs: [accountId],
        orderBy: '$columnCreatedAt DESC, $columnUpdatedAt DESC',
      );
      _logger.d('Database query returned ${maps.length} rows');

      final result = List.generate(maps.length, (i) => fromMap(maps[i]));
      _logger.d('Generated ${result.length} AccountPaymentModel objects');
      return result;
    } catch (e) {
      _logger.e('Error retrieving account payments by account ID: $e');
      rethrow;
    }
  }

  /// Get a specific payment by ID
  static Future<AccountPaymentModel?> getById(Database db, String id) async {
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: '$columnId = ?',
        whereArgs: [id],
        limit: 1,
      );

      if (maps.isNotEmpty) {
        _logger.d('Account payment retrieved successfully: $id');
        return fromMap(maps.first);
      }
      _logger.d('Account payment not found: $id');
      return null;
    } catch (e) {
      _logger.e('Error retrieving account payment by ID: $e');
      rethrow;
    }
  }

  /// Get payments by payment method ID
  static Future<List<AccountPaymentModel>> getByPaymentMethodId(
    Database db,
    String accountId,
    String paymentMethodId,
  ) async {
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: '$columnAccountId = ? AND $columnPaymentMethodId = ?',
        whereArgs: [accountId, paymentMethodId],
        orderBy: '$columnCreatedAt DESC, $columnUpdatedAt DESC',
      );

      final payments = List.generate(maps.length, (i) => fromMap(maps[i]));
      _logger.d(
        'Retrieved ${payments.length} payments for payment method: $paymentMethodId and account: $accountId',
      );
      return payments;
    } catch (e) {
      _logger.e('Error retrieving payments by payment method ID: $e');
      rethrow;
    }
  }

  /// Get payments by date range for a specific account
  static Future<List<AccountPaymentModel>> getByDateRange(
    Database db,
    String accountId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: '$columnAccountId = ? AND $columnCreatedAt BETWEEN ? AND ?',
        whereArgs: [
          accountId,
          startDate.toIso8601String(),
          endDate.toIso8601String(),
        ],
        orderBy: '$columnCreatedAt DESC, $columnUpdatedAt DESC',
      );

      final payments = List.generate(maps.length, (i) => fromMap(maps[i]));
      _logger.d(
        'Retrieved ${payments.length} payments for account: $accountId between ${startDate.toIso8601String()} and ${endDate.toIso8601String()}',
      );
      return payments;
    } catch (e) {
      _logger.e('Error retrieving payments by date range: $e');
      rethrow;
    }
  }

  /// Get payments with pagination
  static Future<List<AccountPaymentModel>> getWithPagination(
    Database db,
    String accountId,
    int page,
    int pageSize,
  ) async {
    try {
      final offset = page * pageSize;
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: '$columnAccountId = ?',
        whereArgs: [accountId],
        orderBy: '$columnCreatedAt DESC, $columnUpdatedAt DESC',
        limit: pageSize,
        offset: offset,
      );

      final payments = List.generate(maps.length, (i) => fromMap(maps[i]));
      _logger.d(
        'Retrieved ${payments.length} payments for account: $accountId (page $page, size $pageSize)',
      );
      return payments;
    } catch (e) {
      _logger.e('Error retrieving payments with pagination: $e');
      rethrow;
    }
  }

  /// Get all payments
  static Future<List<AccountPaymentModel>> getAll(Database db) async {
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        orderBy:
            '$columnAccountId, $columnCreatedAt DESC, $columnUpdatedAt DESC',
      );

      final payments = List.generate(maps.length, (i) => fromMap(maps[i]));
      _logger.d('Retrieved ${payments.length} account payments');
      return payments;
    } catch (e) {
      _logger.e('Error retrieving all account payments: $e');
      rethrow;
    }
  }

  /// Update a payment
  static Future<void> update(Database db, AccountPaymentModel payment) async {
    try {
      final map = toMap(payment);
      map[columnUpdatedAt] = DateTime.now().toIso8601String();

      await db.update(
        tableName,
        map,
        where: '$columnId = ?',
        whereArgs: [payment.id],
      );
      _logger.d('Account payment updated successfully: ${payment.id}');
    } catch (e) {
      _logger.e('Error updating account payment: $e');
      rethrow;
    }
  }

  /// Delete a payment
  static Future<void> delete(Database db, String id) async {
    try {
      await db.delete(tableName, where: '$columnId = ?', whereArgs: [id]);
      _logger.d('Account payment deleted successfully: $id');
    } catch (e) {
      _logger.e('Error deleting account payment: $e');
      rethrow;
    }
  }

  /// Delete payments by account ID
  static Future<void> deleteByAccountId(Database db, String accountId) async {
    try {
      await db.delete(
        tableName,
        where: '$columnAccountId = ?',
        whereArgs: [accountId],
      );
      _logger.d(
        'Account payments deleted successfully for account: $accountId',
      );
    } catch (e) {
      _logger.e('Error deleting account payments by account ID: $e');
      rethrow;
    }
  }

  /// Delete all payments
  static Future<void> deleteAll(Database db) async {
    try {
      await db.delete(tableName);
      _logger.d('All account payments deleted successfully');
    } catch (e) {
      _logger.e('Error deleting all account payments: $e');
      rethrow;
    }
  }

  /// Get count of payments for a specific account
  static Future<int> getCountByAccountId(Database db, String accountId) async {
    try {
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM $tableName WHERE $columnAccountId = ?',
        [accountId],
      );
      final count = Sqflite.firstIntValue(result) ?? 0;
      _logger.d('Account payment count for account $accountId: $count');
      return count;
    } catch (e) {
      _logger.e('Error getting account payment count by account ID: $e');
      rethrow;
    }
  }

  /// Get total count of all payments
  static Future<int> getTotalCount(Database db) async {
    try {
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM $tableName',
      );
      final count = Sqflite.firstIntValue(result) ?? 0;
      _logger.d('Total account payment count: $count');
      return count;
    } catch (e) {
      _logger.e('Error getting total account payment count: $e');
      rethrow;
    }
  }

  /// Get total amount for a specific account
  static Future<double> getTotalAmountByAccountId(
    Database db,
    String accountId,
  ) async {
    try {
      final result = await db.rawQuery(
        'SELECT SUM($columnCapturedAmount) as total FROM $tableName WHERE $columnAccountId = ?',
        [accountId],
      );
      final total = (result.first['total'] as num?)?.toDouble() ?? 0.0;
      _logger.d('Total amount for account $accountId: $total');
      return total;
    } catch (e) {
      _logger.e('Error getting total amount by account ID: $e');
      rethrow;
    }
  }

  /// Get total refunded amount for a specific account
  static Future<double> getTotalRefundedAmountByAccountId(
    Database db,
    String accountId,
  ) async {
    try {
      final result = await db.rawQuery(
        'SELECT SUM($columnRefundedAmount) as total FROM $tableName WHERE $columnAccountId = ?',
        [accountId],
      );
      final total = (result.first['total'] as num?)?.toDouble() ?? 0.0;
      _logger.d('Total refunded amount for account $accountId: $total');
      return total;
    } catch (e) {
      _logger.e('Error getting total refunded amount by account ID: $e');
      rethrow;
    }
  }

  /// Check if a payment exists
  static Future<bool> exists(Database db, String id) async {
    try {
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM $tableName WHERE $columnId = ?',
        [id],
      );
      final exists = (Sqflite.firstIntValue(result) ?? 0) > 0;
      _logger.d('Account payment exists check for $id: $exists');
      return exists;
    } catch (e) {
      _logger.e('Error checking if account payment exists: $e');
      rethrow;
    }
  }

  /// Search payments by payment number or external key
  static Future<List<AccountPaymentModel>> search(
    Database db,
    String accountId,
    String searchQuery,
  ) async {
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where:
            '$columnAccountId = ? AND ($columnPaymentNumber LIKE ? OR $columnPaymentExternalKey LIKE ?)',
        whereArgs: [accountId, '%$searchQuery%', '%$searchQuery%'],
        orderBy: '$columnCreatedAt DESC, $columnUpdatedAt DESC',
      );

      final payments = List.generate(maps.length, (i) => fromMap(maps[i]));
      _logger.d(
        'Found ${payments.length} payments matching "$searchQuery" for account: $accountId',
      );
      return payments;
    } catch (e) {
      _logger.e('Error searching account payments: $e');
      rethrow;
    }
  }

  /// Get payments by currency for a specific account
  static Future<List<AccountPaymentModel>> getByCurrency(
    Database db,
    String accountId,
    String currency,
  ) async {
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: '$columnAccountId = ? AND $columnCurrency = ?',
        whereArgs: [accountId, currency],
        orderBy: '$columnCreatedAt DESC, $columnUpdatedAt DESC',
      );

      final payments = List.generate(maps.length, (i) => fromMap(maps[i]));
      _logger.d(
        'Retrieved ${payments.length} payments for currency $currency and account: $accountId',
      );
      return payments;
    } catch (e) {
      _logger.e('Error retrieving payments by currency: $e');
      rethrow;
    }
  }

  /// Get payments by external key
  static Future<AccountPaymentModel?> getByExternalKey(
    Database db,
    String externalKey,
  ) async {
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: '$columnPaymentExternalKey = ?',
        whereArgs: [externalKey],
        limit: 1,
      );

      if (maps.isNotEmpty) {
        _logger.d('Account payment retrieved by external key: $externalKey');
        return fromMap(maps.first);
      }
      _logger.d('Account payment not found by external key: $externalKey');
      return null;
    } catch (e) {
      _logger.e('Error retrieving account payment by external key: $e');
      rethrow;
    }
  }

  /// Get payments by payment number
  static Future<List<AccountPaymentModel>> getByPaymentNumber(
    Database db,
    String accountId,
    String paymentNumber,
  ) async {
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: '$columnAccountId = ? AND $columnPaymentNumber = ?',
        whereArgs: [accountId, paymentNumber],
        orderBy: '$columnCreatedAt DESC, $columnUpdatedAt DESC',
      );

      final payments = List.generate(maps.length, (i) => fromMap(maps[i]));
      _logger.d(
        'Retrieved ${payments.length} payments for payment number $paymentNumber and account: $accountId',
      );
      return payments;
    } catch (e) {
      _logger.e('Error retrieving payments by payment number: $e');
      rethrow;
    }
  }

  /// Get total amounts by currency for a specific account
  static Future<Map<String, double>> getTotalAmountsByCurrency(
    Database db,
    String accountId,
  ) async {
    try {
      final result = await db.rawQuery(
        'SELECT $columnCurrency, SUM($columnCapturedAmount) as total FROM $tableName WHERE $columnAccountId = ? GROUP BY $columnCurrency',
        [accountId],
      );

      final totals = <String, double>{};
      for (final row in result) {
        final currency = row[columnCurrency] as String;
        final total = row['total'] as double? ?? 0.0;
        totals[currency] = total;
      }

      _logger.d(
        'Retrieved total amounts by currency for account $accountId: $totals',
      );
      return totals;
    } catch (e) {
      _logger.e('Error getting total amounts by currency: $e');
      rethrow;
    }
  }

  /// Get recent payments for a specific account
  static Future<List<AccountPaymentModel>> getRecentPayments(
    Database db,
    String accountId,
    int limit,
  ) async {
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: '$columnAccountId = ?',
        whereArgs: [accountId],
        orderBy: '$columnCreatedAt DESC',
        limit: limit,
      );

      final payments = List.generate(maps.length, (i) => fromMap(maps[i]));
      _logger.d(
        'Retrieved ${payments.length} recent payments for account: $accountId',
      );
      return payments;
    } catch (e) {
      _logger.e('Error retrieving recent payments: $e');
      rethrow;
    }
  }

  /// Get payments with high amounts (above threshold)
  static Future<List<AccountPaymentModel>> getHighAmountPayments(
    Database db,
    String accountId,
    double threshold,
  ) async {
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: '$columnAccountId = ? AND $columnCapturedAmount > ?',
        whereArgs: [accountId, threshold],
        orderBy: '$columnCapturedAmount DESC, $columnCreatedAt DESC',
      );

      final payments = List.generate(maps.length, (i) => fromMap(maps[i]));
      _logger.d(
        'Retrieved ${payments.length} high amount payments (>$threshold) for account: $accountId',
      );
      return payments;
    } catch (e) {
      _logger.e('Error retrieving high amount payments: $e');
      rethrow;
    }
  }

  /// Get payments by status for a specific account
  static Future<List<AccountPaymentModel>> getByStatus(
    Database db,
    String accountId,
    String paymentStatus,
  ) async {
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: '$columnAccountId = ? AND $columnPaymentStatus = ?',
        whereArgs: [accountId, paymentStatus],
        orderBy: '$columnCreatedAt DESC, $columnUpdatedAt DESC',
      );
      final payments = List.generate(maps.length, (i) => fromMap(maps[i]));
      _logger.d(
        'Retrieved ${payments.length} $paymentStatus payments for account: $accountId',
      );
      return payments;
    } catch (e) {
      _logger.e('Error retrieving payments by status: $e');
      rethrow;
    }
  }

  /// Get payments by type for a specific account
  static Future<List<AccountPaymentModel>> getByType(
    Database db,
    String accountId,
    String paymentType,
  ) async {
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: '$columnAccountId = ? AND $columnPaymentType = ?',
        whereArgs: [accountId, paymentType],
        orderBy: '$columnCreatedAt DESC, $columnUpdatedAt DESC',
      );
      final payments = List.generate(maps.length, (i) => fromMap(maps[i]));
      _logger.d(
        'Retrieved ${payments.length} $paymentType payments for account: $accountId',
      );
      return payments;
    } catch (e) {
      _logger.e('Error retrieving payments by type: $e');
      rethrow;
    }
  }

  /// Get successful payments for a specific account
  static Future<List<AccountPaymentModel>> getSuccessfulPayments(
    Database db,
    String accountId,
  ) async {
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: '$columnAccountId = ? AND $columnPaymentStatus = ?',
        whereArgs: [accountId, 'SUCCESS'],
        orderBy: '$columnCreatedAt DESC, $columnUpdatedAt DESC',
      );
      final payments = List.generate(maps.length, (i) => fromMap(maps[i]));
      _logger.d(
        'Retrieved ${payments.length} successful payments for account: $accountId',
      );
      return payments;
    } catch (e) {
      _logger.e('Error retrieving successful payments: $e');
      rethrow;
    }
  }

  /// Get failed payments for a specific account
  static Future<List<AccountPaymentModel>> getFailedPayments(
    Database db,
    String accountId,
  ) async {
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: '$columnAccountId = ? AND $columnPaymentStatus = ?',
        whereArgs: [accountId, 'FAILED'],
        orderBy: '$columnCreatedAt DESC, $columnUpdatedAt DESC',
      );
      final payments = List.generate(maps.length, (i) => fromMap(maps[i]));
      _logger.d(
        'Retrieved ${payments.length} failed payments for account: $accountId',
      );
      return payments;
    } catch (e) {
      _logger.e('Error retrieving failed payments: $e');
      rethrow;
    }
  }

  /// Get pending payments for a specific account
  static Future<List<AccountPaymentModel>> getPendingPayments(
    Database db,
    String accountId,
  ) async {
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: '$columnAccountId = ? AND $columnPaymentStatus = ?',
        whereArgs: [accountId, 'PENDING'],
        orderBy: '$columnCreatedAt DESC, $columnUpdatedAt DESC',
      );
      final payments = List.generate(maps.length, (i) => fromMap(maps[i]));
      _logger.d(
        'Retrieved ${payments.length} pending payments for account: $accountId',
      );
      return payments;
    } catch (e) {
      _logger.e('Error retrieving pending payments: $e');
      rethrow;
    }
  }

  /// Get refunded payments for a specific account
  static Future<List<AccountPaymentModel>> getRefundedPayments(
    Database db,
    String accountId,
  ) async {
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: '$columnAccountId = ? AND $columnIsRefunded = 1',
        whereArgs: [accountId],
        orderBy: '$columnRefundedDate DESC, $columnCreatedAt DESC',
      );
      final payments = List.generate(maps.length, (i) => fromMap(maps[i]));
      _logger.d(
        'Retrieved ${payments.length} refunded payments for account: $accountId',
      );
      return payments;
    } catch (e) {
      _logger.e('Error retrieving refunded payments: $e');
      rethrow;
    }
  }

  /// Search payments by description or notes
  static Future<List<AccountPaymentModel>> searchByText(
    Database db,
    String accountId,
    String searchTerm,
  ) async {
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where:
            '$columnAccountId = ? AND ($columnDescription LIKE ? OR $columnNotes LIKE ?)',
        whereArgs: [accountId, '%$searchTerm%', '%$searchTerm%'],
        orderBy: '$columnCreatedAt DESC, $columnUpdatedAt DESC',
      );
      final payments = List.generate(maps.length, (i) => fromMap(maps[i]));
      _logger.d(
        'Found ${payments.length} payments matching "$searchTerm" for account $accountId',
      );
      return payments;
    } catch (e) {
      _logger.e('Error searching payments by text: $e');
      rethrow;
    }
  }

  /// Get payments by transaction ID
  static Future<AccountPaymentModel?> getByTransactionId(
    Database db,
    String transactionId,
  ) async {
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: '$columnTransactionId = ?',
        whereArgs: [transactionId],
        limit: 1,
      );

      if (maps.isNotEmpty) {
        _logger.d('Payment retrieved by transaction ID: $transactionId');
        return fromMap(maps.first);
      }
      _logger.d('Payment not found by transaction ID: $transactionId');
      return null;
    } catch (e) {
      _logger.e('Error retrieving payment by transaction ID: $e');
      rethrow;
    }
  }

  /// Get payments by reference number
  static Future<List<AccountPaymentModel>> getByReferenceNumber(
    Database db,
    String accountId,
    String referenceNumber,
  ) async {
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: '$columnAccountId = ? AND $columnReferenceNumber = ?',
        whereArgs: [accountId, referenceNumber],
        orderBy: '$columnCreatedAt DESC, $columnUpdatedAt DESC',
      );
      final payments = List.generate(maps.length, (i) => fromMap(maps[i]));
      _logger.d(
        'Retrieved ${payments.length} payments for reference number $referenceNumber for account $accountId',
      );
      return payments;
    } catch (e) {
      _logger.e('Error retrieving payments by reference number: $e');
      rethrow;
    }
  }

  /// Update payment status
  static Future<void> updatePaymentStatus(
    Database db,
    String paymentId,
    String newStatus,
  ) async {
    try {
      final now = DateTime.now().toIso8601String();
      await db.update(
        tableName,
        {columnPaymentStatus: newStatus, columnUpdatedAt: now},
        where: '$columnId = ?',
        whereArgs: [paymentId],
      );
      _logger.d('Payment status updated for $paymentId to $newStatus');
    } catch (e) {
      _logger.e('Error updating payment status: $e');
      rethrow;
    }
  }

  /// Mark payment as processed
  static Future<void> markAsProcessed(
    Database db,
    String paymentId,
    DateTime processedDate,
  ) async {
    try {
      final now = DateTime.now().toIso8601String();
      await db.update(
        tableName,
        {
          columnProcessedDate: processedDate.toIso8601String(),
          columnUpdatedAt: now,
        },
        where: '$columnId = ?',
        whereArgs: [paymentId],
      );
      _logger.d('Payment $paymentId marked as processed');
    } catch (e) {
      _logger.e('Error marking payment as processed: $e');
      rethrow;
    }
  }

  /// Mark payment as refunded
  static Future<void> markAsRefunded(
    Database db,
    String paymentId,
    double refundedAmount,
    DateTime refundedDate,
    String refundReason,
  ) async {
    try {
      final now = DateTime.now().toIso8601String();
      await db.update(
        tableName,
        {
          columnIsRefunded: 1,
          columnRefundedAmount: refundedAmount,
          columnRefundedDate: refundedDate.toIso8601String(),
          columnRefundReason: refundReason,
          columnUpdatedAt: now,
        },
        where: '$columnId = ?',
        whereArgs: [paymentId],
      );
      _logger.d('Payment $paymentId marked as refunded');
    } catch (e) {
      _logger.e('Error marking payment as refunded: $e');
      rethrow;
    }
  }

  /// Get count by status for a specific account
  static Future<int> getCountByStatus(
    Database db,
    String accountId,
    String paymentStatus,
  ) async {
    try {
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM $tableName WHERE $columnAccountId = ? AND $columnPaymentStatus = ?',
        [accountId, paymentStatus],
      );
      final count = Sqflite.firstIntValue(result) ?? 0;
      _logger.d(
        'Count of $paymentStatus payments for account $accountId: $count',
      );
      return count;
    } catch (e) {
      _logger.e('Error getting count of payments by status: $e');
      rethrow;
    }
  }

  /// Get count by type for a specific account
  static Future<int> getCountByType(
    Database db,
    String accountId,
    String paymentType,
  ) async {
    try {
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM $tableName WHERE $columnAccountId = ? AND $columnPaymentType = ?',
        [accountId, paymentType],
      );
      final count = Sqflite.firstIntValue(result) ?? 0;
      _logger.d(
        'Count of $paymentType payments for account $accountId: $count',
      );
      return count;
    } catch (e) {
      _logger.e('Error getting count of payments by type: $e');
      rethrow;
    }
  }

  /// Get total amount by status for a specific account
  static Future<double> getTotalAmountByStatus(
    Database db,
    String accountId,
    String paymentStatus,
  ) async {
    try {
      final result = await db.rawQuery(
        'SELECT SUM($columnAuthAmount) as total FROM $tableName WHERE $columnAccountId = ? AND $columnPaymentStatus = ?',
        [accountId, paymentStatus],
      );
      final total = (result.first['total'] as num?)?.toDouble() ?? 0.0;
      _logger.d('Total $paymentStatus amount for account $accountId: $total');
      return total;
    } catch (e) {
      _logger.e('Error getting total amount by status: $e');
      rethrow;
    }
  }
}
