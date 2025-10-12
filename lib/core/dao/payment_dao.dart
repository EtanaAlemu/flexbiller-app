import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:logger/logger.dart';
import '../../features/payments/data/models/payment_model.dart';
import '../../features/payments/data/models/payment_transaction_model.dart';

class PaymentDao {
  static const String tableName = 'payments';
  static const String transactionsTableName = 'payment_transactions';
  static final Logger _logger = Logger();

  // Column names constants for payments table
  static const String columnAccountId = 'account_id';
  static const String columnPaymentId = 'payment_id';
  static const String columnPaymentNumber = 'payment_number';
  static const String columnPaymentExternalKey = 'payment_external_key';
  static const String columnAuthAmount = 'auth_amount';
  static const String columnCapturedAmount = 'captured_amount';
  static const String columnPurchasedAmount = 'purchased_amount';
  static const String columnRefundedAmount = 'refunded_amount';
  static const String columnCreditedAmount = 'credited_amount';
  static const String columnCurrency = 'currency';
  static const String columnPaymentMethodId = 'payment_method_id';
  static const String columnPaymentAttempts = 'payment_attempts';
  static const String columnAuditLogs = 'audit_logs';
  static const String columnCreatedAt = 'created_at';

  // Column names constants for payment_transactions table
  static const String columnTransactionId = 'transaction_id';
  static const String columnTransactionExternalKey = 'transaction_external_key';
  static const String columnTransactionPaymentId = 'payment_id';
  static const String columnTransactionPaymentExternalKey = 'payment_external_key';
  static const String columnTransactionType = 'transaction_type';
  static const String columnAmount = 'amount';
  static const String columnTransactionCurrency = 'currency';
  static const String columnEffectiveDate = 'effective_date';
  static const String columnProcessedAmount = 'processed_amount';
  static const String columnProcessedCurrency = 'processed_currency';
  static const String columnStatus = 'status';
  static const String columnGatewayErrorCode = 'gateway_error_code';
  static const String columnGatewayErrorMsg = 'gateway_error_msg';
  static const String columnFirstPaymentReferenceId = 'first_payment_reference_id';
  static const String columnSecondPaymentReferenceId = 'second_payment_reference_id';
  static const String columnProperties = 'properties';
  static const String columnTransactionAuditLogs = 'audit_logs';

  static const String createTableSQL =
      '''
    CREATE TABLE $tableName (
      $columnAccountId TEXT NOT NULL,
      $columnPaymentId TEXT PRIMARY KEY,
      $columnPaymentNumber TEXT NOT NULL,
      $columnPaymentExternalKey TEXT NOT NULL,
      $columnAuthAmount REAL NOT NULL DEFAULT 0,
      $columnCapturedAmount REAL NOT NULL DEFAULT 0,
      $columnPurchasedAmount REAL NOT NULL DEFAULT 0,
      $columnRefundedAmount REAL NOT NULL DEFAULT 0,
      $columnCreditedAmount REAL NOT NULL DEFAULT 0,
      $columnCurrency TEXT NOT NULL,
      $columnPaymentMethodId TEXT NOT NULL,
      $columnPaymentAttempts TEXT,
      $columnAuditLogs TEXT,
      $columnCreatedAt TEXT NOT NULL
    )
  ''';

  static const String createTransactionsTableSQL =
      '''
    CREATE TABLE $transactionsTableName (
      $columnTransactionId TEXT PRIMARY KEY,
      $columnTransactionExternalKey TEXT NOT NULL,
      $columnTransactionPaymentId TEXT NOT NULL,
      $columnTransactionPaymentExternalKey TEXT NOT NULL,
      $columnTransactionType TEXT NOT NULL,
      $columnAmount REAL NOT NULL,
      $columnTransactionCurrency TEXT NOT NULL,
      $columnEffectiveDate TEXT NOT NULL,
      $columnProcessedAmount REAL NOT NULL,
      $columnProcessedCurrency TEXT NOT NULL,
      $columnStatus TEXT NOT NULL,
      $columnGatewayErrorCode TEXT,
      $columnGatewayErrorMsg TEXT,
      $columnFirstPaymentReferenceId TEXT,
      $columnSecondPaymentReferenceId TEXT,
      $columnProperties TEXT,
      $columnTransactionAuditLogs TEXT,
      FOREIGN KEY ($columnTransactionPaymentId) REFERENCES $tableName ($columnPaymentId) ON DELETE CASCADE
    )
  ''';

  /// Insert or update a payment
  static Future<void> insertOrUpdate(Database db, PaymentModel payment) async {
    try {
      // Insert/update payment
      final paymentData = {
        columnAccountId: payment.accountId,
        columnPaymentId: payment.paymentId,
        columnPaymentNumber: payment.paymentNumber,
        columnPaymentExternalKey: payment.paymentExternalKey,
        columnAuthAmount: payment.authAmount,
        columnCapturedAmount: payment.capturedAmount,
        columnPurchasedAmount: payment.purchasedAmount,
        columnRefundedAmount: payment.refundedAmount,
        columnCreditedAmount: payment.creditedAmount,
        columnCurrency: payment.currency,
        columnPaymentMethodId: payment.paymentMethodId,
        columnPaymentAttempts: payment.paymentAttempts?.toString(),
        columnAuditLogs: payment.auditLogs.toString(),
        columnCreatedAt: DateTime.now().toIso8601String(),
      };

      await db.insert(
        tableName,
        paymentData,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // Insert/update payment transactions
      for (final transaction in payment.transactions) {
        final transactionData = {
          columnTransactionId: transaction.transactionId,
          columnTransactionExternalKey: transaction.transactionExternalKey,
          columnTransactionPaymentId: payment.paymentId,
          columnTransactionPaymentExternalKey: payment.paymentExternalKey,
          columnTransactionType: transaction.transactionType,
          columnAmount: transaction.amount,
          columnTransactionCurrency: transaction.currency,
          columnEffectiveDate: transaction.effectiveDate.toIso8601String(),
          columnProcessedAmount: transaction.processedAmount,
          columnProcessedCurrency: transaction.processedCurrency,
          columnStatus: transaction.status,
          columnGatewayErrorCode: transaction.gatewayErrorCode,
          columnGatewayErrorMsg: transaction.gatewayErrorMsg,
          columnFirstPaymentReferenceId: transaction.firstPaymentReferenceId,
          columnSecondPaymentReferenceId: transaction.secondPaymentReferenceId,
          columnProperties: transaction.properties?.toString(),
          columnTransactionAuditLogs: transaction.auditLogs.toString(),
        };

        await db.insert(
          transactionsTableName,
          transactionData,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      _logger.d('Payment inserted/updated successfully: ${payment.paymentId}');
    } catch (e) {
      _logger.e('Error inserting payment: $e');
      rethrow;
    }
  }

  /// Update a payment
  static Future<void> update(
    Database db,
    String paymentId,
    Map<String, dynamic> paymentData,
  ) async {
    try {
      await db.update(
        tableName,
        paymentData,
        where: '$columnPaymentId = ?',
        whereArgs: [paymentId],
      );
      _logger.d('Payment updated successfully: $paymentId');
    } catch (e) {
      _logger.e('Error updating payment: $e');
      rethrow;
    }
  }

  /// Get payment by ID
  static Future<PaymentModel?> getById(Database db, String paymentId) async {
    try {
      final results = await db.query(
        tableName,
        where: '$columnPaymentId = ?',
        whereArgs: [paymentId],
      );

      if (results.isEmpty) {
        _logger.d('Payment not found: $paymentId');
        return null;
      }

      final paymentData = results.first;

      // Get payment transactions
      final transactionsResults = await db.query(
        transactionsTableName,
        where: '$columnTransactionPaymentId = ?',
        whereArgs: [paymentId],
      );

      final transactions = transactionsResults.map((transactionData) {
        return PaymentTransactionModel(
          transactionId: transactionData[columnTransactionId] as String,
          transactionExternalKey:
              transactionData[columnTransactionExternalKey] as String,
          paymentId: transactionData[columnTransactionPaymentId] as String,
          paymentExternalKey:
              transactionData[columnTransactionPaymentExternalKey] as String,
          transactionType: transactionData[columnTransactionType] as String,
          amount: transactionData[columnAmount] as double,
          currency: transactionData[columnTransactionCurrency] as String,
          effectiveDate: DateTime.parse(
            transactionData[columnEffectiveDate] as String,
          ),
          processedAmount: transactionData[columnProcessedAmount] as double,
          processedCurrency:
              transactionData[columnProcessedCurrency] as String,
          status: transactionData[columnStatus] as String,
          gatewayErrorCode: transactionData[columnGatewayErrorCode] as String?,
          gatewayErrorMsg: transactionData[columnGatewayErrorMsg] as String?,
          firstPaymentReferenceId:
              transactionData[columnFirstPaymentReferenceId] as String?,
          secondPaymentReferenceId:
              transactionData[columnSecondPaymentReferenceId] as String?,
          properties: transactionData[columnProperties] != null
              ? {} // Simplified - would need proper parsing
              : null,
          auditLogs: [], // Simplified - would need proper parsing
        );
      }).toList();

      final payment = PaymentModel(
        accountId: paymentData[columnAccountId] as String,
        paymentId: paymentData[columnPaymentId] as String,
        paymentNumber: paymentData[columnPaymentNumber] as String,
        paymentExternalKey: paymentData[columnPaymentExternalKey] as String,
        authAmount: paymentData[columnAuthAmount] as double,
        capturedAmount: paymentData[columnCapturedAmount] as double,
        purchasedAmount: paymentData[columnPurchasedAmount] as double,
        refundedAmount: paymentData[columnRefundedAmount] as double,
        creditedAmount: paymentData[columnCreditedAmount] as double,
        currency: paymentData[columnCurrency] as String,
        paymentMethodId: paymentData[columnPaymentMethodId] as String,
        transactions: transactions,
        paymentAttempts: paymentData[columnPaymentAttempts] != null
            ? [] // Simplified - would need proper parsing
            : null,
        auditLogs: [], // Simplified - would need proper parsing
      );

      _logger.d('Payment retrieved successfully: $paymentId');
      return payment;
    } catch (e) {
      _logger.e('Error retrieving payment: $e');
      rethrow;
    }
  }

  /// Get all payments
  static Future<List<PaymentModel>> getAll(Database db) async {
    try {
      final results = await db.query(
        tableName,
        orderBy: '$columnCreatedAt DESC',
      );
      final payments = <PaymentModel>[];

      for (final paymentData in results) {
        final paymentId = paymentData[columnPaymentId] as String;

        // Get payment transactions for each payment
        final transactionsResults = await db.query(
          transactionsTableName,
          where: '$columnTransactionPaymentId = ?',
          whereArgs: [paymentId],
        );

        final transactions = transactionsResults.map((transactionData) {
          return PaymentTransactionModel(
            transactionId: transactionData[columnTransactionId] as String,
            transactionExternalKey:
                transactionData[columnTransactionExternalKey] as String,
            paymentId: transactionData[columnTransactionPaymentId] as String,
            paymentExternalKey:
                transactionData[columnTransactionPaymentExternalKey] as String,
            transactionType: transactionData[columnTransactionType] as String,
            amount: transactionData[columnAmount] as double,
            currency: transactionData[columnTransactionCurrency] as String,
            effectiveDate: DateTime.parse(
              transactionData[columnEffectiveDate] as String,
            ),
            processedAmount: transactionData[columnProcessedAmount] as double,
            processedCurrency:
                transactionData[columnProcessedCurrency] as String,
            status: transactionData[columnStatus] as String,
            gatewayErrorCode:
                transactionData[columnGatewayErrorCode] as String?,
            gatewayErrorMsg: transactionData[columnGatewayErrorMsg] as String?,
            firstPaymentReferenceId:
                transactionData[columnFirstPaymentReferenceId] as String?,
            secondPaymentReferenceId:
                transactionData[columnSecondPaymentReferenceId] as String?,
            properties: transactionData[columnProperties] != null
                ? {} // Simplified - would need proper parsing
                : null,
            auditLogs: [], // Simplified - would need proper parsing
          );
        }).toList();

        final payment = PaymentModel(
          accountId: paymentData[columnAccountId] as String,
          paymentId: paymentData[columnPaymentId] as String,
          paymentNumber: paymentData[columnPaymentNumber] as String,
          paymentExternalKey: paymentData[columnPaymentExternalKey] as String,
          authAmount: paymentData[columnAuthAmount] as double,
          capturedAmount: paymentData[columnCapturedAmount] as double,
          purchasedAmount: paymentData[columnPurchasedAmount] as double,
          refundedAmount: paymentData[columnRefundedAmount] as double,
          creditedAmount: paymentData[columnCreditedAmount] as double,
          currency: paymentData[columnCurrency] as String,
          paymentMethodId: paymentData[columnPaymentMethodId] as String,
          transactions: transactions,
          paymentAttempts: paymentData[columnPaymentAttempts] != null
              ? [] // Simplified - would need proper parsing
              : null,
          auditLogs: [], // Simplified - would need proper parsing
        );

        payments.add(payment);
      }

      _logger.d('Retrieved ${payments.length} payments');
      return payments;
    } catch (e) {
      _logger.e('Error retrieving all payments: $e');
      rethrow;
    }
  }

  /// Get payments by account ID
  static Future<List<PaymentModel>> getByAccountId(
    Database db,
    String accountId,
  ) async {
    try {
      final results = await db.query(
        tableName,
        where: '$columnAccountId = ?',
        whereArgs: [accountId],
        orderBy: '$columnCreatedAt DESC',
      );

      final payments = <PaymentModel>[];

      for (final paymentData in results) {
        final paymentId = paymentData[columnPaymentId] as String;

        // Get payment transactions for each payment
        final transactionsResults = await db.query(
          transactionsTableName,
          where: '$columnTransactionPaymentId = ?',
          whereArgs: [paymentId],
        );

        final transactions = transactionsResults.map((transactionData) {
          return PaymentTransactionModel(
            transactionId: transactionData[columnTransactionId] as String,
            transactionExternalKey:
                transactionData[columnTransactionExternalKey] as String,
            paymentId: transactionData[columnTransactionPaymentId] as String,
            paymentExternalKey:
                transactionData[columnTransactionPaymentExternalKey] as String,
            transactionType: transactionData[columnTransactionType] as String,
            amount: transactionData[columnAmount] as double,
            currency: transactionData[columnTransactionCurrency] as String,
            effectiveDate: DateTime.parse(
              transactionData[columnEffectiveDate] as String,
            ),
            processedAmount: transactionData[columnProcessedAmount] as double,
            processedCurrency:
                transactionData[columnProcessedCurrency] as String,
            status: transactionData[columnStatus] as String,
            gatewayErrorCode:
                transactionData[columnGatewayErrorCode] as String?,
            gatewayErrorMsg: transactionData[columnGatewayErrorMsg] as String?,
            firstPaymentReferenceId:
                transactionData[columnFirstPaymentReferenceId] as String?,
            secondPaymentReferenceId:
                transactionData[columnSecondPaymentReferenceId] as String?,
            properties: transactionData[columnProperties] != null
                ? {} // Simplified - would need proper parsing
                : null,
            auditLogs: [], // Simplified - would need proper parsing
          );
        }).toList();

        final payment = PaymentModel(
          accountId: paymentData[columnAccountId] as String,
          paymentId: paymentData[columnPaymentId] as String,
          paymentNumber: paymentData[columnPaymentNumber] as String,
          paymentExternalKey: paymentData[columnPaymentExternalKey] as String,
          authAmount: paymentData[columnAuthAmount] as double,
          capturedAmount: paymentData[columnCapturedAmount] as double,
          purchasedAmount: paymentData[columnPurchasedAmount] as double,
          refundedAmount: paymentData[columnRefundedAmount] as double,
          creditedAmount: paymentData[columnCreditedAmount] as double,
          currency: paymentData[columnCurrency] as String,
          paymentMethodId: paymentData[columnPaymentMethodId] as String,
          transactions: transactions,
          paymentAttempts: paymentData[columnPaymentAttempts] != null
              ? [] // Simplified - would need proper parsing
              : null,
          auditLogs: [], // Simplified - would need proper parsing
        );

        payments.add(payment);
      }

      _logger.d(
        'Retrieved ${payments.length} payments for account: $accountId',
      );
      return payments;
    } catch (e) {
      _logger.e('Error retrieving payments by account ID: $e');
      rethrow;
    }
  }

  /// Search payments by payment number or external key
  static Future<List<PaymentModel>> search(Database db, String searchQuery) async {
    try {
      final results = await db.query(
        tableName,
        where: '$columnPaymentNumber LIKE ? OR $columnPaymentExternalKey LIKE ?',
        whereArgs: ['%$searchQuery%', '%$searchQuery%'],
        orderBy: '$columnCreatedAt DESC',
      );

      final payments = <PaymentModel>[];

      for (final paymentData in results) {
        final paymentId = paymentData[columnPaymentId] as String;

        // Get payment transactions for each payment
        final transactionsResults = await db.query(
          transactionsTableName,
          where: '$columnTransactionPaymentId = ?',
          whereArgs: [paymentId],
        );

        final transactions = transactionsResults.map((transactionData) {
          return PaymentTransactionModel(
            transactionId: transactionData[columnTransactionId] as String,
            transactionExternalKey:
                transactionData[columnTransactionExternalKey] as String,
            paymentId: transactionData[columnTransactionPaymentId] as String,
            paymentExternalKey:
                transactionData[columnTransactionPaymentExternalKey] as String,
            transactionType: transactionData[columnTransactionType] as String,
            amount: transactionData[columnAmount] as double,
            currency: transactionData[columnTransactionCurrency] as String,
            effectiveDate: DateTime.parse(
              transactionData[columnEffectiveDate] as String,
            ),
            processedAmount: transactionData[columnProcessedAmount] as double,
            processedCurrency:
                transactionData[columnProcessedCurrency] as String,
            status: transactionData[columnStatus] as String,
            gatewayErrorCode:
                transactionData[columnGatewayErrorCode] as String?,
            gatewayErrorMsg: transactionData[columnGatewayErrorMsg] as String?,
            firstPaymentReferenceId:
                transactionData[columnFirstPaymentReferenceId] as String?,
            secondPaymentReferenceId:
                transactionData[columnSecondPaymentReferenceId] as String?,
            properties: transactionData[columnProperties] != null
                ? {} // Simplified - would need proper parsing
                : null,
            auditLogs: [], // Simplified - would need proper parsing
          );
        }).toList();

        final payment = PaymentModel(
          accountId: paymentData[columnAccountId] as String,
          paymentId: paymentData[columnPaymentId] as String,
          paymentNumber: paymentData[columnPaymentNumber] as String,
          paymentExternalKey: paymentData[columnPaymentExternalKey] as String,
          authAmount: paymentData[columnAuthAmount] as double,
          capturedAmount: paymentData[columnCapturedAmount] as double,
          purchasedAmount: paymentData[columnPurchasedAmount] as double,
          refundedAmount: paymentData[columnRefundedAmount] as double,
          creditedAmount: paymentData[columnCreditedAmount] as double,
          currency: paymentData[columnCurrency] as String,
          paymentMethodId: paymentData[columnPaymentMethodId] as String,
          transactions: transactions,
          paymentAttempts: paymentData[columnPaymentAttempts] != null
              ? [] // Simplified - would need proper parsing
              : null,
          auditLogs: [], // Simplified - would need proper parsing
        );

        payments.add(payment);
      }

      _logger.d(
        'Found ${payments.length} payments matching "$searchQuery"',
      );
      return payments;
    } catch (e) {
      _logger.e('Error searching payments: $e');
      rethrow;
    }
  }

  /// Get payments by currency
  static Future<List<PaymentModel>> getByCurrency(
    Database db,
    String currency,
  ) async {
    try {
      final results = await db.query(
        tableName,
        where: '$columnCurrency = ?',
        whereArgs: [currency],
        orderBy: '$columnCreatedAt DESC',
      );

      final payments = <PaymentModel>[];

      for (final paymentData in results) {
        final paymentId = paymentData[columnPaymentId] as String;

        // Get payment transactions for each payment
        final transactionsResults = await db.query(
          transactionsTableName,
          where: '$columnTransactionPaymentId = ?',
          whereArgs: [paymentId],
        );

        final transactions = transactionsResults.map((transactionData) {
          return PaymentTransactionModel(
            transactionId: transactionData[columnTransactionId] as String,
            transactionExternalKey:
                transactionData[columnTransactionExternalKey] as String,
            paymentId: transactionData[columnTransactionPaymentId] as String,
            paymentExternalKey:
                transactionData[columnTransactionPaymentExternalKey] as String,
            transactionType: transactionData[columnTransactionType] as String,
            amount: transactionData[columnAmount] as double,
            currency: transactionData[columnTransactionCurrency] as String,
            effectiveDate: DateTime.parse(
              transactionData[columnEffectiveDate] as String,
            ),
            processedAmount: transactionData[columnProcessedAmount] as double,
            processedCurrency:
                transactionData[columnProcessedCurrency] as String,
            status: transactionData[columnStatus] as String,
            gatewayErrorCode:
                transactionData[columnGatewayErrorCode] as String?,
            gatewayErrorMsg: transactionData[columnGatewayErrorMsg] as String?,
            firstPaymentReferenceId:
                transactionData[columnFirstPaymentReferenceId] as String?,
            secondPaymentReferenceId:
                transactionData[columnSecondPaymentReferenceId] as String?,
            properties: transactionData[columnProperties] != null
                ? {} // Simplified - would need proper parsing
                : null,
            auditLogs: [], // Simplified - would need proper parsing
          );
        }).toList();

        final payment = PaymentModel(
          accountId: paymentData[columnAccountId] as String,
          paymentId: paymentData[columnPaymentId] as String,
          paymentNumber: paymentData[columnPaymentNumber] as String,
          paymentExternalKey: paymentData[columnPaymentExternalKey] as String,
          authAmount: paymentData[columnAuthAmount] as double,
          capturedAmount: paymentData[columnCapturedAmount] as double,
          purchasedAmount: paymentData[columnPurchasedAmount] as double,
          refundedAmount: paymentData[columnRefundedAmount] as double,
          creditedAmount: paymentData[columnCreditedAmount] as double,
          currency: paymentData[columnCurrency] as String,
          paymentMethodId: paymentData[columnPaymentMethodId] as String,
          transactions: transactions,
          paymentAttempts: paymentData[columnPaymentAttempts] != null
              ? [] // Simplified - would need proper parsing
              : null,
          auditLogs: [], // Simplified - would need proper parsing
        );

        payments.add(payment);
      }

      _logger.d('Retrieved ${payments.length} payments for currency: $currency');
      return payments;
    } catch (e) {
      _logger.e('Error retrieving payments by currency: $e');
      rethrow;
    }
  }

  /// Delete payment by ID
  static Future<void> deleteById(Database db, String paymentId) async {
    try {
      // Delete payment transactions first (due to foreign key constraint)
      await db.delete(
        transactionsTableName,
        where: '$columnTransactionPaymentId = ?',
        whereArgs: [paymentId],
      );

      // Delete payment
      await db.delete(tableName, where: '$columnPaymentId = ?', whereArgs: [paymentId]);

      _logger.d('Payment deleted successfully: $paymentId');
    } catch (e) {
      _logger.e('Error deleting payment: $e');
      rethrow;
    }
  }

  /// Delete all payments
  static Future<void> deleteAll(Database db) async {
    try {
      // Delete all payment transactions first
      await db.delete(transactionsTableName);

      // Delete all payments
      await db.delete(tableName);

      _logger.d('All payments deleted successfully');
    } catch (e) {
      _logger.e('Error deleting all payments: $e');
      rethrow;
    }
  }

  /// Get payment count
  static Future<int> getCount(Database db) async {
    try {
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM $tableName',
      );
      final count = result.first['count'] as int;
      _logger.d('Payment count: $count');
      return count;
    } catch (e) {
      _logger.e('Error getting payment count: $e');
      rethrow;
    }
  }

  /// Check if payment exists
  static Future<bool> exists(Database db, String paymentId) async {
    try {
      final result = await db.rawQuery(
        'SELECT 1 FROM $tableName WHERE $columnPaymentId = ?',
        [paymentId],
      );
      return result.isNotEmpty;
    } catch (e) {
      _logger.e('Error checking if payment exists: $e');
      rethrow;
    }
  }

  /// Get total amount by currency
  static Future<Map<String, double>> getTotalAmountsByCurrency(
    Database db,
  ) async {
    try {
      final result = await db.rawQuery(
        'SELECT $columnCurrency, SUM($columnCapturedAmount) as total FROM $tableName GROUP BY $columnCurrency',
      );

      final totals = <String, double>{};
      for (final row in result) {
        final currency = row[columnCurrency] as String;
        final total = row['total'] as double? ?? 0.0;
        totals[currency] = total;
      }

      _logger.d('Retrieved total amounts by currency: $totals');
      return totals;
    } catch (e) {
      _logger.e('Error getting total amounts by currency: $e');
      rethrow;
    }
  }
}