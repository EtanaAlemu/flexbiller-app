import 'dart:async';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import '../../../../../core/network/network_info.dart';
import '../../domain/entities/account_payment.dart';
import '../../domain/repositories/account_payments_repository.dart';
import '../datasources/remote/account_payments_remote_data_source.dart';
import '../datasources/local/account_payments_local_data_source.dart';
import '../models/account_payment_model.dart';

@Injectable(as: AccountPaymentsRepository)
class AccountPaymentsRepositoryImpl implements AccountPaymentsRepository {
  final AccountPaymentsRemoteDataSource _remoteDataSource;
  final AccountPaymentsLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;
  final Logger _logger;

  final StreamController<List<AccountPayment>> _accountPaymentsController =
      StreamController<List<AccountPayment>>.broadcast();

  AccountPaymentsRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
    this._networkInfo,
    this._logger,
  );

  @override
  Stream<List<AccountPayment>> get accountPaymentsStream =>
      _accountPaymentsController.stream;

  @override
  Future<List<AccountPayment>> getAccountPayments(String accountId) async {
    print(
      '🔍 AccountPaymentsRepositoryImpl: getAccountPayments called for accountId: $accountId',
    );
    try {
      // LOCAL-FIRST: Always read from local cache first (single source of truth)
      print(
        '🔍 AccountPaymentsRepositoryImpl: Getting cached payments from local data source',
      );
      final cachedPayments = await _localDataSource.getCachedAccountPayments(
        accountId,
      );
      print(
        '🔍 AccountPaymentsRepositoryImpl: Found ${cachedPayments.length} cached payments',
      );

      // Convert to entities and emit immediately for instant UI response
      final entities = cachedPayments.map((model) => model.toEntity()).toList();

      print(
        '🔍 AccountPaymentsRepositoryImpl: Emitting cached data to stream immediately',
      );
      _accountPaymentsController.add(entities);

      // Return local data immediately (local-first principle)
      print(
        '🔍 AccountPaymentsRepositoryImpl: Returning ${entities.length} payments from local cache',
      );

      // BACKGROUND SYNC: Check if device is online for background synchronization
      print('🔍 AccountPaymentsRepositoryImpl: Checking network connectivity');
      if (await _networkInfo.isConnected) {
        print(
          '🔍 AccountPaymentsRepositoryImpl: Device is online, starting background sync',
        );

        // Perform background sync without blocking the UI
        _performBackgroundSync(accountId);
      } else {
        _logger.d(
          'Device offline, using cached payments for account: $accountId',
        );
      }

      // Always return local data (even if empty)
      return entities;
    } catch (e) {
      _logger.e('Error getting payments for account $accountId: $e');
      rethrow;
    }
  }

  /// Performs background synchronization with remote server
  Future<void> _performBackgroundSync(String accountId) async {
    try {
      print('🔍 AccountPaymentsRepositoryImpl: Starting background sync');

      // Fetch fresh data from remote source
      final remotePayments = await _remoteDataSource.getAccountPayments(
        accountId,
      );
      print(
        '🔍 AccountPaymentsRepositoryImpl: Remote data source returned ${remotePayments.length} payments',
      );

      // Cache the fresh data locally (this becomes the new source of truth)
      print('🔍 AccountPaymentsRepositoryImpl: Caching remote data locally');
      await _localDataSource.cacheAccountPayments(accountId, remotePayments);

      // Emit updated data to stream (UI will reactively update)
      print(
        '🔍 AccountPaymentsRepositoryImpl: Emitting updated data to stream',
      );
      final entities = remotePayments.map((model) => model.toEntity()).toList();
      _accountPaymentsController.add(entities);

      print(
        '🔍 AccountPaymentsRepositoryImpl: Background sync completed for account: $accountId',
      );
      _logger.d('Background sync completed for account: $accountId');
    } catch (e) {
      _logger.w('Background sync failed for account $accountId: $e');
      // Don't throw - background sync failures shouldn't affect the UI
    }
  }

  @override
  Future<AccountPayment> getAccountPayment(
    String accountId,
    String paymentId,
  ) async {
    try {
      // LOCAL-FIRST: Always try local cache first
      final cachedPayment = await _localDataSource.getCachedAccountPayment(
        paymentId,
      );

      if (cachedPayment != null) {
        _logger.d('Payment $paymentId found in local cache');
        return cachedPayment.toEntity();
      }

      // If not in cache and online, fetch from remote
      if (await _networkInfo.isConnected) {
        try {
          final remotePayment = await _remoteDataSource.getAccountPayment(
            accountId,
            paymentId,
          );

          // Cache the fetched data locally
          await _localDataSource.cacheAccountPayment(remotePayment);

          _logger.d(
            'Payment $paymentId fetched from remote and cached locally',
          );
          return remotePayment.toEntity();
        } catch (e) {
          _logger.w('Remote fetch failed for payment $paymentId: $e');
          rethrow;
        }
      } else {
        throw Exception('Payment not found in cache and device is offline');
      }
    } catch (e) {
      _logger.e('Error getting payment $paymentId: $e');
      rethrow;
    }
  }

  @override
  Future<List<AccountPayment>> getAccountPaymentsByStatus(
    String accountId,
    String status,
  ) async {
    try {
      // LOCAL-FIRST: Always read from local cache first
      final cachedPayments = await _localDataSource.getCachedPaymentsByStatus(
        accountId,
        status,
      );

      // Convert to entities and emit immediately
      final entities = cachedPayments.map((model) => model.toEntity()).toList();
      _accountPaymentsController.add(entities);

      // Return local data immediately
      _logger.d(
        'Returning ${entities.length} payments by status $status from local cache',
      );

      // BACKGROUND SYNC: If online, sync in background
      if (await _networkInfo.isConnected) {
        _performBackgroundSyncByStatus(accountId, status);
      } else {
        _logger.d('Device offline, using cached payments by status $status');
      }

      return entities;
    } catch (e) {
      _logger.e(
        'Error getting payments by status $status for account $accountId: $e',
      );
      rethrow;
    }
  }

  /// Performs background synchronization for payments by status
  Future<void> _performBackgroundSyncByStatus(
    String accountId,
    String status,
  ) async {
    try {
      final remotePayments = await _remoteDataSource.getAccountPaymentsByStatus(
        accountId,
        status,
      );

      await _localDataSource.cacheAccountPayments(accountId, remotePayments);

      final entities = remotePayments.map((model) => model.toEntity()).toList();
      _accountPaymentsController.add(entities);

      _logger.d('Background sync completed for payments by status $status');
    } catch (e) {
      _logger.w('Background sync failed for payments by status $status: $e');
    }
  }

  @override
  Future<List<AccountPayment>> getAccountPaymentsByType(
    String accountId,
    String type,
  ) async {
    try {
      // First, get data from local cache for immediate response
      final cachedPayments = await _localDataSource.getCachedPaymentsByType(
        accountId,
        type,
      );

      // Emit cached data immediately for UI responsiveness
      if (cachedPayments.isNotEmpty) {
        final entities = cachedPayments
            .map((model) => model.toEntity())
            .toList();
        _accountPaymentsController.add(entities);
      }

      // Check if device is online for background synchronization
      if (await _networkInfo.isConnected) {
        try {
          // Fetch fresh data from remote source
          final remotePayments = await _remoteDataSource
              .getAccountPaymentsByType(accountId, type);

          // Cache the fresh data locally
          await _localDataSource.cacheAccountPayments(
            accountId,
            remotePayments,
          );

          // Emit updated data
          final entities = remotePayments
              .map((model) => model.toEntity())
              .toList();
          _accountPaymentsController.add(entities);

          _logger.d(
            'Synchronized payments by type $type for account: $accountId',
          );
          return entities;
        } catch (e) {
          _logger.w('Remote sync failed for payments by type $type: $e');
          // Return cached data if remote sync fails
          if (cachedPayments.isNotEmpty) {
            return cachedPayments.map((model) => model.toEntity()).toList();
          }
          rethrow;
        }
      } else {
        _logger.d(
          'Device offline, using cached payments by type $type for account: $accountId',
        );
        // Return cached data if offline
        if (cachedPayments.isNotEmpty) {
          return cachedPayments.map((model) => model.toEntity()).toList();
        }
        throw Exception('No cached data available and device is offline');
      }
    } catch (e) {
      _logger.e(
        'Error getting payments by type $type for account $accountId: $e',
      );
      rethrow;
    }
  }

  @override
  Future<List<AccountPayment>> getAccountPaymentsByDateRange(
    String accountId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      // First, get data from local cache for immediate response
      final cachedPayments = await _localDataSource
          .getCachedPaymentsByDateRange(accountId, startDate, endDate);

      // Emit cached data immediately for UI responsiveness
      if (cachedPayments.isNotEmpty) {
        final entities = cachedPayments
            .map((model) => model.toEntity())
            .toList();
        _accountPaymentsController.add(entities);
      }

      // Check if device is online for background synchronization
      if (await _networkInfo.isConnected) {
        try {
          // Fetch fresh data from remote source
          final remotePayments = await _remoteDataSource
              .getAccountPaymentsByDateRange(accountId, startDate, endDate);

          // Cache the fresh data locally
          await _localDataSource.cacheAccountPayments(
            accountId,
            remotePayments,
          );

          // Emit updated data
          final entities = remotePayments
              .map((model) => model.toEntity())
              .toList();
          _accountPaymentsController.add(entities);

          _logger.d(
            'Synchronized payments by date range for account: $accountId',
          );
          return entities;
        } catch (e) {
          _logger.w('Remote sync failed for payments by date range: $e');
          // Return cached data if remote sync fails
          if (cachedPayments.isNotEmpty) {
            return cachedPayments.map((model) => model.toEntity()).toList();
          }
          rethrow;
        }
      } else {
        _logger.d(
          'Device offline, using cached payments by date range for account: $accountId',
        );
        // Return cached data if offline
        if (cachedPayments.isNotEmpty) {
          return cachedPayments.map((model) => model.toEntity()).toList();
        }
        throw Exception('No cached data available and device is offline');
      }
    } catch (e) {
      _logger.e(
        'Error getting payments by date range for account $accountId: $e',
      );
      rethrow;
    }
  }

  @override
  Future<List<AccountPayment>> getAccountPaymentsWithPagination(
    String accountId,
    int page,
    int pageSize,
  ) async {
    try {
      // First, get data from local cache for immediate response
      final cachedPayments = await _localDataSource
          .getCachedPaymentsWithPagination(accountId, page, pageSize);

      // Emit cached data immediately for UI responsiveness
      if (cachedPayments.isNotEmpty) {
        final entities = cachedPayments
            .map((model) => model.toEntity())
            .toList();
        _accountPaymentsController.add(entities);
      }

      // Check if device is online for background synchronization
      if (await _networkInfo.isConnected) {
        try {
          // Fetch fresh data from remote source
          final remotePayments = await _remoteDataSource
              .getAccountPaymentsWithPagination(accountId, page, pageSize);

          // Cache the fresh data locally
          await _localDataSource.cacheAccountPayments(
            accountId,
            remotePayments,
          );

          // Emit updated data
          final entities = remotePayments
              .map((model) => model.toEntity())
              .toList();
          _accountPaymentsController.add(entities);

          _logger.d('Synchronized paginated payments for account: $accountId');
          return entities;
        } catch (e) {
          _logger.w('Remote sync failed for paginated payments: $e');
          // Return cached data if remote sync fails
          if (cachedPayments.isNotEmpty) {
            return cachedPayments.map((model) => model.toEntity()).toList();
          }
          rethrow;
        }
      } else {
        _logger.d(
          'Device offline, using cached paginated payments for account: $accountId',
        );
        // Return cached data if offline
        if (cachedPayments.isNotEmpty) {
          return cachedPayments.map((model) => model.toEntity()).toList();
        }
        throw Exception('No cached data available and device is offline');
      }
    } catch (e) {
      _logger.e('Error getting paginated payments for account $accountId: $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getAccountPaymentStatistics(
    String accountId,
  ) async {
    try {
      // This method requires fresh data from remote, so check online status first
      if (!await _networkInfo.isConnected) {
        throw Exception('Cannot get payment statistics while offline');
      }

      try {
        final statistics = await _remoteDataSource.getAccountPaymentStatistics(
          accountId,
        );
        _logger.d('Retrieved payment statistics for account: $accountId');
        return statistics;
      } catch (e) {
        _logger.w('Remote fetch failed for payment statistics: $e');
        rethrow;
      }
    } catch (e) {
      _logger.e('Error getting payment statistics for account $accountId: $e');
      rethrow;
    }
  }

  @override
  Future<List<AccountPayment>> searchAccountPayments(
    String accountId,
    String searchTerm,
  ) async {
    try {
      // First, get data from local cache for immediate response
      final cachedPayments = await _localDataSource.searchCachedPaymentsByText(
        accountId,
        searchTerm,
      );

      // Emit cached data immediately for UI responsiveness
      if (cachedPayments.isNotEmpty) {
        final entities = cachedPayments
            .map((model) => model.toEntity())
            .toList();
        _accountPaymentsController.add(entities);
      }

      // Check if device is online for background synchronization
      if (await _networkInfo.isConnected) {
        try {
          // Fetch fresh data from remote source
          final remotePayments = await _remoteDataSource.searchAccountPayments(
            accountId,
            searchTerm,
          );

          // Cache the fresh data locally
          await _localDataSource.cacheAccountPayments(
            accountId,
            remotePayments,
          );

          // Emit updated data
          final entities = remotePayments
              .map((model) => model.toEntity())
              .toList();
          _accountPaymentsController.add(entities);

          _logger.d(
            'Synchronized search results for term "$searchTerm" for account: $accountId',
          );
          return entities;
        } catch (e) {
          _logger.w('Remote sync failed for search term "$searchTerm": $e');
          // Return cached data if remote sync fails
          if (cachedPayments.isNotEmpty) {
            return cachedPayments.map((model) => model.toEntity()).toList();
          }
          rethrow;
        }
      } else {
        _logger.d(
          'Device offline, using cached search results for term "$searchTerm" for account: $accountId',
        );
        // Return cached data if offline
        if (cachedPayments.isNotEmpty) {
          return cachedPayments.map((model) => model.toEntity()).toList();
        }
        throw Exception('No cached data available and device is offline');
      }
    } catch (e) {
      _logger.e(
        'Error searching payments for term "$searchTerm" for account $accountId: $e',
      );
      rethrow;
    }
  }

  @override
  Future<List<AccountPayment>> getRefundedPayments(String accountId) async {
    try {
      // First, get data from local cache for immediate response
      final cachedPayments = await _localDataSource.getCachedRefundedPayments(
        accountId,
      );

      // Emit cached data immediately for UI responsiveness
      if (cachedPayments.isNotEmpty) {
        final entities = cachedPayments
            .map((model) => model.toEntity())
            .toList();
        _accountPaymentsController.add(entities);
      }

      // Check if device is online for background synchronization
      if (await _networkInfo.isConnected) {
        try {
          // Fetch fresh data from remote source
          final remotePayments = await _remoteDataSource.getRefundedPayments(
            accountId,
          );

          // Cache the fresh data locally
          await _localDataSource.cacheAccountPayments(
            accountId,
            remotePayments,
          );

          // Emit updated data
          final entities = remotePayments
              .map((model) => model.toEntity())
              .toList();
          _accountPaymentsController.add(entities);

          _logger.d('Synchronized refunded payments for account: $accountId');
          return entities;
        } catch (e) {
          _logger.w('Remote sync failed for refunded payments: $e');
          // Return cached data if remote sync fails
          if (cachedPayments.isNotEmpty) {
            return cachedPayments.map((model) => model.toEntity()).toList();
          }
          rethrow;
        }
      } else {
        _logger.d(
          'Device offline, using cached refunded payments for account: $accountId',
        );
        // Return cached data if offline
        if (cachedPayments.isNotEmpty) {
          return cachedPayments.map((model) => model.toEntity()).toList();
        }
        throw Exception('No cached data available and device is offline');
      }
    } catch (e) {
      _logger.e('Error getting refunded payments for account $accountId: $e');
      rethrow;
    }
  }

  @override
  Future<List<AccountPayment>> getFailedPayments(String accountId) async {
    try {
      // First, get data from local cache for immediate response
      final cachedPayments = await _localDataSource.getCachedFailedPayments(
        accountId,
      );

      // Emit cached data immediately for UI responsiveness
      if (cachedPayments.isNotEmpty) {
        final entities = cachedPayments
            .map((model) => model.toEntity())
            .toList();
        _accountPaymentsController.add(entities);
      }

      // Check if device is online for background synchronization
      if (await _networkInfo.isConnected) {
        try {
          // Fetch fresh data from remote source
          final remotePayments = await _remoteDataSource.getFailedPayments(
            accountId,
          );

          // Cache the fresh data locally
          await _localDataSource.cacheAccountPayments(
            accountId,
            remotePayments,
          );

          // Emit updated data
          final entities = remotePayments
              .map((model) => model.toEntity())
              .toList();
          _accountPaymentsController.add(entities);

          _logger.d('Synchronized failed payments for account: $accountId');
          return entities;
        } catch (e) {
          _logger.w('Remote sync failed for failed payments: $e');
          // Return cached data if remote sync fails
          if (cachedPayments.isNotEmpty) {
            return cachedPayments.map((model) => model.toEntity()).toList();
          }
          rethrow;
        }
      } else {
        _logger.d(
          'Device offline, using cached failed payments for account: $accountId',
        );
        // Return cached data if offline
        if (cachedPayments.isNotEmpty) {
          return cachedPayments.map((model) => model.toEntity()).toList();
        }
        throw Exception('No cached data available and device is offline');
      }
    } catch (e) {
      _logger.e('Error getting failed payments for account $accountId: $e');
      rethrow;
    }
  }

  @override
  Future<List<AccountPayment>> getSuccessfulPayments(String accountId) async {
    try {
      // First, get data from local cache for immediate response
      final cachedPayments = await _localDataSource.getCachedSuccessfulPayments(
        accountId,
      );

      // Emit cached data immediately for UI responsiveness
      if (cachedPayments.isNotEmpty) {
        final entities = cachedPayments
            .map((model) => model.toEntity())
            .toList();
        _accountPaymentsController.add(entities);
      }

      // Check if device is online for background synchronization
      if (await _networkInfo.isConnected) {
        try {
          // Fetch fresh data from remote source
          final remotePayments = await _remoteDataSource.getSuccessfulPayments(
            accountId,
          );

          // Cache the fresh data locally
          await _localDataSource.cacheAccountPayments(
            accountId,
            remotePayments,
          );

          // Emit updated data
          final entities = remotePayments
              .map((model) => model.toEntity())
              .toList();
          _accountPaymentsController.add(entities);

          _logger.d('Synchronized successful payments for account: $accountId');
          return entities;
        } catch (e) {
          _logger.w('Remote sync failed for successful payments: $e');
          // Return cached data if remote sync fails
          if (cachedPayments.isNotEmpty) {
            return cachedPayments.map((model) => model.toEntity()).toList();
          }
          rethrow;
        }
      } else {
        _logger.d(
          'Device offline, using cached successful payments for account: $accountId',
        );
        // Return cached data if offline
        if (cachedPayments.isNotEmpty) {
          return cachedPayments.map((model) => model.toEntity()).toList();
        }
        throw Exception('No cached data available and device is offline');
      }
    } catch (e) {
      _logger.e('Error getting successful payments for account $accountId: $e');
      rethrow;
    }
  }

  @override
  Future<List<AccountPayment>> getPendingPayments(String accountId) async {
    try {
      // First, get data from local cache for immediate response
      final cachedPayments = await _localDataSource.getCachedPendingPayments(
        accountId,
      );

      // Emit cached data immediately for UI responsiveness
      if (cachedPayments.isNotEmpty) {
        final entities = cachedPayments
            .map((model) => model.toEntity())
            .toList();
        _accountPaymentsController.add(entities);
      }

      // Check if device is online for background synchronization
      if (await _networkInfo.isConnected) {
        try {
          // Fetch fresh data from remote source
          final remotePayments = await _remoteDataSource.getPendingPayments(
            accountId,
          );

          // Cache the fresh data locally
          await _localDataSource.cacheAccountPayments(
            accountId,
            remotePayments,
          );

          // Emit updated data
          final entities = remotePayments
              .map((model) => model.toEntity())
              .toList();
          _accountPaymentsController.add(entities);

          _logger.d('Synchronized pending payments for account: $accountId');
          return entities;
        } catch (e) {
          _logger.w('Remote sync failed for pending payments: $e');
          // Return cached data if remote sync fails
          if (cachedPayments.isNotEmpty) {
            return cachedPayments.map((model) => model.toEntity()).toList();
          }
          rethrow;
        }
      } else {
        _logger.d(
          'Device offline, using cached pending payments for account: $accountId',
        );
        // Return cached data if offline
        if (cachedPayments.isNotEmpty) {
          return cachedPayments.map((model) => model.toEntity()).toList();
        }
        throw Exception('No cached data available and device is offline');
      }
    } catch (e) {
      _logger.e('Error getting pending payments for account $accountId: $e');
      rethrow;
    }
  }

  @override
  Future<AccountPayment> createAccountPayment({
    required String accountId,
    required String paymentMethodId,
    required String transactionType,
    required double amount,
    required String currency,
    required DateTime effectiveDate,
    String? description,
    Map<String, dynamic>? properties,
  }) async {
    try {
      // LOCAL-FIRST: Create payment locally first (optimistic UI)
      final localPayment = AccountPayment.create(
        accountId: accountId,
        paymentMethodId: paymentMethodId,
        transactionType: transactionType,
        amount: amount,
        currency: currency,
        effectiveDate: effectiveDate,
        description: description,
        properties: properties,
      );

      // Cache the payment locally immediately
      await _localDataSource.cacheAccountPayment(
        AccountPaymentModel.fromEntity(localPayment),
      );

      // Emit updated data immediately for instant UI feedback
      final cachedPayments = await _localDataSource.getCachedAccountPayments(
        accountId,
      );
      final entities = cachedPayments.map((model) => model.toEntity()).toList();
      _accountPaymentsController.add(entities);

      _logger.d('Payment created locally for account: $accountId');

      // BACKGROUND SYNC: If online, sync with remote server
      if (await _networkInfo.isConnected) {
        _performBackgroundCreatePayment(
          accountId: accountId,
          paymentMethodId: paymentMethodId,
          transactionType: transactionType,
          amount: amount,
          currency: currency,
          effectiveDate: effectiveDate,
          description: description,
          properties: properties,
        );
      } else {
        _logger.d('Device offline, payment will be synced when online');
      }

      return localPayment;
    } catch (e) {
      _logger.e('Error creating payment for account $accountId: $e');
      rethrow;
    }
  }

  /// Performs background synchronization for payment creation
  Future<void> _performBackgroundCreatePayment({
    required String accountId,
    required String paymentMethodId,
    required String transactionType,
    required double amount,
    required String currency,
    required DateTime effectiveDate,
    String? description,
    Map<String, dynamic>? properties,
  }) async {
    try {
      final remotePayment = await _remoteDataSource.createAccountPayment(
        accountId: accountId,
        paymentMethodId: paymentMethodId,
        transactionType: transactionType,
        amount: amount,
        currency: currency,
        effectiveDate: effectiveDate,
        description: description,
        properties: properties,
      );

      // Update local cache with server response
      await _localDataSource.cacheAccountPayment(remotePayment);

      // Emit updated data
      final cachedPayments = await _localDataSource.getCachedAccountPayments(
        accountId,
      );
      final entities = cachedPayments.map((model) => model.toEntity()).toList();
      _accountPaymentsController.add(entities);

      _logger.d(
        'Payment ${remotePayment.id} synced with server for account: $accountId',
      );
    } catch (e) {
      _logger.w('Background sync failed for payment creation: $e');
      // Could implement retry logic or mark as pending sync
    }
  }

  @override
  Future<AccountPayment> createGlobalPayment({
    required String externalKey,
    required String paymentMethodId,
    required String transactionExternalKey,
    required String paymentExternalKey,
    required String transactionType,
    required double amount,
    required String currency,
    required DateTime effectiveDate,
    List<Map<String, dynamic>>? properties,
  }) async {
    try {
      // If online, create on remote first
      if (await _networkInfo.isConnected) {
        try {
          final remotePayment = await _remoteDataSource.createGlobalPayment(
            externalKey: externalKey,
            paymentMethodId: paymentMethodId,
            transactionExternalKey: transactionExternalKey,
            paymentExternalKey: paymentExternalKey,
            transactionType: transactionType,
            amount: amount,
            currency: currency,
            effectiveDate: effectiveDate,
            properties: properties,
          );

          // Cache the created payment locally
          await _localDataSource.cacheAccountPayment(remotePayment);

          // Emit updated data for the account
          final cachedPayments = await _localDataSource
              .getCachedAccountPayments(remotePayment.accountId);
          final entities = cachedPayments
              .map((model) => model.toEntity())
              .toList();
          _accountPaymentsController.add(entities);

          _logger.d('Created global payment ${remotePayment.id}');
          return remotePayment.toEntity();
        } catch (e) {
          _logger.w('Remote global creation failed: $e');
          rethrow;
        }
      } else {
        throw Exception('Cannot create global payment while offline');
      }
    } catch (e) {
      _logger.e('Error creating global payment: $e');
      rethrow;
    }
  }

  /// Dispose of the stream controller
  void dispose() {
    _accountPaymentsController.close();
  }
}
