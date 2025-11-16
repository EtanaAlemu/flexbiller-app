import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';

import '../../../../../core/services/database_service.dart';
import '../../../../../core/dao/payment_dao.dart';
import '../../models/payment_model.dart';

abstract class PaymentsLocalDataSource {
  Future<void> cachePayments(List<PaymentModel> payments);
  Future<List<PaymentModel>> getCachedPayments();
  Future<void> cachePayment(PaymentModel payment);
  Future<PaymentModel?> getCachedPaymentById(String paymentId);
  Future<List<PaymentModel>> getCachedPaymentsByAccountId(String accountId);
  Future<List<PaymentModel>> searchCachedPayments(String searchKey);
  Future<void> deleteCachedPayment(String paymentId);
  Future<void> clearCachedPayments();
}

@LazySingleton(as: PaymentsLocalDataSource)
class PaymentsLocalDataSourceImpl implements PaymentsLocalDataSource {
  final DatabaseService _databaseService;
  final Logger _logger;

  PaymentsLocalDataSourceImpl(this._databaseService, this._logger);

  @override
  Future<void> cachePayments(List<PaymentModel> payments) async {
    try {
      _logger.d(
        'PaymentsLocalDataSource: Caching ${payments.length} payments to local storage',
      );

      final db = await _databaseService.database;

      // Use PaymentDao to insert payments
      for (final payment in payments) {
        await PaymentDao.insertOrUpdate(db, payment);
        _logger.d(
          'PaymentsLocalDataSource: Cached payment: ${payment.paymentId}',
        );
      }

      _logger.d(
        'PaymentsLocalDataSource: Successfully cached ${payments.length} payments',
      );
    } catch (e, stackTrace) {
      _logger.e('PaymentsLocalDataSource: Error caching payments: $e');
      _logger.e('PaymentsLocalDataSource: Stack trace: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<List<PaymentModel>> getCachedPayments() async {
    try {
      _logger.d(
        'PaymentsLocalDataSource: Retrieving cached payments from local storage',
      );

      final db = await _databaseService.database;
      final payments = await PaymentDao.getAll(db);

      _logger.d(
        'PaymentsLocalDataSource: Retrieved ${payments.length} cached payments',
      );
      return payments;
    } catch (e, stackTrace) {
      _logger.e(
        'PaymentsLocalDataSource: Error retrieving cached payments: $e',
      );
      _logger.e('PaymentsLocalDataSource: Stack trace: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<void> cachePayment(PaymentModel payment) async {
    try {
      _logger.d(
        'PaymentsLocalDataSource: Caching payment: ${payment.paymentId}',
      );

      final db = await _databaseService.database;
      await PaymentDao.insertOrUpdate(db, payment);

      _logger.d(
        'PaymentsLocalDataSource: Successfully cached payment: ${payment.paymentId}',
      );
    } catch (e, stackTrace) {
      _logger.e(
        'PaymentsLocalDataSource: Error caching payment ${payment.paymentId}: $e',
      );
      _logger.e('PaymentsLocalDataSource: Stack trace: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<PaymentModel?> getCachedPaymentById(String paymentId) async {
    try {
      _logger.d(
        'PaymentsLocalDataSource: Retrieving cached payment by ID: $paymentId',
      );

      final db = await _databaseService.database;
      final payment = await PaymentDao.getById(db, paymentId);

      if (payment != null) {
        _logger.d(
          'PaymentsLocalDataSource: Retrieved cached payment: ${payment.paymentId}',
        );
      } else {
        _logger.d(
          'PaymentsLocalDataSource: No cached payment found for ID: $paymentId',
        );
      }

      return payment;
    } catch (e, stackTrace) {
      _logger.e(
        'PaymentsLocalDataSource: Error retrieving cached payment $paymentId: $e',
      );
      _logger.e('PaymentsLocalDataSource: Stack trace: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<List<PaymentModel>> getCachedPaymentsByAccountId(
    String accountId,
  ) async {
    try {
      _logger.d(
        'PaymentsLocalDataSource: Retrieving cached payments by account ID: $accountId',
      );

      final db = await _databaseService.database;
      final payments = await PaymentDao.getByAccountId(db, accountId);

      _logger.d(
        'PaymentsLocalDataSource: Retrieved ${payments.length} cached payments for account: $accountId',
      );
      return payments;
    } catch (e, stackTrace) {
      _logger.e(
        'PaymentsLocalDataSource: Error retrieving cached payments for account $accountId: $e',
      );
      _logger.e('PaymentsLocalDataSource: Stack trace: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<List<PaymentModel>> searchCachedPayments(String searchKey) async {
    try {
      _logger.d(
        'PaymentsLocalDataSource: Searching cached payments with key: $searchKey',
      );

      final db = await _databaseService.database;
      final payments = await PaymentDao.search(db, searchKey);

      _logger.d(
        'PaymentsLocalDataSource: Found ${payments.length} cached payments matching "$searchKey"',
      );
      return payments;
    } catch (e, stackTrace) {
      _logger.e('PaymentsLocalDataSource: Error searching cached payments: $e');
      _logger.e('PaymentsLocalDataSource: Stack trace: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<void> deleteCachedPayment(String paymentId) async {
    try {
      _logger.d('PaymentsLocalDataSource: Deleting cached payment: $paymentId');

      final db = await _databaseService.database;
      await PaymentDao.deleteById(db, paymentId);

      _logger.d(
        'PaymentsLocalDataSource: Successfully deleted cached payment: $paymentId',
      );
    } catch (e, stackTrace) {
      _logger.e(
        'PaymentsLocalDataSource: Error deleting cached payment $paymentId: $e',
      );
      _logger.e('PaymentsLocalDataSource: Stack trace: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<void> clearCachedPayments() async {
    try {
      _logger.d(
        'PaymentsLocalDataSource: Clearing cached payments from local storage',
      );

      final db = await _databaseService.database;
      await PaymentDao.deleteAll(db);

      _logger.d(
        'PaymentsLocalDataSource: Successfully cleared cached payments',
      );
    } catch (e, stackTrace) {
      _logger.e('PaymentsLocalDataSource: Error clearing cached payments: $e');
      _logger.e('PaymentsLocalDataSource: Stack trace: $stackTrace');
      rethrow;
    }
  }
}
