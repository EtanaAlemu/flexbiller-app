import 'dart:convert';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:logger/logger.dart';
import '../../features/accounts/data/models/account_invoice_model.dart';

class AccountInvoicesDao {
  static const String tableName = 'account_invoices';
  static final Logger _logger = Logger();

  // Column names constants
  static const String columnInvoiceId = 'invoice_id';
  static const String columnInvoiceNumber = 'invoice_number';
  static const String columnAccountId = 'account_id';
  static const String columnAmount = 'amount';
  static const String columnCurrency = 'currency';
  static const String columnStatus = 'status';
  static const String columnBalance = 'balance';
  static const String columnCreditAdj = 'credit_adj';
  static const String columnRefundAdj = 'refund_adj';
  static const String columnInvoiceDate = 'invoice_date';
  static const String columnTargetDate = 'target_date';
  static const String columnBundleKeys = 'bundle_keys';
  static const String columnCredits = 'credits';
  static const String columnItems = 'items';
  static const String columnTrackingIds = 'tracking_ids';
  static const String columnIsParentInvoice = 'is_parent_invoice';
  static const String columnParentInvoiceId = 'parent_invoice_id';
  static const String columnParentAccountId = 'parent_account_id';
  static const String columnAuditLogs = 'audit_logs';
  static const String columnCreatedAt = 'created_at';
  static const String columnUpdatedAt = 'updated_at';

  static const String createTableSQL =
      '''
    CREATE TABLE $tableName (
      $columnInvoiceId TEXT PRIMARY KEY,
      $columnInvoiceNumber TEXT NOT NULL,
      $columnAccountId TEXT NOT NULL,
      $columnAmount REAL NOT NULL,
      $columnCurrency TEXT NOT NULL,
      $columnStatus TEXT NOT NULL,
      $columnBalance REAL NOT NULL,
      $columnCreditAdj REAL NOT NULL,
      $columnRefundAdj REAL NOT NULL,
      $columnInvoiceDate TEXT NOT NULL,
      $columnTargetDate TEXT NOT NULL,
      $columnBundleKeys TEXT,
      $columnCredits TEXT,
      $columnItems TEXT NOT NULL,
      $columnTrackingIds TEXT NOT NULL,
      $columnIsParentInvoice INTEGER NOT NULL,
      $columnParentInvoiceId TEXT,
      $columnParentAccountId TEXT,
      $columnAuditLogs TEXT NOT NULL,
      $columnCreatedAt TEXT NOT NULL,
      $columnUpdatedAt TEXT NOT NULL
    )
  ''';

  static Map<String, dynamic> toMap(AccountInvoiceModel invoice) {
    final now = DateTime.now().toIso8601String();
    return {
      columnInvoiceId: invoice.invoiceId,
      columnInvoiceNumber: invoice.invoiceNumber,
      columnAccountId: invoice.accountId,
      columnAmount: invoice.amount,
      columnCurrency: invoice.currency,
      columnStatus: invoice.status,
      columnBalance: invoice.balance,
      columnCreditAdj: invoice.creditAdj,
      columnRefundAdj: invoice.refundAdj,
      columnInvoiceDate: invoice.invoiceDate,
      columnTargetDate: invoice.targetDate,
      columnBundleKeys: invoice.bundleKeys?.join(','),
      columnCredits: invoice.credits != null
          ? jsonEncode(invoice.credits)
          : null,
      columnItems: jsonEncode(invoice.items),
      columnTrackingIds: invoice.trackingIds.join(','),
      columnIsParentInvoice: invoice.isParentInvoice ? 1 : 0,
      columnParentInvoiceId: invoice.parentInvoiceId,
      columnParentAccountId: invoice.parentAccountId,
      columnAuditLogs: jsonEncode(invoice.auditLogs),
      columnCreatedAt: now,
      columnUpdatedAt: now,
    };
  }

  static AccountInvoiceModel fromMap(Map<String, dynamic> map) {
    return AccountInvoiceModel(
      invoiceId: map[columnInvoiceId] as String,
      invoiceNumber: map[columnInvoiceNumber] as String,
      accountId: map[columnAccountId] as String,
      amount: (map[columnAmount] as num).toDouble(),
      currency: map[columnCurrency] as String,
      status: map[columnStatus] as String,
      balance: (map[columnBalance] as num).toDouble(),
      creditAdj: (map[columnCreditAdj] as num).toDouble(),
      refundAdj: (map[columnRefundAdj] as num).toDouble(),
      invoiceDate: map[columnInvoiceDate] as String,
      targetDate: map[columnTargetDate] as String,
      bundleKeys: map[columnBundleKeys]?.toString().split(',') ?? [],
      credits: map[columnCredits] != null
          ? jsonDecode(map[columnCredits] as String)
                as List<Map<String, dynamic>>
          : null,
      items: (jsonDecode(map[columnItems] as String) as List<dynamic>)
          .cast<Map<String, dynamic>>(),
      trackingIds: map[columnTrackingIds].toString().split(','),
      isParentInvoice: (map[columnIsParentInvoice] as int) == 1,
      parentInvoiceId: map[columnParentInvoiceId] as String?,
      parentAccountId: map[columnParentAccountId] as String?,
      auditLogs: (jsonDecode(map[columnAuditLogs] as String) as List<dynamic>)
          .cast<Map<String, dynamic>>(),
    );
  }

  /// Insert or update an invoice
  static Future<void> insertOrUpdate(
    Database db,
    AccountInvoiceModel invoice,
  ) async {
    try {
      final map = toMap(invoice);
      await db.insert(
        tableName,
        map,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      _logger.d(
        'Account invoice inserted/updated successfully: ${invoice.invoiceId}',
      );
    } catch (e) {
      _logger.e('Error inserting account invoice: $e');
      rethrow;
    }
  }

  /// Insert multiple invoices
  static Future<void> insertMultiple(
    Database db,
    List<AccountInvoiceModel> invoices,
  ) async {
    try {
      await db.transaction((txn) async {
        for (final invoice in invoices) {
          final map = toMap(invoice);
          await txn.insert(
            tableName,
            map,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      });
      _logger.d('Inserted ${invoices.length} account invoices successfully');
    } catch (e) {
      _logger.e('Error inserting multiple account invoices: $e');
      rethrow;
    }
  }

  /// Get all invoices for a specific account
  static Future<List<AccountInvoiceModel>> getByAccountId(
    Database db,
    String accountId,
  ) async {
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: '$columnAccountId = ?',
        whereArgs: [accountId],
        orderBy: '$columnInvoiceDate DESC',
      );

      final invoices = List.generate(maps.length, (i) => fromMap(maps[i]));
      _logger.d(
        'Retrieved ${invoices.length} invoices for account: $accountId',
      );
      return invoices;
    } catch (e) {
      _logger.e('Error retrieving invoices by account ID: $e');
      rethrow;
    }
  }

  /// Get a specific invoice by ID
  static Future<AccountInvoiceModel?> getById(
    Database db,
    String invoiceId,
  ) async {
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: '$columnInvoiceId = ?',
        whereArgs: [invoiceId],
        limit: 1,
      );

      if (maps.isNotEmpty) {
        _logger.d('Account invoice retrieved successfully: $invoiceId');
        return fromMap(maps.first);
      }
      _logger.d('Account invoice not found: $invoiceId');
      return null;
    } catch (e) {
      _logger.e('Error retrieving account invoice by ID: $e');
      rethrow;
    }
  }

  /// Get invoices by status
  static Future<List<AccountInvoiceModel>> getByStatus(
    Database db,
    String accountId,
    String status,
  ) async {
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: '$columnAccountId = ? AND $columnStatus = ?',
        whereArgs: [accountId, status],
        orderBy: '$columnInvoiceDate DESC',
      );

      final invoices = List.generate(maps.length, (i) => fromMap(maps[i]));
      _logger.d(
        'Retrieved ${invoices.length} invoices with status $status for account: $accountId',
      );
      return invoices;
    } catch (e) {
      _logger.e('Error retrieving invoices by status: $e');
      rethrow;
    }
  }

  /// Get invoices by date range
  static Future<List<AccountInvoiceModel>> getByDateRange(
    Database db,
    String accountId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: '$columnAccountId = ? AND $columnInvoiceDate BETWEEN ? AND ?',
        whereArgs: [
          accountId,
          startDate.toIso8601String(),
          endDate.toIso8601String(),
        ],
        orderBy: '$columnInvoiceDate DESC',
      );

      final invoices = List.generate(maps.length, (i) => fromMap(maps[i]));
      _logger.d(
        'Retrieved ${invoices.length} invoices for account: $accountId between ${startDate.toIso8601String()} and ${endDate.toIso8601String()}',
      );
      return invoices;
    } catch (e) {
      _logger.e('Error retrieving invoices by date range: $e');
      rethrow;
    }
  }

  /// Get invoices by amount range
  static Future<List<AccountInvoiceModel>> getByAmountRange(
    Database db,
    String accountId,
    double minAmount,
    double maxAmount,
  ) async {
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: '$columnAccountId = ? AND $columnAmount BETWEEN ? AND ?',
        whereArgs: [accountId, minAmount, maxAmount],
        orderBy: '$columnAmount DESC',
      );

      final invoices = List.generate(maps.length, (i) => fromMap(maps[i]));
      _logger.d(
        'Retrieved ${invoices.length} invoices for account: $accountId with amount between $minAmount and $maxAmount',
      );
      return invoices;
    } catch (e) {
      _logger.e('Error retrieving invoices by amount range: $e');
      rethrow;
    }
  }

  /// Get invoices by currency
  static Future<List<AccountInvoiceModel>> getByCurrency(
    Database db,
    String accountId,
    String currency,
  ) async {
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: '$columnAccountId = ? AND $columnCurrency = ?',
        whereArgs: [accountId, currency],
        orderBy: '$columnInvoiceDate DESC',
      );

      final invoices = List.generate(maps.length, (i) => fromMap(maps[i]));
      _logger.d(
        'Retrieved ${invoices.length} invoices for currency $currency and account: $accountId',
      );
      return invoices;
    } catch (e) {
      _logger.e('Error retrieving invoices by currency: $e');
      rethrow;
    }
  }

  /// Get invoices with pagination
  static Future<List<AccountInvoiceModel>> getWithPagination(
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
        orderBy: '$columnInvoiceDate DESC',
        limit: pageSize,
        offset: offset,
      );

      final invoices = List.generate(maps.length, (i) => fromMap(maps[i]));
      _logger.d(
        'Retrieved ${invoices.length} invoices for account: $accountId (page $page, size $pageSize)',
      );
      return invoices;
    } catch (e) {
      _logger.e('Error retrieving invoices with pagination: $e');
      rethrow;
    }
  }

  /// Get all invoices
  static Future<List<AccountInvoiceModel>> getAll(Database db) async {
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        orderBy: '$columnInvoiceDate DESC',
      );

      final invoices = List.generate(maps.length, (i) => fromMap(maps[i]));
      _logger.d('Retrieved ${invoices.length} account invoices');
      return invoices;
    } catch (e) {
      _logger.e('Error retrieving all account invoices: $e');
      rethrow;
    }
  }

  /// Update an invoice
  static Future<void> update(Database db, AccountInvoiceModel invoice) async {
    try {
      final map = toMap(invoice);
      map[columnUpdatedAt] = DateTime.now().toIso8601String();

      await db.update(
        tableName,
        map,
        where: '$columnInvoiceId = ?',
        whereArgs: [invoice.invoiceId],
      );
      _logger.d('Account invoice updated successfully: ${invoice.invoiceId}');
    } catch (e) {
      _logger.e('Error updating account invoice: $e');
      rethrow;
    }
  }

  /// Delete an invoice
  static Future<void> delete(Database db, String invoiceId) async {
    try {
      await db.delete(
        tableName,
        where: '$columnInvoiceId = ?',
        whereArgs: [invoiceId],
      );
      _logger.d('Account invoice deleted successfully: $invoiceId');
    } catch (e) {
      _logger.e('Error deleting account invoice: $e');
      rethrow;
    }
  }

  /// Delete invoices by account ID
  static Future<void> deleteByAccountId(Database db, String accountId) async {
    try {
      await db.delete(
        tableName,
        where: '$columnAccountId = ?',
        whereArgs: [accountId],
      );
      _logger.d(
        'Account invoices deleted successfully for account: $accountId',
      );
    } catch (e) {
      _logger.e('Error deleting account invoices by account ID: $e');
      rethrow;
    }
  }

  /// Delete all invoices
  static Future<void> deleteAll(Database db) async {
    try {
      await db.delete(tableName);
      _logger.d('All account invoices deleted successfully');
    } catch (e) {
      _logger.e('Error deleting all account invoices: $e');
      rethrow;
    }
  }

  /// Get count of invoices for a specific account
  static Future<int> getCountByAccountId(Database db, String accountId) async {
    try {
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM $tableName WHERE $columnAccountId = ?',
        [accountId],
      );
      final count = Sqflite.firstIntValue(result) ?? 0;
      _logger.d('Account invoice count for account $accountId: $count');
      return count;
    } catch (e) {
      _logger.e('Error getting account invoice count by account ID: $e');
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
        'Account invoice count for account $accountId and status $status: $count',
      );
      return count;
    } catch (e) {
      _logger.e('Error getting account invoice count by status: $e');
      rethrow;
    }
  }

  /// Get total count of all invoices
  static Future<int> getTotalCount(Database db) async {
    try {
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM $tableName',
      );
      final count = Sqflite.firstIntValue(result) ?? 0;
      _logger.d('Total account invoice count: $count');
      return count;
    } catch (e) {
      _logger.e('Error getting total account invoice count: $e');
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

  /// Get total balance for a specific account
  static Future<double> getTotalBalanceByAccountId(
    Database db,
    String accountId,
  ) async {
    try {
      final result = await db.rawQuery(
        'SELECT SUM($columnBalance) as total FROM $tableName WHERE $columnAccountId = ?',
        [accountId],
      );
      final total = (result.first['total'] as num?)?.toDouble() ?? 0.0;
      _logger.d('Total balance for account $accountId: $total');
      return total;
    } catch (e) {
      _logger.e('Error getting total balance by account ID: $e');
      rethrow;
    }
  }

  /// Check if an invoice exists
  static Future<bool> exists(Database db, String invoiceId) async {
    try {
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM $tableName WHERE $columnInvoiceId = ?',
        [invoiceId],
      );
      final exists = (Sqflite.firstIntValue(result) ?? 0) > 0;
      _logger.d('Account invoice exists check for $invoiceId: $exists');
      return exists;
    } catch (e) {
      _logger.e('Error checking if account invoice exists: $e');
      rethrow;
    }
  }

  /// Search invoices by invoice number
  static Future<List<AccountInvoiceModel>> searchByInvoiceNumber(
    Database db,
    String accountId,
    String searchTerm,
  ) async {
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: '$columnAccountId = ? AND $columnInvoiceNumber LIKE ?',
        whereArgs: [accountId, '%$searchTerm%'],
        orderBy: '$columnInvoiceDate DESC',
      );

      final invoices = List.generate(maps.length, (i) => fromMap(maps[i]));
      _logger.d(
        'Found ${invoices.length} invoices matching "$searchTerm" for account: $accountId',
      );
      return invoices;
    } catch (e) {
      _logger.e('Error searching invoices by invoice number: $e');
      rethrow;
    }
  }

  /// Get invoices by parent invoice ID
  static Future<List<AccountInvoiceModel>> getByParentInvoiceId(
    Database db,
    String parentInvoiceId,
  ) async {
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: '$columnParentInvoiceId = ?',
        whereArgs: [parentInvoiceId],
        orderBy: '$columnInvoiceDate DESC',
      );

      final invoices = List.generate(maps.length, (i) => fromMap(maps[i]));
      _logger.d(
        'Retrieved ${invoices.length} child invoices for parent invoice: $parentInvoiceId',
      );
      return invoices;
    } catch (e) {
      _logger.e('Error retrieving invoices by parent invoice ID: $e');
      rethrow;
    }
  }

  /// Get parent invoices only
  static Future<List<AccountInvoiceModel>> getParentInvoices(
    Database db,
    String accountId,
  ) async {
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: '$columnAccountId = ? AND $columnIsParentInvoice = 1',
        whereArgs: [accountId],
        orderBy: '$columnInvoiceDate DESC',
      );

      final invoices = List.generate(maps.length, (i) => fromMap(maps[i]));
      _logger.d(
        'Retrieved ${invoices.length} parent invoices for account: $accountId',
      );
      return invoices;
    } catch (e) {
      _logger.e('Error retrieving parent invoices: $e');
      rethrow;
    }
  }

  /// Get child invoices only
  static Future<List<AccountInvoiceModel>> getChildInvoices(
    Database db,
    String accountId,
  ) async {
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: '$columnAccountId = ? AND $columnIsParentInvoice = 0',
        whereArgs: [accountId],
        orderBy: '$columnInvoiceDate DESC',
      );

      final invoices = List.generate(maps.length, (i) => fromMap(maps[i]));
      _logger.d(
        'Retrieved ${invoices.length} child invoices for account: $accountId',
      );
      return invoices;
    } catch (e) {
      _logger.e('Error retrieving child invoices: $e');
      rethrow;
    }
  }

  /// Get invoices with overdue status
  static Future<List<AccountInvoiceModel>> getOverdueInvoices(
    Database db,
    String accountId,
  ) async {
    try {
      final now = DateTime.now().toIso8601String();
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where:
            '$columnAccountId = ? AND $columnTargetDate < ? AND $columnBalance > 0',
        whereArgs: [accountId, now],
        orderBy: '$columnTargetDate ASC',
      );

      final invoices = List.generate(maps.length, (i) => fromMap(maps[i]));
      _logger.d(
        'Retrieved ${invoices.length} overdue invoices for account: $accountId',
      );
      return invoices;
    } catch (e) {
      _logger.e('Error retrieving overdue invoices: $e');
      rethrow;
    }
  }

  /// Get invoices due soon (within specified days)
  static Future<List<AccountInvoiceModel>> getInvoicesDueSoon(
    Database db,
    String accountId,
    int daysAhead,
  ) async {
    try {
      final now = DateTime.now();
      final dueDate = now.add(Duration(days: daysAhead)).toIso8601String();
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where:
            '$columnAccountId = ? AND $columnTargetDate BETWEEN ? AND ? AND $columnBalance > 0',
        whereArgs: [now.toIso8601String(), dueDate],
        orderBy: '$columnTargetDate ASC',
      );

      final invoices = List.generate(maps.length, (i) => fromMap(maps[i]));
      _logger.d(
        'Retrieved ${invoices.length} invoices due within $daysAhead days for account: $accountId',
      );
      return invoices;
    } catch (e) {
      _logger.e('Error retrieving invoices due soon: $e');
      rethrow;
    }
  }

  /// Get invoices by invoice number
  static Future<List<AccountInvoiceModel>> getByInvoiceNumber(
    Database db,
    String accountId,
    String invoiceNumber,
  ) async {
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: '$columnAccountId = ? AND $columnInvoiceNumber = ?',
        whereArgs: [accountId, invoiceNumber],
        orderBy: '$columnInvoiceDate DESC',
      );

      final invoices = List.generate(maps.length, (i) => fromMap(maps[i]));
      _logger.d(
        'Retrieved ${invoices.length} invoices for invoice number $invoiceNumber and account: $accountId',
      );
      return invoices;
    } catch (e) {
      _logger.e('Error retrieving invoices by invoice number: $e');
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

  /// Get recent invoices for a specific account
  static Future<List<AccountInvoiceModel>> getRecentInvoices(
    Database db,
    String accountId,
    int limit,
  ) async {
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: '$columnAccountId = ?',
        whereArgs: [accountId],
        orderBy: '$columnInvoiceDate DESC',
        limit: limit,
      );

      final invoices = List.generate(maps.length, (i) => fromMap(maps[i]));
      _logger.d(
        'Retrieved ${invoices.length} recent invoices for account: $accountId',
      );
      return invoices;
    } catch (e) {
      _logger.e('Error retrieving recent invoices: $e');
      rethrow;
    }
  }

  /// Get invoices with high amounts (above threshold)
  static Future<List<AccountInvoiceModel>> getHighAmountInvoices(
    Database db,
    String accountId,
    double threshold,
  ) async {
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: '$columnAccountId = ? AND $columnAmount > ?',
        whereArgs: [accountId, threshold],
        orderBy: '$columnAmount DESC, $columnInvoiceDate DESC',
      );

      final invoices = List.generate(maps.length, (i) => fromMap(maps[i]));
      _logger.d(
        'Retrieved ${invoices.length} high amount invoices (>$threshold) for account: $accountId',
      );
      return invoices;
    } catch (e) {
      _logger.e('Error retrieving high amount invoices: $e');
      rethrow;
    }
  }

  /// Get unpaid invoices for a specific account
  static Future<List<AccountInvoiceModel>> getUnpaidInvoices(
    Database db,
    String accountId,
  ) async {
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: '$columnAccountId = ? AND $columnBalance > 0',
        whereArgs: [accountId],
        orderBy: '$columnTargetDate ASC',
      );

      final invoices = List.generate(maps.length, (i) => fromMap(maps[i]));
      _logger.d(
        'Retrieved ${invoices.length} unpaid invoices for account: $accountId',
      );
      return invoices;
    } catch (e) {
      _logger.e('Error retrieving unpaid invoices: $e');
      rethrow;
    }
  }
}
