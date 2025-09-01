import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import '../../../../../core/services/database_service.dart';
import '../../../../../core/dao/account_invoice_payment_dao.dart';
import '../../models/account_invoice_payment_model.dart';

abstract class AccountInvoicePaymentsLocalDataSource {
  Future<void> cacheAccountInvoicePayments(
    String accountId,
    List<AccountInvoicePaymentModel> payments,
  );
  Future<void> cacheAccountInvoicePayment(AccountInvoicePaymentModel payment);
  Future<List<AccountInvoicePaymentModel>> getCachedAccountInvoicePayments(
    String accountId,
  );
  Future<AccountInvoicePaymentModel?> getCachedAccountInvoicePayment(String id);
  Future<List<AccountInvoicePaymentModel>> getCachedInvoicePaymentsByStatus(
    String accountId,
    String status,
  );
  Future<List<AccountInvoicePaymentModel>> getCachedInvoicePaymentsByDateRange(
    String accountId,
    DateTime startDate,
    DateTime endDate,
  );
  Future<List<AccountInvoicePaymentModel>> getCachedInvoicePaymentsByMethod(
    String accountId,
    String paymentMethod,
  );
  Future<List<AccountInvoicePaymentModel>>
  getCachedInvoicePaymentsByInvoiceNumber(
    String accountId,
    String invoiceNumber,
  );
  Future<List<AccountInvoicePaymentModel>>
  getCachedInvoicePaymentsWithPagination(
    String accountId,
    int page,
    int pageSize,
  );
  Future<List<AccountInvoicePaymentModel>> getAllCachedInvoicePayments();
  Future<List<AccountInvoicePaymentModel>> searchCachedInvoicePaymentsByNotes(
    String accountId,
    String searchTerm,
  );
  Future<AccountInvoicePaymentModel?> getCachedInvoicePaymentByTransactionId(
    String transactionId,
  );
  Future<void> updateCachedInvoicePayment(AccountInvoicePaymentModel payment);
  Future<void> deleteCachedInvoicePayment(String id);
  Future<void> deleteCachedInvoicePayments(String accountId);
  Future<void> clearAllCachedInvoicePayments();
  Future<int> getCachedInvoicePaymentsCount(String accountId);
  Future<int> getCachedInvoicePaymentsCountByStatus(
    String accountId,
    String status,
  );
  Future<int> getTotalCachedInvoicePaymentsCount();
  Future<double> getCachedInvoicePaymentsTotalAmount(String accountId);
  Future<double> getCachedInvoicePaymentsTotalAmountByStatus(
    String accountId,
    String status,
  );
  Future<bool> hasCachedInvoicePayments(String accountId);
}

@Injectable(as: AccountInvoicePaymentsLocalDataSource)
class AccountInvoicePaymentsLocalDataSourceImpl
    implements AccountInvoicePaymentsLocalDataSource {
  final DatabaseService _databaseService;
  final Logger _logger;

  AccountInvoicePaymentsLocalDataSourceImpl(
    this._databaseService,
    this._logger,
  );

  @override
  Future<void> cacheAccountInvoicePayments(
    String accountId,
    List<AccountInvoicePaymentModel> payments,
  ) async {
    try {
      final db = await _databaseService.database;
      await AccountInvoicePaymentDao.insertMultiple(db, payments);
      _logger.d(
        'Cached ${payments.length} invoice payments for account: $accountId',
      );
    } catch (e) {
      _logger.e('Error caching invoice payments for account $accountId: $e');
      rethrow;
    }
  }

  @override
  Future<void> cacheAccountInvoicePayment(
    AccountInvoicePaymentModel payment,
  ) async {
    try {
      final db = await _databaseService.database;
      await AccountInvoicePaymentDao.insertOrUpdate(db, payment);
      _logger.d(
        'Cached invoice payment: ${payment.id} for account: ${payment.accountId}',
      );
    } catch (e) {
      _logger.e('Error caching invoice payment ${payment.id}: $e');
      rethrow;
    }
  }

  @override
  Future<List<AccountInvoicePaymentModel>> getCachedAccountInvoicePayments(
    String accountId,
  ) async {
    try {
      final db = await _databaseService.database;
      final payments = await AccountInvoicePaymentDao.getByAccountId(
        db,
        accountId,
      );
      _logger.d(
        'Retrieved ${payments.length} cached invoice payments for account: $accountId',
      );
      return payments;
    } catch (e) {
      _logger.e(
        'Error retrieving cached invoice payments for account $accountId: $e',
      );
      rethrow;
    }
  }

  @override
  Future<AccountInvoicePaymentModel?> getCachedAccountInvoicePayment(
    String id,
  ) async {
    try {
      final db = await _databaseService.database;
      final payment = await AccountInvoicePaymentDao.getById(db, id);
      if (payment != null) {
        _logger.d('Retrieved cached invoice payment: $id');
      } else {
        _logger.d('No cached invoice payment found: $id');
      }
      return payment;
    } catch (e) {
      _logger.e('Error retrieving cached invoice payment $id: $e');
      rethrow;
    }
  }

  @override
  Future<List<AccountInvoicePaymentModel>> getCachedInvoicePaymentsByStatus(
    String accountId,
    String status,
  ) async {
    try {
      final db = await _databaseService.database;
      final payments = await AccountInvoicePaymentDao.getByStatus(
        db,
        accountId,
        status,
      );
      _logger.d(
        'Retrieved ${payments.length} cached invoice payments with status $status for account: $accountId',
      );
      return payments;
    } catch (e) {
      _logger.e(
        'Error retrieving cached invoice payments with status $status for account $accountId: $e',
      );
      rethrow;
    }
  }

  @override
  Future<List<AccountInvoicePaymentModel>> getCachedInvoicePaymentsByDateRange(
    String accountId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final db = await _databaseService.database;
      final payments = await AccountInvoicePaymentDao.getByDateRange(
        db,
        accountId,
        startDate,
        endDate,
      );
      _logger.d(
        'Retrieved ${payments.length} cached invoice payments in date range for account: $accountId',
      );
      return payments;
    } catch (e) {
      _logger.e(
        'Error retrieving cached invoice payments in date range for account $accountId: $e',
      );
      rethrow;
    }
  }

  @override
  Future<List<AccountInvoicePaymentModel>> getCachedInvoicePaymentsByMethod(
    String accountId,
    String paymentMethod,
  ) async {
    try {
      final db = await _databaseService.database;
      final payments = await AccountInvoicePaymentDao.getByPaymentMethod(
        db,
        accountId,
        paymentMethod,
      );
      _logger.d(
        'Retrieved ${payments.length} cached invoice payments with method $paymentMethod for account: $accountId',
      );
      return payments;
    } catch (e) {
      _logger.e(
        'Error retrieving cached invoice payments with method $paymentMethod for account $accountId: $e',
      );
      rethrow;
    }
  }

  @override
  Future<List<AccountInvoicePaymentModel>>
  getCachedInvoicePaymentsByInvoiceNumber(
    String accountId,
    String invoiceNumber,
  ) async {
    try {
      final db = await _databaseService.database;
      final payments = await AccountInvoicePaymentDao.getByInvoiceNumber(
        db,
        accountId,
        invoiceNumber,
      );
      _logger.d(
        'Retrieved ${payments.length} cached invoice payments for invoice $invoiceNumber, account: $accountId',
      );
      return payments;
    } catch (e) {
      _logger.e(
        'Error retrieving cached invoice payments for invoice $invoiceNumber, account $accountId: $e',
      );
      rethrow;
    }
  }

  @override
  Future<List<AccountInvoicePaymentModel>>
  getCachedInvoicePaymentsWithPagination(
    String accountId,
    int page,
    int pageSize,
  ) async {
    try {
      final db = await _databaseService.database;
      final payments = await AccountInvoicePaymentDao.getWithPagination(
        db,
        accountId,
        page,
        pageSize,
      );
      _logger.d(
        'Retrieved ${payments.length} cached invoice payments (page $page, size $pageSize) for account: $accountId',
      );
      return payments;
    } catch (e) {
      _logger.e(
        'Error retrieving cached invoice payments with pagination for account $accountId: $e',
      );
      rethrow;
    }
  }

  @override
  Future<List<AccountInvoicePaymentModel>> getAllCachedInvoicePayments() async {
    try {
      final db = await _databaseService.database;
      final payments = await AccountInvoicePaymentDao.getAll(db);
      _logger.d('Retrieved ${payments.length} total cached invoice payments');
      return payments;
    } catch (e) {
      _logger.e('Error retrieving all cached invoice payments: $e');
      rethrow;
    }
  }

  @override
  Future<List<AccountInvoicePaymentModel>> searchCachedInvoicePaymentsByNotes(
    String accountId,
    String searchTerm,
  ) async {
    try {
      final db = await _databaseService.database;
      final payments = await AccountInvoicePaymentDao.searchByNotes(
        db,
        accountId,
        searchTerm,
      );
      _logger.d(
        'Searched cached invoice payments by notes: $searchTerm, found ${payments.length} results for account: $accountId',
      );
      return payments;
    } catch (e) {
      _logger.e(
        'Error searching cached invoice payments by notes $searchTerm for account $accountId: $e',
      );
      rethrow;
    }
  }

  @override
  Future<AccountInvoicePaymentModel?> getCachedInvoicePaymentByTransactionId(
    String transactionId,
  ) async {
    try {
      final db = await _databaseService.database;
      final payment = await AccountInvoicePaymentDao.getByTransactionId(
        db,
        transactionId,
      );
      if (payment != null) {
        _logger.d(
          'Retrieved cached invoice payment by transaction ID: $transactionId',
        );
      } else {
        _logger.d(
          'No cached invoice payment found by transaction ID: $transactionId',
        );
      }
      return payment;
    } catch (e) {
      _logger.e(
        'Error retrieving cached invoice payment by transaction ID $transactionId: $e',
      );
      rethrow;
    }
  }

  @override
  Future<void> updateCachedInvoicePayment(
    AccountInvoicePaymentModel payment,
  ) async {
    try {
      final db = await _databaseService.database;
      await AccountInvoicePaymentDao.update(db, payment);
      _logger.d(
        'Updated cached invoice payment: ${payment.id} for account: ${payment.accountId}',
      );
    } catch (e) {
      _logger.e('Error updating cached invoice payment ${payment.id}: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteCachedInvoicePayment(String id) async {
    try {
      final db = await _databaseService.database;
      await AccountInvoicePaymentDao.delete(db, id);
      _logger.d('Deleted cached invoice payment: $id');
    } catch (e) {
      _logger.e('Error deleting cached invoice payment $id: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteCachedInvoicePayments(String accountId) async {
    try {
      final db = await _databaseService.database;
      await AccountInvoicePaymentDao.deleteByAccountId(db, accountId);
      _logger.d('Deleted all cached invoice payments for account: $accountId');
    } catch (e) {
      _logger.e(
        'Error deleting cached invoice payments for account $accountId: $e',
      );
      rethrow;
    }
  }

  @override
  Future<void> clearAllCachedInvoicePayments() async {
    try {
      final db = await _databaseService.database;
      await AccountInvoicePaymentDao.deleteAll(db);
      _logger.d('Cleared all cached invoice payments');
    } catch (e) {
      _logger.e('Error clearing all cached invoice payments: $e');
      rethrow;
    }
  }

  @override
  Future<int> getCachedInvoicePaymentsCount(String accountId) async {
    try {
      final db = await _databaseService.database;
      final count = await AccountInvoicePaymentDao.getCountByAccountId(
        db,
        accountId,
      );
      _logger.d(
        'Retrieved cached invoice payments count for account $accountId: $count',
      );
      return count;
    } catch (e) {
      _logger.e(
        'Error retrieving cached invoice payments count for account $accountId: $e',
      );
      rethrow;
    }
  }

  @override
  Future<int> getCachedInvoicePaymentsCountByStatus(
    String accountId,
    String status,
  ) async {
    try {
      final db = await _databaseService.database;
      final count = await AccountInvoicePaymentDao.getCountByStatus(
        db,
        accountId,
        status,
      );
      _logger.d(
        'Retrieved cached invoice payments count with status $status for account $accountId: $count',
      );
      return count;
    } catch (e) {
      _logger.e(
        'Error retrieving cached invoice payments count with status $status for account $accountId: $e',
      );
      rethrow;
    }
  }

  @override
  Future<int> getTotalCachedInvoicePaymentsCount() async {
    try {
      final db = await _databaseService.database;
      final count = await AccountInvoicePaymentDao.getTotalCount(db);
      _logger.d('Retrieved total cached invoice payments count: $count');
      return count;
    } catch (e) {
      _logger.e('Error retrieving total cached invoice payments count: $e');
      rethrow;
    }
  }

  @override
  Future<double> getCachedInvoicePaymentsTotalAmount(String accountId) async {
    try {
      final db = await _databaseService.database;
      final amount = await AccountInvoicePaymentDao.getTotalAmountByAccountId(
        db,
        accountId,
      );
      _logger.d(
        'Retrieved cached invoice payments total amount for account $accountId: $amount',
      );
      return amount;
    } catch (e) {
      _logger.e(
        'Error retrieving cached invoice payments total amount for account $accountId: $e',
      );
      rethrow;
    }
  }

  @override
  Future<double> getCachedInvoicePaymentsTotalAmountByStatus(
    String accountId,
    String status,
  ) async {
    try {
      final db = await _databaseService.database;
      final amount = await AccountInvoicePaymentDao.getTotalAmountByStatus(
        db,
        accountId,
        status,
      );
      _logger.d(
        'Retrieved cached invoice payments total amount with status $status for account $accountId: $amount',
      );
      return amount;
    } catch (e) {
      _logger.e(
        'Error retrieving cached invoice payments total amount with status $status for account $accountId: $e',
      );
      rethrow;
    }
  }

  @override
  Future<bool> hasCachedInvoicePayments(String accountId) async {
    try {
      final count = await getCachedInvoicePaymentsCount(accountId);
      final hasPayments = count > 0;
      _logger.d('Account $accountId has cached invoice payments: $hasPayments');
      return hasPayments;
    } catch (e) {
      _logger.e(
        'Error checking if account $accountId has cached invoice payments: $e',
      );
      rethrow;
    }
  }
}
