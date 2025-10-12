import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import '../../../../../core/services/database_service.dart';
import '../../../../../core/services/user_session_service.dart';
import '../../models/account_invoice_model.dart';
import '../../../../../core/dao/account_invoices_dao.dart';

abstract class AccountInvoicesLocalDataSource {
  /// Cache account invoices for a specific account
  Future<void> cacheAccountInvoices(
    String accountId,
    List<AccountInvoiceModel> invoices,
  );

  /// Get cached account invoices for a specific account
  Future<List<AccountInvoiceModel>> getCachedAccountInvoices(String accountId);

  /// Get cached paginated invoices for a specific account
  Future<List<AccountInvoiceModel>> getCachedPaginatedInvoices(
    String accountId,
  );

  /// Cache a single account invoice
  Future<void> cacheAccountInvoice(AccountInvoiceModel invoice);

  /// Get a cached account invoice by ID
  Future<AccountInvoiceModel?> getCachedAccountInvoice(String invoiceId);

  /// Update a cached account invoice
  Future<void> updateCachedInvoice(AccountInvoiceModel invoice);

  /// Delete a cached account invoice
  Future<void> deleteCachedInvoice(String invoiceId);

  /// Clear all cached invoices for an account
  Future<void> clearCachedInvoices(String accountId);

  /// Clear all cached invoices
  Future<void> clearAllCachedInvoices();
}

@Injectable(as: AccountInvoicesLocalDataSource)
class AccountInvoicesLocalDataSourceImpl
    implements AccountInvoicesLocalDataSource {
  final DatabaseService _databaseService;
  final UserSessionService _userSessionService;
  final Logger _logger;

  AccountInvoicesLocalDataSourceImpl(
    this._databaseService,
    this._userSessionService,
    this._logger,
  );

  @override
  Future<void> cacheAccountInvoices(
    String accountId,
    List<AccountInvoiceModel> invoices,
  ) async {
    try {
      // Check for user context and restore if needed
      var currentUserId = _userSessionService.getCurrentUserIdOrNull();
      if (currentUserId == null) {
        _logger.w('No active user context, attempting to restore user context');
        try {
          await _userSessionService.restoreCurrentUserContext();
          currentUserId = _userSessionService.getCurrentUserIdOrNull();
          if (currentUserId == null) {
            _logger.w(
              'Failed to restore user context, skipping invoice caching',
            );
            return;
          } else {
            _logger.i('User context restored successfully: $currentUserId');
          }
        } catch (e) {
          _logger.e('Error restoring user context: $e');
          return;
        }
      }
      // Log the user ID we're using
      _logger.d('Using user ID: $currentUserId');

      // Use transaction for batch operations
      final db = await _databaseService.database;
      await db.transaction((txn) async {
        for (final invoice in invoices) {
          // Insert or update invoice directly in transaction
          await AccountInvoicesDao.insertOrUpdate(db, invoice);
          _logger.d(
            'Cached invoice: ${invoice.invoiceId} for account: $accountId',
          );
        }
      });

      _logger.d('Cached ${invoices.length} invoices for account: $accountId');
    } catch (e) {
      _logger.e('Error caching invoices for account $accountId: $e');
      rethrow;
    }
  }

  @override
  Future<List<AccountInvoiceModel>> getCachedAccountInvoices(
    String accountId,
  ) async {
    try {
      // Check for user context and restore if needed
      var currentUserId = _userSessionService.getCurrentUserIdOrNull();
      if (currentUserId == null) {
        _logger.w('No active user context, attempting to restore user context');
        try {
          await _userSessionService.restoreCurrentUserContext();
          currentUserId = _userSessionService.getCurrentUserIdOrNull();
          if (currentUserId == null) {
            _logger.w(
              'Failed to restore user context, returning empty invoices list',
            );
            return [];
          } else {
            _logger.i('User context restored successfully: $currentUserId');
          }
        } catch (e) {
          _logger.e('Error restoring user context: $e');
          return [];
        }
      }
      // Log the user ID we're using
      _logger.d('Using user ID: $currentUserId');

      final db = await _databaseService.database;
      final invoices = await AccountInvoicesDao.getByAccountId(db, accountId);
      _logger.d(
        'Retrieved ${invoices.length} cached invoices for account: $accountId',
      );
      return invoices;
    } catch (e) {
      _logger.e('Error getting cached invoices for account $accountId: $e');
      rethrow;
    }
  }

  @override
  Future<List<AccountInvoiceModel>> getCachedPaginatedInvoices(
    String accountId,
  ) async {
    try {
      final db = await _databaseService.database;
      final invoices = await AccountInvoicesDao.getWithPagination(
        db,
        accountId,
        0,
        50,
      );
      _logger.d(
        'Retrieved ${invoices.length} cached paginated invoices for account: $accountId',
      );
      return invoices;
    } catch (e) {
      _logger.e(
        'Error getting cached paginated invoices for account $accountId: $e',
      );
      rethrow;
    }
  }

  @override
  Future<void> cacheAccountInvoice(AccountInvoiceModel invoice) async {
    try {
      final db = await _databaseService.database;
      final exists = await AccountInvoicesDao.exists(db, invoice.invoiceId);

      if (exists) {
        await AccountInvoicesDao.update(db, invoice);
        _logger.d('Updated cached invoice: ${invoice.invoiceId}');
      } else {
        await AccountInvoicesDao.insertOrUpdate(db, invoice);
        _logger.d('Cached new invoice: ${invoice.invoiceId}');
      }
    } catch (e) {
      _logger.e('Error caching invoice ${invoice.invoiceId}: $e');
      rethrow;
    }
  }

  @override
  Future<AccountInvoiceModel?> getCachedAccountInvoice(String invoiceId) async {
    try {
      final db = await _databaseService.database;
      final invoice = await AccountInvoicesDao.getById(db, invoiceId);
      if (invoice != null) {
        _logger.d('Retrieved cached invoice: $invoiceId');
      } else {
        _logger.d('Invoice not found in cache: $invoiceId');
      }
      return invoice;
    } catch (e) {
      _logger.e('Error getting cached invoice $invoiceId: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateCachedInvoice(AccountInvoiceModel invoice) async {
    try {
      final db = await _databaseService.database;
      await AccountInvoicesDao.update(db, invoice);
      _logger.d('Updated cached invoice: ${invoice.invoiceId}');
    } catch (e) {
      _logger.e('Error updating cached invoice ${invoice.invoiceId}: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteCachedInvoice(String invoiceId) async {
    try {
      final db = await _databaseService.database;
      await AccountInvoicesDao.delete(db, invoiceId);
      _logger.d('Deleted cached invoice: $invoiceId');
    } catch (e) {
      _logger.e('Error deleting cached invoice $invoiceId: $e');
      rethrow;
    }
  }

  @override
  Future<void> clearCachedInvoices(String accountId) async {
    try {
      final db = await _databaseService.database;
      await AccountInvoicesDao.deleteByAccountId(db, accountId);
      _logger.d('Cleared cached invoices for account: $accountId');
    } catch (e) {
      _logger.e('Error clearing cached invoices for account $accountId: $e');
      rethrow;
    }
  }

  @override
  Future<void> clearAllCachedInvoices() async {
    try {
      final db = await _databaseService.database;
      await AccountInvoicesDao.deleteAll(db);
      _logger.d('Cleared all cached invoices');
    } catch (e) {
      _logger.e('Error clearing all cached invoices: $e');
      rethrow;
    }
  }
}
