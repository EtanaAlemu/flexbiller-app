import 'dart:convert';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:logger/logger.dart';
import '../../features/accounts/data/models/account_invoice_payment_model.dart';

class AccountInvoicePaymentDao {
  static const String tableName = 'account_invoice_payments';
  static final Logger _logger = Logger();

  // Column names constants
  static const String columnId = 'id';
  static const String columnAccountId = 'accountId';
  static const String columnInvoiceId = 'invoiceId';
  static const String columnInvoiceNumber = 'invoiceNumber';
  static const String columnAmount = 'amount';
  static const String columnCurrency = 'currency';
  static const String columnPaymentMethod = 'paymentMethod';
  static const String columnStatus = 'status';
  static const String columnPaymentDate = 'paymentDate';
  static const String columnProcessedDate = 'processedDate';
  static const String columnTransactionId = 'transactionId';
  static const String columnNotes = 'notes';
  static const String columnMetadata = 'metadata';
  static const String columnCreatedAt = 'created_at';
  static const String columnUpdatedAt = 'updated_at';

  static const String createTableSQL =
      '''
    CREATE TABLE $tableName (
      $columnId TEXT PRIMARY KEY,
      $columnAccountId TEXT NOT NULL,
      $columnInvoiceId TEXT NOT NULL,
      $columnInvoiceNumber TEXT NOT NULL,
      $columnAmount REAL NOT NULL,
      $columnCurrency TEXT NOT NULL,
      $columnPaymentMethod TEXT NOT NULL,
      $columnStatus TEXT NOT NULL,
      $columnPaymentDate TEXT NOT NULL,
      $columnProcessedDate TEXT,
      $columnTransactionId TEXT,
      $columnNotes TEXT,
      $columnMetadata TEXT,
      $columnCreatedAt TEXT NOT NULL,
      $columnUpdatedAt TEXT NOT NULL
    )
  ''';

  static Map<String, dynamic> toMap(AccountInvoicePaymentModel payment) {
    final now = DateTime.now().toIso8601String();
    return {
      columnId: payment.id,
      columnAccountId: payment.accountId,
      columnInvoiceId: payment.invoiceId,
      columnInvoiceNumber: payment.invoiceNumber,
      columnAmount: payment.amount,
      columnCurrency: payment.currency,
      columnPaymentMethod: payment.paymentMethod,
      columnStatus: payment.status,
      columnPaymentDate: payment.paymentDate.toIso8601String(),
      columnProcessedDate: payment.processedDate?.toIso8601String(),
      columnTransactionId: payment.transactionId,
      columnNotes: payment.notes,
      columnMetadata: payment.metadata != null
          ? jsonEncode(payment.metadata)
          : null,
      columnCreatedAt: now,
      columnUpdatedAt: now,
    };
  }

  static AccountInvoicePaymentModel fromMap(Map<String, dynamic> map) {
    return AccountInvoicePaymentModel(
      id: map[columnId] as String,
      accountId: map[columnAccountId] as String,
      invoiceId: map[columnInvoiceId] as String,
      invoiceNumber: map[columnInvoiceNumber] as String,
      amount: map[columnAmount] as double,
      currency: map[columnCurrency] as String,
      paymentMethod: map[columnPaymentMethod] as String,
      status: map[columnStatus] as String,
      paymentDate: DateTime.parse(map[columnPaymentDate] as String),
      processedDate: map[columnProcessedDate] != null
          ? DateTime.parse(map[columnProcessedDate] as String)
          : null,
      transactionId: map[columnTransactionId] as String?,
      notes: map[columnNotes] as String?,
      metadata: map[columnMetadata] != null
          ? jsonDecode(map[columnMetadata] as String) as Map<String, dynamic>
          : null,
    );
  }

  /// Insert or update an invoice payment
  static Future<void> insertOrUpdate(
    Database db,
    AccountInvoicePaymentModel payment,
  ) async {
    try {
      final map = toMap(payment);
      await db.insert(
        tableName,
        map,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      _logger.d(
        'Account invoice payment inserted/updated successfully: ${payment.id}',
      );
    } catch (e) {
      _logger.e('Error inserting account invoice payment: $e');
      rethrow;
    }
  }

  /// Insert multiple invoice payments
  static Future<void> insertMultiple(
    Database db,
    List<AccountInvoicePaymentModel> payments,
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
      _logger.d(
        'Inserted ${payments.length} account invoice payments successfully',
      );
    } catch (e) {
      _logger.e('Error inserting multiple account invoice payments: $e');
      rethrow;
    }
  }

  /// Get all invoice payments for a specific account
  static Future<List<AccountInvoicePaymentModel>> getByAccountId(
    Database db,
    String accountId,
  ) async {
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: '$columnAccountId = ?',
        whereArgs: [accountId],
        orderBy: '$columnPaymentDate DESC',
      );

      final payments = List.generate(maps.length, (i) => fromMap(maps[i]));
      _logger.d(
        'Retrieved ${payments.length} invoice payments for account: $accountId',
      );
      return payments;
    } catch (e) {
      _logger.e('Error retrieving invoice payments by account ID: $e');
      rethrow;
    }
  }

  /// Get a specific invoice payment by ID
  static Future<AccountInvoicePaymentModel?> getById(
    Database db,
    String id,
  ) async {
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: '$columnId = ?',
        whereArgs: [id],
        limit: 1,
      );

      if (maps.isNotEmpty) {
        _logger.d('Account invoice payment retrieved successfully: $id');
        return fromMap(maps.first);
      }
      _logger.d('Account invoice payment not found: $id');
      return null;
    } catch (e) {
      _logger.e('Error retrieving account invoice payment by ID: $e');
      rethrow;
    }
  }

  /// Get invoice payments by status
  static Future<List<AccountInvoicePaymentModel>> getByStatus(
    Database db,
    String accountId,
    String status,
  ) async {
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: '$columnAccountId = ? AND $columnStatus = ?',
        whereArgs: [accountId, status],
        orderBy: '$columnPaymentDate DESC',
      );

      final payments = List.generate(maps.length, (i) => fromMap(maps[i]));
      _logger.d(
        'Retrieved ${payments.length} invoice payments with status $status for account: $accountId',
      );
      return payments;
    } catch (e) {
      _logger.e('Error retrieving invoice payments by status: $e');
      rethrow;
    }
  }

  /// Get invoice payments by date range
  static Future<List<AccountInvoicePaymentModel>> getByDateRange(
    Database db,
    String accountId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: '$columnAccountId = ? AND $columnPaymentDate BETWEEN ? AND ?',
        whereArgs: [
          accountId,
          startDate.toIso8601String(),
          endDate.toIso8601String(),
        ],
        orderBy: '$columnPaymentDate DESC',
      );

      final payments = List.generate(maps.length, (i) => fromMap(maps[i]));
      _logger.d(
        'Retrieved ${payments.length} invoice payments for account: $accountId between ${startDate.toIso8601String()} and ${endDate.toIso8601String()}',
      );
      return payments;
    } catch (e) {
      _logger.e('Error retrieving invoice payments by date range: $e');
      rethrow;
    }
  }

  /// Get invoice payments by payment method
  static Future<List<AccountInvoicePaymentModel>> getByPaymentMethod(
    Database db,
    String accountId,
    String paymentMethod,
  ) async {
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: '$columnAccountId = ? AND $columnPaymentMethod = ?',
        whereArgs: [accountId, paymentMethod],
        orderBy: '$columnPaymentDate DESC',
      );

      final payments = List.generate(maps.length, (i) => fromMap(maps[i]));
      _logger.d(
        'Retrieved ${payments.length} invoice payments for payment method $paymentMethod and account: $accountId',
      );
      return payments;
    } catch (e) {
      _logger.e('Error retrieving invoice payments by payment method: $e');
      rethrow;
    }
  }

  /// Get invoice payments by invoice number
  static Future<List<AccountInvoicePaymentModel>> getByInvoiceNumber(
    Database db,
    String accountId,
    String invoiceNumber,
  ) async {
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: '$columnAccountId = ? AND $columnInvoiceNumber = ?',
        whereArgs: [accountId, invoiceNumber],
        orderBy: '$columnPaymentDate DESC',
      );

      final payments = List.generate(maps.length, (i) => fromMap(maps[i]));
      _logger.d(
        'Retrieved ${payments.length} invoice payments for invoice number $invoiceNumber and account: $accountId',
      );
      return payments;
    } catch (e) {
      _logger.e('Error retrieving invoice payments by invoice number: $e');
      rethrow;
    }
  }

  /// Get invoice payments by invoice ID
  static Future<List<AccountInvoicePaymentModel>> getByInvoiceId(
    Database db,
    String accountId,
    String invoiceId,
  ) async {
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: '$columnAccountId = ? AND $columnInvoiceId = ?',
        whereArgs: [accountId, invoiceId],
        orderBy: '$columnPaymentDate DESC',
      );

      final payments = List.generate(maps.length, (i) => fromMap(maps[i]));
      _logger.d(
        'Retrieved ${payments.length} invoice payments for invoice ID $invoiceId and account: $accountId',
      );
      return payments;
    } catch (e) {
      _logger.e('Error retrieving invoice payments by invoice ID: $e');
      rethrow;
    }
  }

  /// Get invoice payments with pagination
  static Future<List<AccountInvoicePaymentModel>> getWithPagination(
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
        orderBy: '$columnPaymentDate DESC',
        limit: pageSize,
        offset: offset,
      );

      final payments = List.generate(maps.length, (i) => fromMap(maps[i]));
      _logger.d(
        'Retrieved ${payments.length} invoice payments for account: $accountId (page $page, size $pageSize)',
      );
      return payments;
    } catch (e) {
      _logger.e('Error retrieving invoice payments with pagination: $e');
      rethrow;
    }
  }

  /// Get all invoice payments
  static Future<List<AccountInvoicePaymentModel>> getAll(Database db) async {
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        orderBy: '$columnPaymentDate DESC',
      );

      final payments = List.generate(maps.length, (i) => fromMap(maps[i]));
      _logger.d('Retrieved ${payments.length} account invoice payments');
      return payments;
    } catch (e) {
      _logger.e('Error retrieving all account invoice payments: $e');
      rethrow;
    }
  }

  /// Update an invoice payment
  static Future<void> update(
    Database db,
    AccountInvoicePaymentModel payment,
  ) async {
    try {
      final map = toMap(payment);
      map[columnUpdatedAt] = DateTime.now().toIso8601String();

      await db.update(
        tableName,
        map,
        where: '$columnId = ?',
        whereArgs: [payment.id],
      );
      _logger.d('Account invoice payment updated successfully: ${payment.id}');
    } catch (e) {
      _logger.e('Error updating account invoice payment: $e');
      rethrow;
    }
  }

  /// Delete an invoice payment
  static Future<void> delete(Database db, String id) async {
    try {
      await db.delete(tableName, where: '$columnId = ?', whereArgs: [id]);
      _logger.d('Account invoice payment deleted successfully: $id');
    } catch (e) {
      _logger.e('Error deleting account invoice payment: $e');
      rethrow;
    }
  }

  /// Delete invoice payments by account ID
  static Future<void> deleteByAccountId(Database db, String accountId) async {
    try {
      await db.delete(
        tableName,
        where: '$columnAccountId = ?',
        whereArgs: [accountId],
      );
      _logger.d(
        'Account invoice payments deleted successfully for account: $accountId',
      );
    } catch (e) {
      _logger.e('Error deleting account invoice payments by account ID: $e');
      rethrow;
    }
  }

  /// Delete all invoice payments
  static Future<void> deleteAll(Database db) async {
    try {
      await db.delete(tableName);
      _logger.d('All account invoice payments deleted successfully');
    } catch (e) {
      _logger.e('Error deleting all account invoice payments: $e');
      rethrow;
    }
  }

  /// Get count of invoice payments for a specific account
  static Future<int> getCountByAccountId(Database db, String accountId) async {
    try {
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM $tableName WHERE $columnAccountId = ?',
        [accountId],
      );
      final count = Sqflite.firstIntValue(result) ?? 0;
      _logger.d('Account invoice payment count for account $accountId: $count');
      return count;
    } catch (e) {
      _logger.e(
        'Error getting account invoice payment count by account ID: $e',
      );
      rethrow;
    }
  }

  /// Get count by status for a specific account
  static Future<int> getCountByStatus(
    Database db,
    String accountId,
    String status,
  ) async {
    try {
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM $tableName WHERE $columnAccountId = ? AND $columnStatus = ?',
        [accountId, status],
      );
      final count = Sqflite.firstIntValue(result) ?? 0;
      _logger.d(
        'Account invoice payment count for account $accountId and status $status: $count',
      );
      return count;
    } catch (e) {
      _logger.e('Error getting account invoice payment count by status: $e');
      rethrow;
    }
  }

  /// Get total count of all invoice payments
  static Future<int> getTotalCount(Database db) async {
    try {
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM $tableName',
      );
      final count = Sqflite.firstIntValue(result) ?? 0;
      _logger.d('Total account invoice payment count: $count');
      return count;
    } catch (e) {
      _logger.e('Error getting total account invoice payment count: $e');
      rethrow;
    }
  }

  /// Get total amount by status for a specific account
  static Future<double> getTotalAmountByStatus(
    Database db,
    String accountId,
    String status,
  ) async {
    try {
      final result = await db.rawQuery(
        'SELECT SUM($columnAmount) as total FROM $tableName WHERE $columnAccountId = ? AND $columnStatus = ?',
        [accountId, status],
      );
      final total = (result.first['total'] as num?)?.toDouble() ?? 0.0;
      _logger.d(
        'Total amount for account $accountId and status $status: $total',
      );
      return total;
    } catch (e) {
      _logger.e('Error getting total amount by status: $e');
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
        'SELECT SUM($columnAmount) as total FROM $tableName WHERE $columnAccountId = ?',
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

  /// Check if an invoice payment exists
  static Future<bool> exists(Database db, String id) async {
    try {
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM $tableName WHERE $columnId = ?',
        [id],
      );
      final exists = (Sqflite.firstIntValue(result) ?? 0) > 0;
      _logger.d('Account invoice payment exists check for $id: $exists');
      return exists;
    } catch (e) {
      _logger.e('Error checking if account invoice payment exists: $e');
      rethrow;
    }
  }

  /// Search invoice payments by notes
  static Future<List<AccountInvoicePaymentModel>> searchByNotes(
    Database db,
    String accountId,
    String searchTerm,
  ) async {
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: '$columnAccountId = ? AND $columnNotes LIKE ?',
        whereArgs: [accountId, '%$searchTerm%'],
        orderBy: '$columnPaymentDate DESC',
      );

      final payments = List.generate(maps.length, (i) => fromMap(maps[i]));
      _logger.d(
        'Found ${payments.length} invoice payments matching "$searchTerm" in notes for account: $accountId',
      );
      return payments;
    } catch (e) {
      _logger.e('Error searching invoice payments by notes: $e');
      rethrow;
    }
  }

  /// Get invoice payments by transaction ID
  static Future<AccountInvoicePaymentModel?> getByTransactionId(
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
        _logger.d(
          'Account invoice payment retrieved by transaction ID: $transactionId',
        );
        return fromMap(maps.first);
      }
      _logger.d(
        'Account invoice payment not found by transaction ID: $transactionId',
      );
      return null;
    } catch (e) {
      _logger.e(
        'Error retrieving account invoice payment by transaction ID: $e',
      );
      rethrow;
    }
  }

  /// Get invoice payments by currency
  static Future<List<AccountInvoicePaymentModel>> getByCurrency(
    Database db,
    String accountId,
    String currency,
  ) async {
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: '$columnAccountId = ? AND $columnCurrency = ?',
        whereArgs: [accountId, currency],
        orderBy: '$columnPaymentDate DESC',
      );

      final payments = List.generate(maps.length, (i) => fromMap(maps[i]));
      _logger.d(
        'Retrieved ${payments.length} invoice payments for currency $currency and account: $accountId',
      );
      return payments;
    } catch (e) {
      _logger.e('Error retrieving invoice payments by currency: $e');
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
        'SELECT $columnCurrency, SUM($columnAmount) as total FROM $tableName WHERE $columnAccountId = ? GROUP BY $columnCurrency',
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

  /// Get recent invoice payments for a specific account
  static Future<List<AccountInvoicePaymentModel>> getRecentPayments(
    Database db,
    String accountId,
    int limit,
  ) async {
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: '$columnAccountId = ?',
        whereArgs: [accountId],
        orderBy: '$columnPaymentDate DESC',
        limit: limit,
      );

      final payments = List.generate(maps.length, (i) => fromMap(maps[i]));
      _logger.d(
        'Retrieved ${payments.length} recent invoice payments for account: $accountId',
      );
      return payments;
    } catch (e) {
      _logger.e('Error retrieving recent invoice payments: $e');
      rethrow;
    }
  }

  /// Get invoice payments with high amounts (above threshold)
  static Future<List<AccountInvoicePaymentModel>> getHighAmountPayments(
    Database db,
    String accountId,
    double threshold,
  ) async {
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: '$columnAccountId = ? AND $columnAmount > ?',
        whereArgs: [accountId, threshold],
        orderBy: '$columnAmount DESC, $columnPaymentDate DESC',
      );

      final payments = List.generate(maps.length, (i) => fromMap(maps[i]));
      _logger.d(
        'Retrieved ${payments.length} high amount invoice payments (>$threshold) for account: $accountId',
      );
      return payments;
    } catch (e) {
      _logger.e('Error retrieving high amount invoice payments: $e');
      rethrow;
    }
  }

  /// Get successful invoice payments for a specific account
  static Future<List<AccountInvoicePaymentModel>> getSuccessfulPayments(
    Database db,
    String accountId,
  ) async {
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: '$columnAccountId = ? AND $columnStatus = ?',
        whereArgs: [accountId, 'SUCCESS'],
        orderBy: '$columnPaymentDate DESC',
      );

      final payments = List.generate(maps.length, (i) => fromMap(maps[i]));
      _logger.d(
        'Retrieved ${payments.length} successful invoice payments for account: $accountId',
      );
      return payments;
    } catch (e) {
      _logger.e('Error retrieving successful invoice payments: $e');
      rethrow;
    }
  }

  /// Get failed invoice payments for a specific account
  static Future<List<AccountInvoicePaymentModel>> getFailedPayments(
    Database db,
    String accountId,
  ) async {
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: '$columnAccountId = ? AND $columnStatus = ?',
        whereArgs: [accountId, 'FAILED'],
        orderBy: '$columnPaymentDate DESC',
      );

      final payments = List.generate(maps.length, (i) => fromMap(maps[i]));
      _logger.d(
        'Retrieved ${payments.length} failed invoice payments for account: $accountId',
      );
      return payments;
    } catch (e) {
      _logger.e('Error retrieving failed invoice payments: $e');
      rethrow;
    }
  }

  /// Get pending invoice payments for a specific account
  static Future<List<AccountInvoicePaymentModel>> getPendingPayments(
    Database db,
    String accountId,
  ) async {
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: '$columnAccountId = ? AND $columnStatus = ?',
        whereArgs: [accountId, 'PENDING'],
        orderBy: '$columnPaymentDate DESC',
      );

      final payments = List.generate(maps.length, (i) => fromMap(maps[i]));
      _logger.d(
        'Retrieved ${payments.length} pending invoice payments for account: $accountId',
      );
      return payments;
    } catch (e) {
      _logger.e('Error retrieving pending invoice payments: $e');
      rethrow;
    }
  }
}
