import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';

import '../../../../../core/services/database_service.dart';
import '../../models/payment_model.dart';
import '../../models/payment_transaction_model.dart';

abstract class PaymentsLocalDataSource {
  Future<void> cachePayments(List<PaymentModel> payments);
  Future<List<PaymentModel>> getCachedPayments();
  Future<void> cachePayment(PaymentModel payment);
  Future<PaymentModel?> getCachedPaymentById(String paymentId);
  Future<List<PaymentModel>> getCachedPaymentsByAccountId(String accountId);
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
      _logger.d('Caching ${payments.length} payments to local storage');

      // Clear existing payments first
      await clearCachedPayments();

      // Insert new payments
      for (final payment in payments) {
        await _cachePayment(payment);
      }

      _logger.d('Successfully cached ${payments.length} payments');
    } catch (e) {
      _logger.e('Error caching payments: $e');
      rethrow;
    }
  }

  @override
  Future<List<PaymentModel>> getCachedPayments() async {
    try {
      _logger.d('Retrieving cached payments from local storage');

      final db = await _databaseService.database;
      final List<Map<String, dynamic>> paymentsData = await db.query(
        'payments',
        orderBy: 'created_at DESC',
      );

      final List<PaymentModel> payments = [];
      for (final paymentData in paymentsData) {
        final paymentId = paymentData['payment_id'] as String;

        // Get payment transactions
        final List<Map<String, dynamic>> transactionsData = await db.query(
          'payment_transactions',
          where: 'payment_id = ?',
          whereArgs: [paymentId],
        );

        final transactions = transactionsData
            .map(
              (transactionData) => PaymentTransactionModel.fromJson({
                'transactionId': transactionData['transaction_id'] as String,
                'transactionExternalKey':
                    transactionData['transaction_external_key'] as String,
                'paymentId': transactionData['payment_id'] as String,
                'paymentExternalKey':
                    transactionData['payment_external_key'] as String,
                'transactionType':
                    transactionData['transaction_type'] as String,
                'amount': (transactionData['amount'] as num).toDouble(),
                'currency': transactionData['currency'] as String,
                'effectiveDate': transactionData['effective_date'] as String,
                'processedAmount': (transactionData['processed_amount'] as num)
                    .toDouble(),
                'processedCurrency':
                    transactionData['processed_currency'] as String,
                'status': transactionData['status'] as String,
                'gatewayErrorCode':
                    transactionData['gateway_error_code'] as String?,
                'gatewayErrorMsg':
                    transactionData['gateway_error_msg'] as String?,
                'firstPaymentReferenceId':
                    transactionData['first_payment_reference_id'] as String?,
                'secondPaymentReferenceId':
                    transactionData['second_payment_reference_id'] as String?,
                'properties': transactionData['properties'] != null
                    ? Map<String, dynamic>.from(
                        transactionData['properties'] as Map,
                      )
                    : null,
                'auditLogs': transactionData['audit_logs'] != null
                    ? List<Map<String, dynamic>>.from(
                        transactionData['audit_logs'] as List,
                      )
                    : [],
              }),
            )
            .toList();

        final paymentModel = PaymentModel.fromJson({
          'accountId': paymentData['account_id'] as String,
          'paymentId': paymentData['payment_id'] as String,
          'paymentNumber': paymentData['payment_number'] as String,
          'paymentExternalKey': paymentData['payment_external_key'] as String,
          'authAmount': (paymentData['auth_amount'] as num).toDouble(),
          'capturedAmount': (paymentData['captured_amount'] as num).toDouble(),
          'purchasedAmount': (paymentData['purchased_amount'] as num)
              .toDouble(),
          'refundedAmount': (paymentData['refunded_amount'] as num).toDouble(),
          'creditedAmount': (paymentData['credited_amount'] as num).toDouble(),
          'currency': paymentData['currency'] as String,
          'paymentMethodId': paymentData['payment_method_id'] as String,
          'transactions': transactions,
          'paymentAttempts': paymentData['payment_attempts'] != null
              ? List<Map<String, dynamic>>.from(
                  paymentData['payment_attempts'] as List,
                )
              : null,
          'auditLogs': paymentData['audit_logs'] != null
              ? List<Map<String, dynamic>>.from(
                  paymentData['audit_logs'] as List,
                )
              : [],
        });

        payments.add(paymentModel);
      }

      _logger.d('Retrieved ${payments.length} cached payments');
      return payments;
    } catch (e) {
      _logger.e('Error retrieving cached payments: $e');
      rethrow;
    }
  }

  @override
  Future<void> cachePayment(PaymentModel payment) async {
    try {
      _logger.d('Caching payment: ${payment.paymentId}');
      await _cachePayment(payment);
      _logger.d('Successfully cached payment: ${payment.paymentId}');
    } catch (e) {
      _logger.e('Error caching payment ${payment.paymentId}: $e');
      rethrow;
    }
  }

  @override
  Future<PaymentModel?> getCachedPaymentById(String paymentId) async {
    try {
      _logger.d('Retrieving cached payment by ID: $paymentId');

      final db = await _databaseService.database;
      final List<Map<String, dynamic>> paymentsData = await db.query(
        'payments',
        where: 'payment_id = ?',
        whereArgs: [paymentId],
        limit: 1,
      );

      if (paymentsData.isEmpty) {
        _logger.d('No cached payment found for ID: $paymentId');
        return null;
      }

      final paymentData = paymentsData.first;

      // Get payment transactions
      final List<Map<String, dynamic>> transactionsData = await db.query(
        'payment_transactions',
        where: 'payment_id = ?',
        whereArgs: [paymentId],
      );

      final transactions = transactionsData
          .map(
            (transactionData) => PaymentTransactionModel(
              transactionId: transactionData['transaction_id'] as String,
              transactionExternalKey:
                  transactionData['transaction_external_key'] as String,
              paymentId: transactionData['payment_id'] as String,
              paymentExternalKey:
                  transactionData['payment_external_key'] as String,
              transactionType: transactionData['transaction_type'] as String,
              amount: (transactionData['amount'] as num).toDouble(),
              currency: transactionData['currency'] as String,
              effectiveDate: DateTime.parse(
                transactionData['effective_date'] as String,
              ),
              processedAmount: (transactionData['processed_amount'] as num)
                  .toDouble(),
              processedCurrency:
                  transactionData['processed_currency'] as String,
              status: transactionData['status'] as String,
              gatewayErrorCode:
                  transactionData['gateway_error_code'] as String?,
              gatewayErrorMsg: transactionData['gateway_error_msg'] as String?,
              firstPaymentReferenceId:
                  transactionData['first_payment_reference_id'] as String?,
              secondPaymentReferenceId:
                  transactionData['second_payment_reference_id'] as String?,
              properties: transactionData['properties'] != null
                  ? Map<String, dynamic>.from(
                      transactionData['properties'] as Map,
                    )
                  : null,
              auditLogs: transactionData['audit_logs'] != null
                  ? List<Map<String, dynamic>>.from(
                      transactionData['audit_logs'] as List,
                    )
                  : [],
            ),
          )
          .toList();

      final paymentModel = PaymentModel(
        accountId: paymentData['account_id'] as String,
        paymentId: paymentData['payment_id'] as String,
        paymentNumber: paymentData['payment_number'] as String,
        paymentExternalKey: paymentData['payment_external_key'] as String,
        authAmount: (paymentData['auth_amount'] as num).toDouble(),
        capturedAmount: (paymentData['captured_amount'] as num).toDouble(),
        purchasedAmount: (paymentData['purchased_amount'] as num).toDouble(),
        refundedAmount: (paymentData['refunded_amount'] as num).toDouble(),
        creditedAmount: (paymentData['credited_amount'] as num).toDouble(),
        currency: paymentData['currency'] as String,
        paymentMethodId: paymentData['payment_method_id'] as String,
        transactions: transactions,
        paymentAttempts: paymentData['payment_attempts'] != null
            ? List<Map<String, dynamic>>.from(
                paymentData['payment_attempts'] as List,
              )
            : null,
        auditLogs: paymentData['audit_logs'] != null
            ? List<Map<String, dynamic>>.from(paymentData['audit_logs'] as List)
            : [],
      );

      _logger.d('Retrieved cached payment: ${paymentModel.paymentId}');
      return paymentModel;
    } catch (e) {
      _logger.e('Error retrieving cached payment $paymentId: $e');
      rethrow;
    }
  }

  @override
  Future<List<PaymentModel>> getCachedPaymentsByAccountId(
    String accountId,
  ) async {
    try {
      _logger.d('Retrieving cached payments by account ID: $accountId');

      final db = await _databaseService.database;
      final List<Map<String, dynamic>> paymentsData = await db.query(
        'payments',
        where: 'account_id = ?',
        whereArgs: [accountId],
        orderBy: 'created_at DESC',
      );

      final List<PaymentModel> payments = [];
      for (final paymentData in paymentsData) {
        final paymentId = paymentData['payment_id'] as String;

        // Get payment transactions
        final List<Map<String, dynamic>> transactionsData = await db.query(
          'payment_transactions',
          where: 'payment_id = ?',
          whereArgs: [paymentId],
        );

        final transactions = transactionsData
            .map(
              (transactionData) => PaymentTransactionModel.fromJson({
                'transactionId': transactionData['transaction_id'] as String,
                'transactionExternalKey':
                    transactionData['transaction_external_key'] as String,
                'paymentId': transactionData['payment_id'] as String,
                'paymentExternalKey':
                    transactionData['payment_external_key'] as String,
                'transactionType':
                    transactionData['transaction_type'] as String,
                'amount': (transactionData['amount'] as num).toDouble(),
                'currency': transactionData['currency'] as String,
                'effectiveDate': transactionData['effective_date'] as String,
                'processedAmount': (transactionData['processed_amount'] as num)
                    .toDouble(),
                'processedCurrency':
                    transactionData['processed_currency'] as String,
                'status': transactionData['status'] as String,
                'gatewayErrorCode':
                    transactionData['gateway_error_code'] as String?,
                'gatewayErrorMsg':
                    transactionData['gateway_error_msg'] as String?,
                'firstPaymentReferenceId':
                    transactionData['first_payment_reference_id'] as String?,
                'secondPaymentReferenceId':
                    transactionData['second_payment_reference_id'] as String?,
                'properties': transactionData['properties'] != null
                    ? Map<String, dynamic>.from(
                        transactionData['properties'] as Map,
                      )
                    : null,
                'auditLogs': transactionData['audit_logs'] != null
                    ? List<Map<String, dynamic>>.from(
                        transactionData['audit_logs'] as List,
                      )
                    : [],
              }),
            )
            .toList();

        final paymentModel = PaymentModel.fromJson({
          'accountId': paymentData['account_id'] as String,
          'paymentId': paymentData['payment_id'] as String,
          'paymentNumber': paymentData['payment_number'] as String,
          'paymentExternalKey': paymentData['payment_external_key'] as String,
          'authAmount': (paymentData['auth_amount'] as num).toDouble(),
          'capturedAmount': (paymentData['captured_amount'] as num).toDouble(),
          'purchasedAmount': (paymentData['purchased_amount'] as num)
              .toDouble(),
          'refundedAmount': (paymentData['refunded_amount'] as num).toDouble(),
          'creditedAmount': (paymentData['credited_amount'] as num).toDouble(),
          'currency': paymentData['currency'] as String,
          'paymentMethodId': paymentData['payment_method_id'] as String,
          'transactions': transactions,
          'paymentAttempts': paymentData['payment_attempts'] != null
              ? List<Map<String, dynamic>>.from(
                  paymentData['payment_attempts'] as List,
                )
              : null,
          'auditLogs': paymentData['audit_logs'] != null
              ? List<Map<String, dynamic>>.from(
                  paymentData['audit_logs'] as List,
                )
              : [],
        });

        payments.add(paymentModel);
      }

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
  Future<void> clearCachedPayments() async {
    try {
      _logger.d('Clearing cached payments from local storage');

      final db = await _databaseService.database;
      await db.delete('payment_transactions');
      await db.delete('payments');

      _logger.d('Successfully cleared cached payments');
    } catch (e) {
      _logger.e('Error clearing cached payments: $e');
      rethrow;
    }
  }

  Future<void> _cachePayment(PaymentModel payment) async {
    final db = await _databaseService.database;

    // Insert or replace payment
    await db.insert('payments', {
      'account_id': payment.accountId,
      'payment_id': payment.paymentId,
      'payment_number': payment.paymentNumber,
      'payment_external_key': payment.paymentExternalKey,
      'auth_amount': payment.authAmount,
      'captured_amount': payment.capturedAmount,
      'purchased_amount': payment.purchasedAmount,
      'refunded_amount': payment.refundedAmount,
      'credited_amount': payment.creditedAmount,
      'currency': payment.currency,
      'payment_method_id': payment.paymentMethodId,
      'payment_attempts': payment.paymentAttempts?.toString(),
      'audit_logs': payment.auditLogs.toString(),
      'created_at': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);

    // Delete existing payment transactions first
    await db.delete(
      'payment_transactions',
      where: 'payment_id = ?',
      whereArgs: [payment.paymentId],
    );

    // Insert payment transactions
    for (final transaction in payment.transactions) {
      await db.insert('payment_transactions', {
        'transaction_id': transaction.transactionId,
        'transaction_external_key': transaction.transactionExternalKey,
        'payment_id': transaction.paymentId,
        'payment_external_key': transaction.paymentExternalKey,
        'transaction_type': transaction.transactionType,
        'amount': transaction.amount,
        'currency': transaction.currency,
        'effective_date': transaction.effectiveDate.toIso8601String(),
        'processed_amount': transaction.processedAmount,
        'processed_currency': transaction.processedCurrency,
        'status': transaction.status,
        'gateway_error_code': transaction.gatewayErrorCode,
        'gateway_error_msg': transaction.gatewayErrorMsg,
        'first_payment_reference_id': transaction.firstPaymentReferenceId,
        'second_payment_reference_id': transaction.secondPaymentReferenceId,
        'properties': transaction.properties?.toString(),
        'audit_logs': transaction.auditLogs.toString(),
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }
}
