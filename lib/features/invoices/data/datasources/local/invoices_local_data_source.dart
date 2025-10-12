import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';

import '../../../../../core/services/database_service.dart';
import '../../../../../core/dao/invoice_dao.dart';
import '../../models/invoice_model.dart';
import '../../models/invoice_audit_log_model.dart';

abstract class InvoicesLocalDataSource {
  Future<void> cacheInvoices(List<InvoiceModel> invoices);
  Future<List<InvoiceModel>> getCachedInvoices();
  Future<void> cacheInvoice(InvoiceModel invoice);
  Future<InvoiceModel?> getCachedInvoiceById(String invoiceId);
  Future<List<InvoiceModel>> getCachedInvoicesByAccountId(String accountId);
  Future<List<InvoiceModel>> searchCachedInvoices(String searchKey);
  Future<void> clearCachedInvoices();
  Future<List<InvoiceAuditLogModel>> getCachedInvoiceAuditLogsWithHistory(
    String invoiceId,
  );
}

@LazySingleton(as: InvoicesLocalDataSource)
class InvoicesLocalDataSourceImpl implements InvoicesLocalDataSource {
  final DatabaseService _databaseService;
  final Logger _logger;

  InvoicesLocalDataSourceImpl(this._databaseService, this._logger);

  @override
  Future<void> cacheInvoices(List<InvoiceModel> invoices) async {
    try {
      _logger.d(
        'InvoicesLocalDataSource: Caching ${invoices.length} invoices to local storage',
      );

      final db = await _databaseService.database;

      // Use InvoiceDao to insert invoices
      for (final invoice in invoices) {
        await InvoiceDao.insertOrUpdate(db, invoice);
        _logger.d(
          'InvoicesLocalDataSource: Cached invoice: ${invoice.invoiceId}',
        );
      }

      _logger.d(
        'InvoicesLocalDataSource: Successfully cached ${invoices.length} invoices',
      );
    } catch (e, stackTrace) {
      _logger.e('InvoicesLocalDataSource: Error caching invoices: $e');
      _logger.e('InvoicesLocalDataSource: Stack trace: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<List<InvoiceModel>> getCachedInvoices() async {
    try {
      _logger.d(
        'InvoicesLocalDataSource: Retrieving cached invoices from local storage',
      );

      final db = await _databaseService.database;
      final invoices = await InvoiceDao.getAll(db);

      _logger.d(
        'InvoicesLocalDataSource: Retrieved ${invoices.length} cached invoices',
      );
      return invoices;
    } catch (e, stackTrace) {
      _logger.e(
        'InvoicesLocalDataSource: Error retrieving cached invoices: $e',
      );
      _logger.e('InvoicesLocalDataSource: Stack trace: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<void> cacheInvoice(InvoiceModel invoice) async {
    try {
      _logger.d(
        'InvoicesLocalDataSource: Caching invoice: ${invoice.invoiceId}',
      );

      final db = await _databaseService.database;
      await InvoiceDao.insertOrUpdate(db, invoice);

      _logger.d(
        'InvoicesLocalDataSource: Successfully cached invoice: ${invoice.invoiceId}',
      );
    } catch (e, stackTrace) {
      _logger.e(
        'InvoicesLocalDataSource: Error caching invoice ${invoice.invoiceId}: $e',
      );
      _logger.e('InvoicesLocalDataSource: Stack trace: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<InvoiceModel?> getCachedInvoiceById(String invoiceId) async {
    try {
      _logger.d(
        'InvoicesLocalDataSource: Retrieving cached invoice by ID: $invoiceId',
      );

      final db = await _databaseService.database;
      final invoice = await InvoiceDao.getById(db, invoiceId);

      if (invoice != null) {
        _logger.d(
          'InvoicesLocalDataSource: Retrieved cached invoice: ${invoice.invoiceId}',
        );
      } else {
        _logger.d(
          'InvoicesLocalDataSource: No cached invoice found for ID: $invoiceId',
        );
      }

      return invoice;
    } catch (e, stackTrace) {
      _logger.e(
        'InvoicesLocalDataSource: Error retrieving cached invoice $invoiceId: $e',
      );
      _logger.e('InvoicesLocalDataSource: Stack trace: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<List<InvoiceModel>> getCachedInvoicesByAccountId(
    String accountId,
  ) async {
    try {
      _logger.d(
        'InvoicesLocalDataSource: Retrieving cached invoices by account ID: $accountId',
      );

      final db = await _databaseService.database;
      final invoices = await InvoiceDao.getByAccountId(db, accountId);

      _logger.d(
        'InvoicesLocalDataSource: Retrieved ${invoices.length} cached invoices for account: $accountId',
      );
      return invoices;
    } catch (e, stackTrace) {
      _logger.e(
        'InvoicesLocalDataSource: Error retrieving cached invoices for account $accountId: $e',
      );
      _logger.e('InvoicesLocalDataSource: Stack trace: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<List<InvoiceModel>> searchCachedInvoices(String searchKey) async {
    try {
      _logger.d(
        'InvoicesLocalDataSource: Searching cached invoices with key: $searchKey',
      );

      final db = await _databaseService.database;
      final invoices = await InvoiceDao.search(db, searchKey);

      _logger.d(
        'InvoicesLocalDataSource: Found ${invoices.length} cached invoices matching "$searchKey"',
      );
      return invoices;
    } catch (e, stackTrace) {
      _logger.e('InvoicesLocalDataSource: Error searching cached invoices: $e');
      _logger.e('InvoicesLocalDataSource: Stack trace: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<void> clearCachedInvoices() async {
    try {
      _logger.d(
        'InvoicesLocalDataSource: Clearing cached invoices from local storage',
      );

      final db = await _databaseService.database;
      await InvoiceDao.deleteAll(db);

      _logger.d(
        'InvoicesLocalDataSource: Successfully cleared cached invoices',
      );
    } catch (e, stackTrace) {
      _logger.e('InvoicesLocalDataSource: Error clearing cached invoices: $e');
      _logger.e('InvoicesLocalDataSource: Stack trace: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<List<InvoiceAuditLogModel>> getCachedInvoiceAuditLogsWithHistory(
    String invoiceId,
  ) async {
    try {
      _logger.d(
        'InvoicesLocalDataSource: Retrieving cached invoice audit logs for invoice ID: $invoiceId',
      );

      final db = await _databaseService.database;
      final auditLogs = await InvoiceDao.getAuditLogsByInvoiceId(db, invoiceId);

      _logger.d(
        'InvoicesLocalDataSource: Retrieved ${auditLogs.length} cached audit logs for invoice: $invoiceId',
      );
      return auditLogs;
    } catch (e, stackTrace) {
      _logger.e(
        'InvoicesLocalDataSource: Error retrieving cached audit logs for invoice $invoiceId: $e',
      );
      _logger.e('InvoicesLocalDataSource: Stack trace: $stackTrace');
      rethrow;
    }
  }
}
