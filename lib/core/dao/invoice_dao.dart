import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:logger/logger.dart';
import '../../features/invoices/data/models/invoice_model.dart';
import '../../features/invoices/data/models/invoice_audit_log_model.dart';

class InvoiceDao {
  static const String tableName = 'invoices';
  static const String auditLogsTableName = 'invoice_audit_logs';
  static final Logger _logger = Logger();

  // Column names constants for invoices table
  static const String columnInvoiceId = 'invoice_id';
  static const String columnAccountId = 'account_id';
  static const String columnAmount = 'amount';
  static const String columnCurrency = 'currency';
  static const String columnStatus = 'status';
  static const String columnCreditAdj = 'credit_adj';
  static const String columnRefundAdj = 'refund_adj';
  static const String columnInvoiceDate = 'invoice_date';
  static const String columnTargetDate = 'target_date';
  static const String columnInvoiceNumber = 'invoice_number';
  static const String columnBalance = 'balance';
  static const String columnBundleKeys = 'bundle_keys';
  static const String columnCredits = 'credits';
  static const String columnItems = 'items';
  static const String columnTrackingIds = 'tracking_ids';
  static const String columnIsParentInvoice = 'is_parent_invoice';
  static const String columnParentInvoiceId = 'parent_invoice_id';
  static const String columnParentAccountId = 'parent_account_id';
  static const String columnCreatedAt = 'created_at';

  // Column names constants for invoice_audit_logs table
  static const String columnAuditLogId = 'audit_log_id';
  static const String columnAuditLogInvoiceId = 'invoice_id';
  static const String columnChangeType = 'change_type';
  static const String columnChangeDate = 'change_date';
  static const String columnObjectType = 'object_type';
  static const String columnObjectId = 'object_id';
  static const String columnChangedBy = 'changed_by';
  static const String columnReasonCode = 'reason_code';
  static const String columnComments = 'comments';
  static const String columnUserToken = 'user_token';
  static const String columnHistory = 'history';

  static const String createTableSQL =
      '''
    CREATE TABLE $tableName (
      $columnInvoiceId TEXT PRIMARY KEY,
      $columnAccountId TEXT NOT NULL,
      $columnAmount REAL NOT NULL DEFAULT 0,
      $columnCurrency TEXT NOT NULL,
      $columnStatus TEXT NOT NULL,
      $columnCreditAdj REAL NOT NULL DEFAULT 0,
      $columnRefundAdj REAL NOT NULL DEFAULT 0,
      $columnInvoiceDate TEXT NOT NULL,
      $columnTargetDate TEXT NOT NULL,
      $columnInvoiceNumber TEXT NOT NULL,
      $columnBalance REAL NOT NULL DEFAULT 0,
      $columnBundleKeys TEXT,
      $columnCredits TEXT,
      $columnItems TEXT,
      $columnTrackingIds TEXT,
      $columnIsParentInvoice INTEGER NOT NULL DEFAULT 0,
      $columnParentInvoiceId TEXT,
      $columnParentAccountId TEXT,
      $columnCreatedAt TEXT NOT NULL
    )
  ''';

  static const String createAuditLogsTableSQL =
      '''
    CREATE TABLE $auditLogsTableName (
      $columnAuditLogId INTEGER PRIMARY KEY AUTOINCREMENT,
      $columnAuditLogInvoiceId TEXT NOT NULL,
      $columnChangeType TEXT NOT NULL,
      $columnChangeDate TEXT NOT NULL,
      $columnObjectType TEXT NOT NULL,
      $columnObjectId TEXT NOT NULL,
      $columnChangedBy TEXT NOT NULL,
      $columnReasonCode TEXT,
      $columnComments TEXT,
      $columnUserToken TEXT NOT NULL,
      $columnHistory TEXT,
      FOREIGN KEY ($columnAuditLogInvoiceId) REFERENCES $tableName ($columnInvoiceId) ON DELETE CASCADE
    )
  ''';

  static const String createIndexesSQL =
      '''
    CREATE INDEX IF NOT EXISTS idx_invoices_account_id ON $tableName ($columnAccountId);
    CREATE INDEX IF NOT EXISTS idx_invoices_status ON $tableName ($columnStatus);
    CREATE INDEX IF NOT EXISTS idx_invoices_invoice_number ON $tableName ($columnInvoiceNumber);
    CREATE INDEX IF NOT EXISTS idx_invoices_created_at ON $tableName ($columnCreatedAt);
    CREATE INDEX IF NOT EXISTS idx_invoices_invoice_date ON $tableName ($columnInvoiceDate);
    CREATE INDEX IF NOT EXISTS idx_invoice_audit_logs_invoice_id ON $auditLogsTableName ($columnAuditLogInvoiceId);
    CREATE INDEX IF NOT EXISTS idx_invoice_audit_logs_change_date ON $auditLogsTableName ($columnChangeDate);
  ''';

  /// Insert or update an invoice
  static Future<void> insertOrUpdate(Database db, InvoiceModel invoice) async {
    try {
      // Insert/update invoice
      final invoiceData = {
        columnInvoiceId: invoice.invoiceId,
        columnAccountId: invoice.accountId,
        columnAmount: invoice.amount,
        columnCurrency: invoice.currency,
        columnStatus: invoice.status,
        columnCreditAdj: invoice.creditAdj,
        columnRefundAdj: invoice.refundAdj,
        columnInvoiceDate: invoice.invoiceDate,
        columnTargetDate: invoice.targetDate,
        columnInvoiceNumber: invoice.invoiceNumber,
        columnBalance: invoice.balance,
        columnBundleKeys: invoice.bundleKeys?.join(','),
        columnCredits: invoice.credits?.toString(),
        columnItems: invoice.items.toString(),
        columnTrackingIds: invoice.trackingIds.join(','),
        columnIsParentInvoice: invoice.isParentInvoice ? 1 : 0,
        columnParentInvoiceId: invoice.parentInvoiceId,
        columnParentAccountId: invoice.parentAccountId,
        columnCreatedAt: DateTime.now().toIso8601String(),
      };

      await db.insert(
        tableName,
        invoiceData,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // Insert/update invoice audit logs
      for (final auditLog in invoice.auditLogs) {
        final auditLogData = {
          columnAuditLogInvoiceId: invoice.invoiceId,
          columnChangeType: auditLog.changeType,
          columnChangeDate: auditLog.changeDate,
          columnObjectType: auditLog.objectType,
          columnObjectId: auditLog.objectId,
          columnChangedBy: auditLog.changedBy,
          columnReasonCode: auditLog.reasonCode,
          columnComments: auditLog.comments,
          columnUserToken: auditLog.userToken,
          columnHistory: auditLog.history?.toString(),
        };

        await db.insert(
          auditLogsTableName,
          auditLogData,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      _logger.d('Invoice inserted/updated successfully: ${invoice.invoiceId}');
    } catch (e) {
      _logger.e('Error inserting invoice: $e');
      rethrow;
    }
  }

  /// Get invoice by ID
  static Future<InvoiceModel?> getById(Database db, String invoiceId) async {
    try {
      final results = await db.query(
        tableName,
        where: '$columnInvoiceId = ?',
        whereArgs: [invoiceId],
      );

      if (results.isEmpty) {
        _logger.d('Invoice not found: $invoiceId');
        return null;
      }

      final invoiceData = results.first;

      // Get invoice audit logs
      final auditLogsResults = await db.query(
        auditLogsTableName,
        where: '$columnAuditLogInvoiceId = ?',
        whereArgs: [invoiceId],
      );

      final auditLogs = auditLogsResults.map((auditLogData) {
        return InvoiceAuditLogModel(
          changeType: auditLogData[columnChangeType] as String,
          changeDate: auditLogData[columnChangeDate] as String,
          objectType: auditLogData[columnObjectType] as String,
          objectId: auditLogData[columnObjectId] as String,
          changedBy: auditLogData[columnChangedBy] as String,
          reasonCode: auditLogData[columnReasonCode] as String?,
          comments: auditLogData[columnComments] as String?,
          userToken: auditLogData[columnUserToken] as String,
          history: auditLogData[columnHistory] != null
              ? {} // Simplified - would need proper parsing
              : null,
        );
      }).toList();

      final invoice = InvoiceModel(
        amount: invoiceData[columnAmount] as double,
        currency: invoiceData[columnCurrency] as String,
        status: invoiceData[columnStatus] as String,
        creditAdj: invoiceData[columnCreditAdj] as double,
        refundAdj: invoiceData[columnRefundAdj] as double,
        invoiceId: invoiceData[columnInvoiceId] as String,
        invoiceDate: invoiceData[columnInvoiceDate] as String,
        targetDate: invoiceData[columnTargetDate] as String,
        invoiceNumber: invoiceData[columnInvoiceNumber] as String,
        balance: invoiceData[columnBalance] as double,
        accountId: invoiceData[columnAccountId] as String,
        bundleKeys: invoiceData[columnBundleKeys] != null
            ? (invoiceData[columnBundleKeys] as String).split(',')
            : null,
        credits: invoiceData[columnCredits] != null
            ? [] // Simplified - would need proper parsing
            : null,
        items: [], // Simplified - would need proper parsing
        trackingIds: invoiceData[columnTrackingIds] != null
            ? (invoiceData[columnTrackingIds] as String).split(',')
            : [],
        isParentInvoice: (invoiceData[columnIsParentInvoice] as int) == 1,
        parentInvoiceId: invoiceData[columnParentInvoiceId] as String?,
        parentAccountId: invoiceData[columnParentAccountId] as String?,
        auditLogs: auditLogs,
      );

      _logger.d('Invoice retrieved successfully: $invoiceId');
      return invoice;
    } catch (e) {
      _logger.e('Error retrieving invoice: $e');
      rethrow;
    }
  }

  /// Get all invoices
  static Future<List<InvoiceModel>> getAll(Database db) async {
    try {
      // Fetch all invoices
      final results = await db.query(
        tableName,
        orderBy: '$columnCreatedAt DESC',
      );

      if (results.isEmpty) {
        _logger.d('No invoices found');
        return [];
      }

      // Extract invoice IDs
      final invoiceIds = results
          .map((row) => row[columnInvoiceId] as String)
          .toList();

      // Fetch all audit logs for all invoices in a single query (optimized)
      final auditLogsResults = invoiceIds.isEmpty
          ? <Map<String, dynamic>>[]
          : await db.query(
              auditLogsTableName,
              where:
                  '$columnAuditLogInvoiceId IN (${List.filled(invoiceIds.length, '?').join(',')})',
              whereArgs: invoiceIds,
              orderBy: '$columnChangeDate DESC',
            );

      // Group audit logs by invoice ID
      final auditLogsByInvoiceId = <String, List<InvoiceAuditLogModel>>{};
      for (final auditLogData in auditLogsResults) {
        final invoiceId = auditLogData[columnAuditLogInvoiceId] as String;
        auditLogsByInvoiceId
            .putIfAbsent(invoiceId, () => [])
            .add(
              InvoiceAuditLogModel(
                changeType: auditLogData[columnChangeType] as String,
                changeDate: auditLogData[columnChangeDate] as String,
                objectType: auditLogData[columnObjectType] as String,
                objectId: auditLogData[columnObjectId] as String,
                changedBy: auditLogData[columnChangedBy] as String,
                reasonCode: auditLogData[columnReasonCode] as String?,
                comments: auditLogData[columnComments] as String?,
                userToken: auditLogData[columnUserToken] as String,
                history: auditLogData[columnHistory] != null
                    ? {} // Simplified - would need proper parsing
                    : null,
              ),
            );
      }

      // Build invoice models with their audit logs
      final invoices = results.map((invoiceData) {
        final invoiceId = invoiceData[columnInvoiceId] as String;
        final auditLogs = auditLogsByInvoiceId[invoiceId] ?? [];

        return InvoiceModel(
          amount: invoiceData[columnAmount] as double,
          currency: invoiceData[columnCurrency] as String,
          status: invoiceData[columnStatus] as String,
          creditAdj: invoiceData[columnCreditAdj] as double,
          refundAdj: invoiceData[columnRefundAdj] as double,
          invoiceId: invoiceId,
          invoiceDate: invoiceData[columnInvoiceDate] as String,
          targetDate: invoiceData[columnTargetDate] as String,
          invoiceNumber: invoiceData[columnInvoiceNumber] as String,
          balance: invoiceData[columnBalance] as double,
          accountId: invoiceData[columnAccountId] as String,
          bundleKeys: invoiceData[columnBundleKeys] != null
              ? (invoiceData[columnBundleKeys] as String).split(',')
              : null,
          credits: invoiceData[columnCredits] != null
              ? [] // Simplified - would need proper parsing
              : null,
          items: [], // Simplified - would need proper parsing
          trackingIds: invoiceData[columnTrackingIds] != null
              ? (invoiceData[columnTrackingIds] as String).split(',')
              : [],
          isParentInvoice: (invoiceData[columnIsParentInvoice] as int) == 1,
          parentInvoiceId: invoiceData[columnParentInvoiceId] as String?,
          parentAccountId: invoiceData[columnParentAccountId] as String?,
          auditLogs: auditLogs,
        );
      }).toList();

      _logger.d('Retrieved ${invoices.length} invoices');
      return invoices;
    } catch (e) {
      _logger.e('Error retrieving all invoices: $e');
      rethrow;
    }
  }

  /// Get invoices by account ID
  static Future<List<InvoiceModel>> getByAccountId(
    Database db,
    String accountId,
  ) async {
    try {
      // Fetch invoices for the account
      final results = await db.query(
        tableName,
        where: '$columnAccountId = ?',
        whereArgs: [accountId],
        orderBy: '$columnCreatedAt DESC',
      );

      if (results.isEmpty) {
        _logger.d('No invoices found for account: $accountId');
        return [];
      }

      // Extract invoice IDs
      final invoiceIds = results
          .map((row) => row[columnInvoiceId] as String)
          .toList();

      // Fetch all audit logs for all invoices in a single query (optimized)
      final auditLogsResults = invoiceIds.isEmpty
          ? <Map<String, dynamic>>[]
          : await db.query(
              auditLogsTableName,
              where:
                  '$columnAuditLogInvoiceId IN (${List.filled(invoiceIds.length, '?').join(',')})',
              whereArgs: invoiceIds,
              orderBy: '$columnChangeDate DESC',
            );

      // Group audit logs by invoice ID
      final auditLogsByInvoiceId = <String, List<InvoiceAuditLogModel>>{};
      for (final auditLogData in auditLogsResults) {
        final invoiceId = auditLogData[columnAuditLogInvoiceId] as String;
        auditLogsByInvoiceId
            .putIfAbsent(invoiceId, () => [])
            .add(
              InvoiceAuditLogModel(
                changeType: auditLogData[columnChangeType] as String,
                changeDate: auditLogData[columnChangeDate] as String,
                objectType: auditLogData[columnObjectType] as String,
                objectId: auditLogData[columnObjectId] as String,
                changedBy: auditLogData[columnChangedBy] as String,
                reasonCode: auditLogData[columnReasonCode] as String?,
                comments: auditLogData[columnComments] as String?,
                userToken: auditLogData[columnUserToken] as String,
                history: auditLogData[columnHistory] != null
                    ? {} // Simplified - would need proper parsing
                    : null,
              ),
            );
      }

      // Build invoice models with their audit logs
      final invoices = results.map((invoiceData) {
        final invoiceId = invoiceData[columnInvoiceId] as String;
        final auditLogs = auditLogsByInvoiceId[invoiceId] ?? [];

        return InvoiceModel(
          amount: invoiceData[columnAmount] as double,
          currency: invoiceData[columnCurrency] as String,
          status: invoiceData[columnStatus] as String,
          creditAdj: invoiceData[columnCreditAdj] as double,
          refundAdj: invoiceData[columnRefundAdj] as double,
          invoiceId: invoiceId,
          invoiceDate: invoiceData[columnInvoiceDate] as String,
          targetDate: invoiceData[columnTargetDate] as String,
          invoiceNumber: invoiceData[columnInvoiceNumber] as String,
          balance: invoiceData[columnBalance] as double,
          accountId: invoiceData[columnAccountId] as String,
          bundleKeys: invoiceData[columnBundleKeys] != null
              ? (invoiceData[columnBundleKeys] as String).split(',')
              : null,
          credits: invoiceData[columnCredits] != null
              ? [] // Simplified - would need proper parsing
              : null,
          items: [], // Simplified - would need proper parsing
          trackingIds: invoiceData[columnTrackingIds] != null
              ? (invoiceData[columnTrackingIds] as String).split(',')
              : [],
          isParentInvoice: (invoiceData[columnIsParentInvoice] as int) == 1,
          parentInvoiceId: invoiceData[columnParentInvoiceId] as String?,
          parentAccountId: invoiceData[columnParentAccountId] as String?,
          auditLogs: auditLogs,
        );
      }).toList();

      _logger.d(
        'Retrieved ${invoices.length} invoices for account: $accountId',
      );
      return invoices;
    } catch (e) {
      _logger.e('Error retrieving invoices by account ID: $e');
      rethrow;
    }
  }

  /// Search invoices by invoice number
  static Future<List<InvoiceModel>> search(
    Database db,
    String searchQuery,
  ) async {
    try {
      // Fetch invoices matching search query
      final results = await db.query(
        tableName,
        where: '$columnInvoiceNumber LIKE ?',
        whereArgs: ['%$searchQuery%'],
        orderBy: '$columnCreatedAt DESC',
      );

      if (results.isEmpty) {
        _logger.d('No invoices found matching "$searchQuery"');
        return [];
      }

      // Extract invoice IDs
      final invoiceIds = results
          .map((row) => row[columnInvoiceId] as String)
          .toList();

      // Fetch all audit logs for all invoices in a single query (optimized)
      final auditLogsResults = invoiceIds.isEmpty
          ? <Map<String, dynamic>>[]
          : await db.query(
              auditLogsTableName,
              where:
                  '$columnAuditLogInvoiceId IN (${List.filled(invoiceIds.length, '?').join(',')})',
              whereArgs: invoiceIds,
              orderBy: '$columnChangeDate DESC',
            );

      // Group audit logs by invoice ID
      final auditLogsByInvoiceId = <String, List<InvoiceAuditLogModel>>{};
      for (final auditLogData in auditLogsResults) {
        final invoiceId = auditLogData[columnAuditLogInvoiceId] as String;
        auditLogsByInvoiceId
            .putIfAbsent(invoiceId, () => [])
            .add(
              InvoiceAuditLogModel(
                changeType: auditLogData[columnChangeType] as String,
                changeDate: auditLogData[columnChangeDate] as String,
                objectType: auditLogData[columnObjectType] as String,
                objectId: auditLogData[columnObjectId] as String,
                changedBy: auditLogData[columnChangedBy] as String,
                reasonCode: auditLogData[columnReasonCode] as String?,
                comments: auditLogData[columnComments] as String?,
                userToken: auditLogData[columnUserToken] as String,
                history: auditLogData[columnHistory] != null
                    ? {} // Simplified - would need proper parsing
                    : null,
              ),
            );
      }

      // Build invoice models with their audit logs
      final invoices = results.map((invoiceData) {
        final invoiceId = invoiceData[columnInvoiceId] as String;
        final auditLogs = auditLogsByInvoiceId[invoiceId] ?? [];

        return InvoiceModel(
          amount: invoiceData[columnAmount] as double,
          currency: invoiceData[columnCurrency] as String,
          status: invoiceData[columnStatus] as String,
          creditAdj: invoiceData[columnCreditAdj] as double,
          refundAdj: invoiceData[columnRefundAdj] as double,
          invoiceId: invoiceId,
          invoiceDate: invoiceData[columnInvoiceDate] as String,
          targetDate: invoiceData[columnTargetDate] as String,
          invoiceNumber: invoiceData[columnInvoiceNumber] as String,
          balance: invoiceData[columnBalance] as double,
          accountId: invoiceData[columnAccountId] as String,
          bundleKeys: invoiceData[columnBundleKeys] != null
              ? (invoiceData[columnBundleKeys] as String).split(',')
              : null,
          credits: invoiceData[columnCredits] != null
              ? [] // Simplified - would need proper parsing
              : null,
          items: [], // Simplified - would need proper parsing
          trackingIds: invoiceData[columnTrackingIds] != null
              ? (invoiceData[columnTrackingIds] as String).split(',')
              : [],
          isParentInvoice: (invoiceData[columnIsParentInvoice] as int) == 1,
          parentInvoiceId: invoiceData[columnParentInvoiceId] as String?,
          parentAccountId: invoiceData[columnParentAccountId] as String?,
          auditLogs: auditLogs,
        );
      }).toList();

      _logger.d('Found ${invoices.length} invoices matching "$searchQuery"');
      return invoices;
    } catch (e) {
      _logger.e('Error searching invoices: $e');
      rethrow;
    }
  }

  /// Delete invoice by ID
  static Future<void> deleteById(Database db, String invoiceId) async {
    try {
      // Delete invoice audit logs first (due to foreign key constraint)
      await db.delete(
        auditLogsTableName,
        where: '$columnAuditLogInvoiceId = ?',
        whereArgs: [invoiceId],
      );

      // Delete invoice
      await db.delete(
        tableName,
        where: '$columnInvoiceId = ?',
        whereArgs: [invoiceId],
      );

      _logger.d('Invoice deleted successfully: $invoiceId');
    } catch (e) {
      _logger.e('Error deleting invoice: $e');
      rethrow;
    }
  }

  /// Delete all invoices
  static Future<void> deleteAll(Database db) async {
    try {
      // Delete all invoice audit logs first
      await db.delete(auditLogsTableName);

      // Delete all invoices
      await db.delete(tableName);

      _logger.d('All invoices deleted successfully');
    } catch (e) {
      _logger.e('Error deleting all invoices: $e');
      rethrow;
    }
  }

  /// Get invoice count
  static Future<int> getCount(Database db) async {
    try {
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM $tableName',
      );
      final count = result.first['count'] as int;
      _logger.d('Invoice count: $count');
      return count;
    } catch (e) {
      _logger.e('Error getting invoice count: $e');
      rethrow;
    }
  }

  /// Check if invoice exists
  static Future<bool> exists(Database db, String invoiceId) async {
    try {
      final result = await db.rawQuery(
        'SELECT 1 FROM $tableName WHERE $columnInvoiceId = ?',
        [invoiceId],
      );
      return result.isNotEmpty;
    } catch (e) {
      _logger.e('Error checking if invoice exists: $e');
      rethrow;
    }
  }

  /// Get audit logs by invoice ID
  static Future<List<InvoiceAuditLogModel>> getAuditLogsByInvoiceId(
    Database db,
    String invoiceId,
  ) async {
    try {
      final results = await db.query(
        auditLogsTableName,
        where: '$columnAuditLogInvoiceId = ?',
        whereArgs: [invoiceId],
        orderBy: '$columnChangeDate DESC',
      );

      final auditLogs = results.map((auditLogData) {
        return InvoiceAuditLogModel(
          changeType: auditLogData[columnChangeType] as String,
          changeDate: auditLogData[columnChangeDate] as String,
          objectType: auditLogData[columnObjectType] as String,
          objectId: auditLogData[columnObjectId] as String,
          changedBy: auditLogData[columnChangedBy] as String,
          reasonCode: auditLogData[columnReasonCode] as String?,
          comments: auditLogData[columnComments] as String?,
          userToken: auditLogData[columnUserToken] as String,
          history: auditLogData[columnHistory] != null
              ? {} // Simplified - would need proper parsing
              : null,
        );
      }).toList();

      _logger.d('Found ${auditLogs.length} audit logs for invoice: $invoiceId');
      return auditLogs;
    } catch (e) {
      _logger.e('Error getting audit logs for invoice: $e');
      rethrow;
    }
  }
}
