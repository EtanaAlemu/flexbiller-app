import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import '../../../../../core/services/database_service.dart';
import '../../../../../core/services/user_session_service.dart';
import '../../../../../core/dao/account_payment_dao.dart';
import '../../models/account_payment_model.dart';

abstract class AccountPaymentsLocalDataSource {
  Future<void> cacheAccountPayments(
    String accountId,
    List<AccountPaymentModel> payments,
  );
  Future<void> cacheAccountPayment(AccountPaymentModel payment);
  Future<List<AccountPaymentModel>> getCachedAccountPayments(String accountId);
  Future<AccountPaymentModel?> getCachedAccountPayment(String id);
  Future<List<AccountPaymentModel>> getCachedPaymentsByStatus(
    String accountId,
    String paymentStatus,
  );
  Future<List<AccountPaymentModel>> getCachedPaymentsByType(
    String accountId,
    String paymentType,
  );
  Future<List<AccountPaymentModel>> getCachedPaymentsByPaymentMethodId(
    String accountId,
    String paymentMethodId,
  );
  Future<List<AccountPaymentModel>> getCachedPaymentsByDateRange(
    String accountId,
    DateTime startDate,
    DateTime endDate,
  );
  Future<List<AccountPaymentModel>> getCachedPaymentsWithPagination(
    String accountId,
    int page,
    int pageSize,
  );
  Future<List<AccountPaymentModel>> getAllCachedPayments();
  Future<List<AccountPaymentModel>> getCachedSuccessfulPayments(
    String accountId,
  );
  Future<List<AccountPaymentModel>> getCachedFailedPayments(String accountId);
  Future<List<AccountPaymentModel>> getCachedPendingPayments(String accountId);
  Future<List<AccountPaymentModel>> getCachedRefundedPayments(String accountId);
  Future<List<AccountPaymentModel>> searchCachedPaymentsByText(
    String accountId,
    String searchTerm,
  );
  Future<AccountPaymentModel?> getCachedPaymentByTransactionId(
    String transactionId,
  );
  Future<List<AccountPaymentModel>> getCachedPaymentsByReferenceNumber(
    String accountId,
    String referenceNumber,
  );
  Future<List<AccountPaymentModel>> getCachedPaymentsByCurrency(
    String accountId,
    String currency,
  );
  Future<void> updateCachedPayment(AccountPaymentModel payment);
  Future<void> updateCachedPaymentStatus(String paymentId, String newStatus);
  Future<void> markCachedPaymentAsProcessed(
    String paymentId,
    DateTime processedDate,
  );
  Future<void> markCachedPaymentAsRefunded(
    String paymentId,
    double refundedAmount,
    DateTime refundedDate,
    String refundReason,
  );
  Future<void> deleteCachedPayment(String id);
  Future<void> deleteCachedPayments(String accountId);
  Future<void> clearAllCachedPayments();
  Future<int> getCachedPaymentsCount(String accountId);
  Future<int> getCachedPaymentsCountByStatus(
    String accountId,
    String paymentStatus,
  );
  Future<int> getCachedPaymentsCountByType(
    String accountId,
    String paymentType,
  );
  Future<int> getTotalCachedPaymentsCount();
  Future<double> getCachedPaymentsTotalAmount(String accountId);
  Future<double> getCachedPaymentsTotalAmountByStatus(
    String accountId,
    String paymentStatus,
  );
  Future<double> getCachedPaymentsTotalRefundedAmount(String accountId);
  Future<bool> hasCachedPayments(String accountId);
}

@Injectable(as: AccountPaymentsLocalDataSource)
class AccountPaymentsLocalDataSourceImpl
    implements AccountPaymentsLocalDataSource {
  final DatabaseService _databaseService;
  final UserSessionService _userSessionService;
  final Logger _logger;

  AccountPaymentsLocalDataSourceImpl(
    this._databaseService,
    this._userSessionService,
    this._logger,
  );

  @override
  Future<void> cacheAccountPayments(
    String accountId,
    List<AccountPaymentModel> payments,
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
              'Failed to restore user context, skipping payments caching',
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
      // If we have a user ID, proceed even if hasActiveUser is false
      if (currentUserId != null) {
        _logger.d('Using restored user ID: $currentUserId');
      }

      final db = await _databaseService.database;
      await AccountPaymentDao.insertMultiple(db, payments);
      _logger.d('Cached ${payments.length} payments for account: $accountId');
    } catch (e) {
      _logger.e('Error caching payments for account $accountId: $e');
      rethrow;
    }
  }

  @override
  Future<void> cacheAccountPayment(AccountPaymentModel payment) async {
    try {
      final db = await _databaseService.database;
      await AccountPaymentDao.insertOrUpdate(db, payment);
      _logger.d(
        'Cached payment: ${payment.id} for account: ${payment.accountId}',
      );
    } catch (e) {
      _logger.e('Error caching payment ${payment.id}: $e');
      rethrow;
    }
  }

  @override
  Future<List<AccountPaymentModel>> getCachedAccountPayments(
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
              'Failed to restore user context, returning empty payments list',
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
      // If we have a user ID, proceed even if hasActiveUser is false
      if (currentUserId != null) {
        _logger.d('Using restored user ID: $currentUserId');
      }

      final db = await _databaseService.database;
      final payments = await AccountPaymentDao.getByAccountId(db, accountId);
      _logger.d(
        'Retrieved ${payments.length} cached payments for account: $accountId',
      );
      return payments;
    } catch (e) {
      _logger.e('Error retrieving cached payments for account $accountId: $e');
      rethrow;
    }
  }

  @override
  Future<AccountPaymentModel?> getCachedAccountPayment(String id) async {
    try {
      final db = await _databaseService.database;
      final payment = await AccountPaymentDao.getById(db, id);
      if (payment != null) {
        _logger.d('Retrieved cached payment: $id');
      } else {
        _logger.d('No cached payment found: $id');
      }
      return payment;
    } catch (e) {
      _logger.e('Error retrieving cached payment $id: $e');
      rethrow;
    }
  }

  @override
  Future<List<AccountPaymentModel>> getCachedPaymentsByStatus(
    String accountId,
    String paymentStatus,
  ) async {
    try {
      final db = await _databaseService.database;
      final payments = await AccountPaymentDao.getByStatus(
        db,
        accountId,
        paymentStatus,
      );
      _logger.d(
        'Retrieved ${payments.length} cached payments with status $paymentStatus for account: $accountId',
      );
      return payments;
    } catch (e) {
      _logger.e(
        'Error retrieving cached payments with status $paymentStatus for account $accountId: $e',
      );
      rethrow;
    }
  }

  @override
  Future<List<AccountPaymentModel>> getCachedPaymentsByType(
    String accountId,
    String paymentType,
  ) async {
    try {
      final db = await _databaseService.database;
      final payments = await AccountPaymentDao.getByType(
        db,
        accountId,
        paymentType,
      );
      _logger.d(
        'Retrieved ${payments.length} cached payments with type $paymentType for account: $accountId',
      );
      return payments;
    } catch (e) {
      _logger.e(
        'Error retrieving cached payments with type $paymentType for account $accountId: $e',
      );
      rethrow;
    }
  }

  @override
  Future<List<AccountPaymentModel>> getCachedPaymentsByPaymentMethodId(
    String accountId,
    String paymentMethodId,
  ) async {
    try {
      final db = await _databaseService.database;
      final payments = await AccountPaymentDao.getByPaymentMethodId(
        db,
        accountId,
        paymentMethodId,
      );
      _logger.d(
        'Retrieved ${payments.length} cached payments with payment method $paymentMethodId for account: $accountId',
      );
      return payments;
    } catch (e) {
      _logger.e(
        'Error retrieving cached payments with payment method $paymentMethodId for account $accountId: $e',
      );
      rethrow;
    }
  }

  @override
  Future<List<AccountPaymentModel>> getCachedPaymentsByDateRange(
    String accountId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final db = await _databaseService.database;
      final payments = await AccountPaymentDao.getByDateRange(
        db,
        accountId,
        startDate,
        endDate,
      );
      _logger.d(
        'Retrieved ${payments.length} cached payments in date range for account: $accountId',
      );
      return payments;
    } catch (e) {
      _logger.e(
        'Error retrieving cached payments in date range for account $accountId: $e',
      );
      rethrow;
    }
  }

  @override
  Future<List<AccountPaymentModel>> getCachedPaymentsWithPagination(
    String accountId,
    int page,
    int pageSize,
  ) async {
    try {
      final db = await _databaseService.database;
      final payments = await AccountPaymentDao.getWithPagination(
        db,
        accountId,
        page,
        pageSize,
      );
      _logger.d(
        'Retrieved ${payments.length} cached payments (page $page, size $pageSize) for account: $accountId',
      );
      return payments;
    } catch (e) {
      _logger.e(
        'Error retrieving cached payments with pagination for account $accountId: $e',
      );
      rethrow;
    }
  }

  @override
  Future<List<AccountPaymentModel>> getAllCachedPayments() async {
    try {
      final db = await _databaseService.database;
      final payments = await AccountPaymentDao.getAll(db);
      _logger.d('Retrieved ${payments.length} total cached payments');
      return payments;
    } catch (e) {
      _logger.e('Error retrieving all cached payments: $e');
      rethrow;
    }
  }

  @override
  Future<List<AccountPaymentModel>> getCachedSuccessfulPayments(
    String accountId,
  ) async {
    try {
      final db = await _databaseService.database;
      final payments = await AccountPaymentDao.getSuccessfulPayments(
        db,
        accountId,
      );
      _logger.d(
        'Retrieved ${payments.length} cached successful payments for account: $accountId',
      );
      return payments;
    } catch (e) {
      _logger.e(
        'Error retrieving cached successful payments for account $accountId: $e',
      );
      rethrow;
    }
  }

  @override
  Future<List<AccountPaymentModel>> getCachedFailedPayments(
    String accountId,
  ) async {
    try {
      final db = await _databaseService.database;
      final payments = await AccountPaymentDao.getFailedPayments(db, accountId);
      _logger.d(
        'Retrieved ${payments.length} cached failed payments for account: $accountId',
      );
      return payments;
    } catch (e) {
      _logger.e(
        'Error retrieving cached failed payments for account $accountId: $e',
      );
      rethrow;
    }
  }

  @override
  Future<List<AccountPaymentModel>> getCachedPendingPayments(
    String accountId,
  ) async {
    try {
      final db = await _databaseService.database;
      final payments = await AccountPaymentDao.getPendingPayments(
        db,
        accountId,
      );
      _logger.d(
        'Retrieved ${payments.length} cached pending payments for account: $accountId',
      );
      return payments;
    } catch (e) {
      _logger.e(
        'Error retrieving cached pending payments for account $accountId: $e',
      );
      rethrow;
    }
  }

  @override
  Future<List<AccountPaymentModel>> getCachedRefundedPayments(
    String accountId,
  ) async {
    try {
      final db = await _databaseService.database;
      final payments = await AccountPaymentDao.getRefundedPayments(
        db,
        accountId,
      );
      _logger.d(
        'Retrieved ${payments.length} cached refunded payments for account: $accountId',
      );
      return payments;
    } catch (e) {
      _logger.e(
        'Error retrieving cached refunded payments for account $accountId: $e',
      );
      rethrow;
    }
  }

  @override
  Future<List<AccountPaymentModel>> searchCachedPaymentsByText(
    String accountId,
    String searchTerm,
  ) async {
    try {
      final db = await _databaseService.database;
      final payments = await AccountPaymentDao.searchByText(
        db,
        accountId,
        searchTerm,
      );
      _logger.d(
        'Searched cached payments by text: $searchTerm, found ${payments.length} results for account: $accountId',
      );
      return payments;
    } catch (e) {
      _logger.e(
        'Error searching cached payments by text $searchTerm for account $accountId: $e',
      );
      rethrow;
    }
  }

  @override
  Future<AccountPaymentModel?> getCachedPaymentByTransactionId(
    String transactionId,
  ) async {
    try {
      final db = await _databaseService.database;
      final payment = await AccountPaymentDao.getByTransactionId(
        db,
        transactionId,
      );
      if (payment != null) {
        _logger.d('Retrieved cached payment by transaction ID: $transactionId');
      } else {
        _logger.d('No cached payment found by transaction ID: $transactionId');
      }
      return payment;
    } catch (e) {
      _logger.e(
        'Error retrieving cached payment by transaction ID $transactionId: $e',
      );
      rethrow;
    }
  }

  @override
  Future<List<AccountPaymentModel>> getCachedPaymentsByReferenceNumber(
    String accountId,
    String referenceNumber,
  ) async {
    try {
      final db = await _databaseService.database;
      final payments = await AccountPaymentDao.getByReferenceNumber(
        db,
        accountId,
        referenceNumber,
      );
      _logger.d(
        'Retrieved ${payments.length} cached payments with reference number $referenceNumber for account: $accountId',
      );
      return payments;
    } catch (e) {
      _logger.e(
        'Error retrieving cached payments with reference number $referenceNumber for account $accountId: $e',
      );
      rethrow;
    }
  }

  @override
  Future<List<AccountPaymentModel>> getCachedPaymentsByCurrency(
    String accountId,
    String currency,
  ) async {
    try {
      final db = await _databaseService.database;
      final payments = await AccountPaymentDao.getByCurrency(
        db,
        accountId,
        currency,
      );
      _logger.d(
        'Retrieved ${payments.length} cached payments with currency $currency for account: $accountId',
      );
      return payments;
    } catch (e) {
      _logger.e(
        'Error retrieving cached payments with currency $currency for account $accountId: $e',
      );
      rethrow;
    }
  }

  @override
  Future<void> updateCachedPayment(AccountPaymentModel payment) async {
    try {
      final db = await _databaseService.database;
      await AccountPaymentDao.update(db, payment);
      _logger.d(
        'Updated cached payment: ${payment.id} for account: ${payment.accountId}',
      );
    } catch (e) {
      _logger.e('Error updating cached payment ${payment.id}: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateCachedPaymentStatus(
    String paymentId,
    String newStatus,
  ) async {
    try {
      final db = await _databaseService.database;
      await AccountPaymentDao.updatePaymentStatus(db, paymentId, newStatus);
      _logger.d('Updated cached payment status: $paymentId to $newStatus');
    } catch (e) {
      _logger.e(
        'Error updating cached payment status $paymentId to $newStatus: $e',
      );
      rethrow;
    }
  }

  @override
  Future<void> markCachedPaymentAsProcessed(
    String paymentId,
    DateTime processedDate,
  ) async {
    try {
      final db = await _databaseService.database;
      await AccountPaymentDao.markAsProcessed(db, paymentId, processedDate);
      _logger.d('Marked cached payment as processed: $paymentId');
    } catch (e) {
      _logger.e('Error marking cached payment as processed $paymentId: $e');
      rethrow;
    }
  }

  @override
  Future<void> markCachedPaymentAsRefunded(
    String paymentId,
    double refundedAmount,
    DateTime refundedDate,
    String refundReason,
  ) async {
    try {
      final db = await _databaseService.database;
      await AccountPaymentDao.markAsRefunded(
        db,
        paymentId,
        refundedAmount,
        refundedDate,
        refundReason,
      );
      _logger.d('Marked cached payment as refunded: $paymentId');
    } catch (e) {
      _logger.e('Error marking cached payment as refunded $paymentId: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteCachedPayment(String id) async {
    try {
      final db = await _databaseService.database;
      await AccountPaymentDao.delete(db, id);
      _logger.d('Deleted cached payment: $id');
    } catch (e) {
      _logger.e('Error deleting cached payment $id: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteCachedPayments(String accountId) async {
    try {
      final db = await _databaseService.database;
      await AccountPaymentDao.deleteByAccountId(db, accountId);
      _logger.d('Deleted all cached payments for account: $accountId');
    } catch (e) {
      _logger.e('Error deleting cached payments for account $accountId: $e');
      rethrow;
    }
  }

  @override
  Future<void> clearAllCachedPayments() async {
    try {
      final db = await _databaseService.database;
      await AccountPaymentDao.deleteAll(db);
      _logger.d('Cleared all cached payments');
    } catch (e) {
      _logger.e('Error clearing all cached payments: $e');
      rethrow;
    }
  }

  @override
  Future<int> getCachedPaymentsCount(String accountId) async {
    try {
      final db = await _databaseService.database;
      final count = await AccountPaymentDao.getCountByAccountId(db, accountId);
      _logger.d(
        'Retrieved cached payments count for account $accountId: $count',
      );
      return count;
    } catch (e) {
      _logger.e(
        'Error retrieving cached payments count for account $accountId: $e',
      );
      rethrow;
    }
  }

  @override
  Future<int> getCachedPaymentsCountByStatus(
    String accountId,
    String paymentStatus,
  ) async {
    try {
      final db = await _databaseService.database;
      final count = await AccountPaymentDao.getCountByStatus(
        db,
        accountId,
        paymentStatus,
      );
      _logger.d(
        'Retrieved cached payments count with status $paymentStatus for account $accountId: $count',
      );
      return count;
    } catch (e) {
      _logger.e(
        'Error retrieving cached payments count with status $paymentStatus for account $accountId: $e',
      );
      rethrow;
    }
  }

  @override
  Future<int> getCachedPaymentsCountByType(
    String accountId,
    String paymentType,
  ) async {
    try {
      final db = await _databaseService.database;
      final count = await AccountPaymentDao.getCountByType(
        db,
        accountId,
        paymentType,
      );
      _logger.d(
        'Retrieved cached payments count with type $paymentType for account $accountId: $count',
      );
      return count;
    } catch (e) {
      _logger.e(
        'Error retrieving cached payments count with type $paymentType for account $accountId: $e',
      );
      rethrow;
    }
  }

  @override
  Future<int> getTotalCachedPaymentsCount() async {
    try {
      final db = await _databaseService.database;
      final count = await AccountPaymentDao.getTotalCount(db);
      _logger.d('Retrieved total cached payments count: $count');
      return count;
    } catch (e) {
      _logger.e('Error retrieving total cached payments count: $e');
      rethrow;
    }
  }

  @override
  Future<double> getCachedPaymentsTotalAmount(String accountId) async {
    try {
      final db = await _databaseService.database;
      final amount = await AccountPaymentDao.getTotalAmountByAccountId(
        db,
        accountId,
      );
      _logger.d(
        'Retrieved cached payments total amount for account $accountId: $amount',
      );
      return amount;
    } catch (e) {
      _logger.e(
        'Error retrieving cached payments total amount for account $accountId: $e',
      );
      rethrow;
    }
  }

  @override
  Future<double> getCachedPaymentsTotalAmountByStatus(
    String accountId,
    String paymentStatus,
  ) async {
    try {
      final db = await _databaseService.database;
      final amount = await AccountPaymentDao.getTotalAmountByStatus(
        db,
        accountId,
        paymentStatus,
      );
      _logger.d(
        'Retrieved cached payments total amount with status $paymentStatus for account $accountId: $amount',
      );
      return amount;
    } catch (e) {
      _logger.e(
        'Error retrieving cached payments total amount with status $paymentStatus for account $accountId: $e',
      );
      rethrow;
    }
  }

  @override
  Future<double> getCachedPaymentsTotalRefundedAmount(String accountId) async {
    try {
      final db = await _databaseService.database;
      final amount = await AccountPaymentDao.getTotalRefundedAmountByAccountId(
        db,
        accountId,
      );
      _logger.d(
        'Retrieved cached payments total refunded amount for account $accountId: $amount',
      );
      return amount;
    } catch (e) {
      _logger.e(
        'Error retrieving cached payments total refunded amount for account $accountId: $e',
      );
      rethrow;
    }
  }

  @override
  Future<bool> hasCachedPayments(String accountId) async {
    try {
      final count = await getCachedPaymentsCount(accountId);
      final hasPayments = count > 0;
      _logger.d('Account $accountId has cached payments: $hasPayments');
      return hasPayments;
    } catch (e) {
      _logger.e('Error checking if account $accountId has cached payments: $e');
      rethrow;
    }
  }
}
