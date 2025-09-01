import 'dart:async';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import '../../../../../core/network/network_info.dart';
import '../../domain/entities/account_invoice_payment.dart';
import '../../domain/repositories/account_invoice_payments_repository.dart';
import '../datasources/local/account_invoice_payments_local_data_source.dart';
import '../datasources/remote/account_invoice_payments_remote_data_source.dart';
import '../models/account_invoice_payment_model.dart';

@Injectable(as: AccountInvoicePaymentsRepository)
class AccountInvoicePaymentsRepositoryImpl
    implements AccountInvoicePaymentsRepository {
  final AccountInvoicePaymentsRemoteDataSource _remoteDataSource;
  final AccountInvoicePaymentsLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;
  final Logger _logger;

  // Stream controllers for reactive UI updates
  final StreamController<List<AccountInvoicePayment>>
  _accountInvoicePaymentsController =
      StreamController<List<AccountInvoicePayment>>.broadcast();

  AccountInvoicePaymentsRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
    this._networkInfo,
    this._logger,
  );

  @override
  Stream<List<AccountInvoicePayment>> get accountInvoicePaymentsStream =>
      _accountInvoicePaymentsController.stream;

  @override
  Future<List<AccountInvoicePayment>> getAccountInvoicePayments(
    String accountId,
  ) async {
    try {
      // First, get data from local cache (immediate response)
      final cachedPayments = await _localDataSource
          .getCachedAccountInvoicePayments(accountId);

      // Emit cached data immediately for UI responsiveness
      if (cachedPayments.isNotEmpty) {
        final entities = cachedPayments
            .map((model) => model.toEntity())
            .toList();
        _accountInvoicePaymentsController.add(entities);
        _logger.d(
          'Emitted ${entities.length} cached invoice payments for account: $accountId',
        );
      }

      // Check if device is online for background synchronization
      if (await _networkInfo.isConnected) {
        try {
          // Fetch fresh data from remote source
          final remotePayments = await _remoteDataSource
              .getAccountInvoicePayments(accountId);

          // Cache the fresh data locally
          await _localDataSource.cacheAccountInvoicePayments(
            accountId,
            remotePayments,
          );
          _logger.d(
            'Cached ${remotePayments.length} fresh invoice payments for account: $accountId',
          );

          // Emit updated data for UI refresh
          final updatedEntities = remotePayments
              .map((model) => model.toEntity())
              .toList();
          _accountInvoicePaymentsController.add(updatedEntities);
          _logger.d(
            'Emitted ${updatedEntities.length} fresh invoice payments for account: $accountId',
          );

          return updatedEntities;
        } catch (e) {
          _logger.w('Remote fetch failed for account $accountId: $e');
          // Return cached data if remote fetch fails
          if (cachedPayments.isNotEmpty) {
            return cachedPayments.map((model) => model.toEntity()).toList();
          }
          rethrow;
        }
      } else {
        _logger.d(
          'Device offline, returning cached invoice payments for account: $accountId',
        );
        // Return cached data if offline
        if (cachedPayments.isNotEmpty) {
          return cachedPayments.map((model) => model.toEntity()).toList();
        }
        // Return empty list if no cached data
        return [];
      }
    } catch (e) {
      _logger.e(
        'Error getting account invoice payments for account $accountId: $e',
      );
      rethrow;
    }
  }

  @override
  Future<AccountInvoicePayment> getAccountInvoicePayment(
    String accountId,
    String paymentId,
  ) async {
    try {
      // First, try to get from local cache
      final cachedPayment = await _localDataSource
          .getCachedAccountInvoicePayment(paymentId);
      if (cachedPayment != null) {
        _logger.d(
          'Retrieved cached invoice payment: $paymentId for account: $accountId',
        );
        return cachedPayment.toEntity();
      }

      // If not in cache and online, fetch from remote
      if (await _networkInfo.isConnected) {
        try {
          final remotePayment = await _remoteDataSource
              .getAccountInvoicePayment(accountId, paymentId);

          // Cache the payment locally
          await _localDataSource.cacheAccountInvoicePayment(remotePayment);
          _logger.d(
            'Cached invoice payment: $paymentId for account: $accountId',
          );

          return remotePayment.toEntity();
        } catch (e) {
          _logger.w('Remote fetch failed for invoice payment $paymentId: $e');
          rethrow;
        }
      } else {
        _logger.d('Device offline and invoice payment not cached: $paymentId');
        throw Exception(
          'Invoice payment not found in cache and device is offline',
        );
      }
    } catch (e) {
      _logger.e(
        'Error getting account invoice payment $paymentId for account $accountId: $e',
      );
      rethrow;
    }
  }

  @override
  Future<List<AccountInvoicePayment>> getInvoicePaymentsByStatus(
    String accountId,
    String status,
  ) async {
    try {
      // First, get from local cache
      final cachedPayments = await _localDataSource
          .getCachedInvoicePaymentsByStatus(accountId, status);

      if (cachedPayments.isNotEmpty) {
        _logger.d(
          'Found ${cachedPayments.length} cached invoice payments with status $status for account: $accountId',
        );
        return cachedPayments.map((model) => model.toEntity()).toList();
      }

      // If no cached results and online, fetch from remote
      if (await _networkInfo.isConnected) {
        try {
          final remotePayments = await _remoteDataSource
              .getInvoicePaymentsByStatus(accountId, status);

          // Cache the results locally
          await _localDataSource.cacheAccountInvoicePayments(
            accountId,
            remotePayments,
          );
          _logger.d(
            'Cached ${remotePayments.length} invoice payments with status $status for account: $accountId',
          );

          return remotePayments.map((model) => model.toEntity()).toList();
        } catch (e) {
          _logger.w(
            'Remote fetch failed for status $status, account $accountId: $e',
          );
          rethrow;
        }
      } else {
        _logger.d(
          'Device offline, no cached results for status $status, account $accountId',
        );
        return [];
      }
    } catch (e) {
      _logger.e(
        'Error getting invoice payments by status $status for account $accountId: $e',
      );
      rethrow;
    }
  }

  @override
  Future<List<AccountInvoicePayment>> getInvoicePaymentsByDateRange(
    String accountId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      // First, get from local cache
      final cachedPayments = await _localDataSource
          .getCachedInvoicePaymentsByDateRange(accountId, startDate, endDate);

      if (cachedPayments.isNotEmpty) {
        _logger.d(
          'Found ${cachedPayments.length} cached invoice payments in date range for account: $accountId',
        );
        return cachedPayments.map((model) => model.toEntity()).toList();
      }

      // If no cached results and online, fetch from remote
      if (await _networkInfo.isConnected) {
        try {
          final remotePayments = await _remoteDataSource
              .getInvoicePaymentsByDateRange(accountId, startDate, endDate);

          // Cache the results locally
          await _localDataSource.cacheAccountInvoicePayments(
            accountId,
            remotePayments,
          );
          _logger.d(
            'Cached ${remotePayments.length} invoice payments in date range for account: $accountId',
          );

          return remotePayments.map((model) => model.toEntity()).toList();
        } catch (e) {
          _logger.w(
            'Remote fetch failed for date range, account $accountId: $e',
          );
          rethrow;
        }
      } else {
        _logger.d(
          'Device offline, no cached results for date range, account $accountId',
        );
        return [];
      }
    } catch (e) {
      _logger.e(
        'Error getting invoice payments by date range for account $accountId: $e',
      );
      rethrow;
    }
  }

  @override
  Future<List<AccountInvoicePayment>> getInvoicePaymentsByMethod(
    String accountId,
    String paymentMethod,
  ) async {
    try {
      // First, get from local cache
      final cachedPayments = await _localDataSource
          .getCachedInvoicePaymentsByMethod(accountId, paymentMethod);

      if (cachedPayments.isNotEmpty) {
        _logger.d(
          'Found ${cachedPayments.length} cached invoice payments with method $paymentMethod for account: $accountId',
        );
        return cachedPayments.map((model) => model.toEntity()).toList();
      }

      // If no cached results and online, fetch from remote
      if (await _networkInfo.isConnected) {
        try {
          final remotePayments = await _remoteDataSource
              .getInvoicePaymentsByMethod(accountId, paymentMethod);

          // Cache the results locally
          await _localDataSource.cacheAccountInvoicePayments(
            accountId,
            remotePayments,
          );
          _logger.d(
            'Cached ${remotePayments.length} invoice payments with method $paymentMethod for account: $accountId',
          );

          return remotePayments.map((model) => model.toEntity()).toList();
        } catch (e) {
          _logger.w(
            'Remote fetch failed for method $paymentMethod, account $accountId: $e',
          );
          rethrow;
        }
      } else {
        _logger.d(
          'Device offline, no cached results for method $paymentMethod, account $accountId',
        );
        return [];
      }
    } catch (e) {
      _logger.e(
        'Error getting invoice payments by method $paymentMethod for account $accountId: $e',
      );
      rethrow;
    }
  }

  @override
  Future<List<AccountInvoicePayment>> getInvoicePaymentsByInvoiceNumber(
    String accountId,
    String invoiceNumber,
  ) async {
    try {
      // First, get from local cache
      final cachedPayments = await _localDataSource
          .getCachedInvoicePaymentsByInvoiceNumber(accountId, invoiceNumber);

      if (cachedPayments.isNotEmpty) {
        _logger.d(
          'Found ${cachedPayments.length} cached invoice payments for invoice $invoiceNumber, account: $accountId',
        );
        return cachedPayments.map((model) => model.toEntity()).toList();
      }

      // If no cached results and online, fetch from remote
      if (await _networkInfo.isConnected) {
        try {
          final remotePayments = await _remoteDataSource
              .getInvoicePaymentsByInvoiceNumber(accountId, invoiceNumber);

          // Cache the results locally
          await _localDataSource.cacheAccountInvoicePayments(
            accountId,
            remotePayments,
          );
          _logger.d(
            'Cached ${remotePayments.length} invoice payments for invoice $invoiceNumber, account: $accountId',
          );

          return remotePayments.map((model) => model.toEntity()).toList();
        } catch (e) {
          _logger.w(
            'Remote fetch failed for invoice $invoiceNumber, account $accountId: $e',
          );
          rethrow;
        }
      } else {
        _logger.d(
          'Device offline, no cached results for invoice $invoiceNumber, account $accountId',
        );
        return [];
      }
    } catch (e) {
      _logger.e(
        'Error getting invoice payments by invoice number $invoiceNumber for account $accountId: $e',
      );
      rethrow;
    }
  }

  @override
  Future<List<AccountInvoicePayment>> getInvoicePaymentsWithPagination(
    String accountId,
    int page,
    int pageSize,
  ) async {
    try {
      // First, get from local cache
      final cachedPayments = await _localDataSource
          .getCachedInvoicePaymentsWithPagination(accountId, page, pageSize);

      if (cachedPayments.isNotEmpty) {
        _logger.d(
          'Found ${cachedPayments.length} cached invoice payments (page $page, size $pageSize) for account: $accountId',
        );
        return cachedPayments.map((model) => model.toEntity()).toList();
      }

      // If no cached results and online, fetch from remote
      if (await _networkInfo.isConnected) {
        try {
          final remotePayments = await _remoteDataSource
              .getInvoicePaymentsWithPagination(accountId, page, pageSize);

          // Cache the results locally
          await _localDataSource.cacheAccountInvoicePayments(
            accountId,
            remotePayments,
          );
          _logger.d(
            'Cached ${remotePayments.length} invoice payments (page $page, size $pageSize) for account: $accountId',
          );

          return remotePayments.map((model) => model.toEntity()).toList();
        } catch (e) {
          _logger.w(
            'Remote fetch failed for pagination (page $page, size $pageSize), account $accountId: $e',
          );
          rethrow;
        }
      } else {
        _logger.d(
          'Device offline, no cached results for pagination (page $page, size $pageSize), account $accountId',
        );
        return [];
      }
    } catch (e) {
      _logger.e(
        'Error getting invoice payments with pagination (page $page, size $pageSize) for account $accountId: $e',
      );
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getInvoicePaymentStatistics(
    String accountId,
  ) async {
    try {
      // For statistics, we'll try to get from local cache first if available
      // Since statistics are typically computed data, we'll prioritize remote data
      if (await _networkInfo.isConnected) {
        try {
          final remoteStats = await _remoteDataSource
              .getInvoicePaymentStatistics(accountId);
          _logger.d(
            'Retrieved invoice payment statistics from remote for account: $accountId',
          );
          return remoteStats;
        } catch (e) {
          _logger.w(
            'Remote statistics fetch failed for account $accountId: $e',
          );
          rethrow;
        }
      } else {
        _logger.d(
          'Device offline, cannot fetch invoice payment statistics for account: $accountId',
        );
        throw Exception('Cannot fetch statistics while offline');
      }
    } catch (e) {
      _logger.e(
        'Error getting invoice payment statistics for account $accountId: $e',
      );
      rethrow;
    }
  }

  @override
  Future<AccountInvoicePayment> createInvoicePayment(
    String accountId,
    double paymentAmount,
    String currency,
    String paymentMethod,
    String? notes,
  ) async {
    try {
      // Create payment model with local data
      final paymentModel = AccountInvoicePaymentModel(
        id: '', // Will be assigned by server
        accountId: accountId,
        invoiceId: '', // Will be assigned by server
        invoiceNumber: '', // Will be assigned by server
        amount: paymentAmount,
        currency: currency,
        paymentMethod: paymentMethod,
        status: 'PENDING', // New payments start as pending
        paymentDate: DateTime.now(),
        processedDate: null,
        transactionId: null,
        notes: notes,
        metadata: null,
      );

      // Save to local cache first for immediate UI response
      await _localDataSource.cacheAccountInvoicePayment(paymentModel);
      _logger.d('Cached new invoice payment locally for account: $accountId');

      // Emit updated list for UI refresh
      final updatedPayments = await _localDataSource
          .getCachedAccountInvoicePayments(accountId);
      final entities = updatedPayments
          .map((model) => model.toEntity())
          .toList();
      _accountInvoicePaymentsController.add(entities);

      // If online, send to remote server
      if (await _networkInfo.isConnected) {
        try {
          final remotePayment = await _remoteDataSource.createInvoicePayment(
            accountId,
            paymentAmount,
            currency,
            paymentMethod,
            notes,
          );

          // Update local cache with server response
          await _localDataSource.updateCachedInvoicePayment(remotePayment);
          _logger.d(
            'Created invoice payment on remote server for account: $accountId',
          );

          // Emit final updated list
          final finalPayments = await _localDataSource
              .getCachedAccountInvoicePayments(accountId);
          final finalEntities = finalPayments
              .map((model) => model.toEntity())
              .toList();
          _accountInvoicePaymentsController.add(finalEntities);

          return remotePayment.toEntity();
        } catch (e) {
          _logger.w('Remote creation failed for account $accountId: $e');
          // Return locally cached payment if remote creation fails
          return paymentModel.toEntity();
        }
      } else {
        _logger.d(
          'Device offline, invoice payment created locally for account: $accountId',
        );
        return paymentModel.toEntity();
      }
    } catch (e) {
      _logger.e('Error creating invoice payment for account $accountId: $e');
      rethrow;
    }
  }

  /// Dispose resources
  void dispose() {
    _accountInvoicePaymentsController.close();
    _logger.d('AccountInvoicePaymentsRepositoryImpl disposed');
  }
}
