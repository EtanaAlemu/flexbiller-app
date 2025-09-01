import 'dart:async';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import '../../../../../core/network/network_info.dart';
import '../../domain/entities/account_payment.dart';
import '../../domain/repositories/account_payments_repository.dart';
import '../datasources/remote/account_payments_remote_data_source.dart';
import '../datasources/local/account_payments_local_data_source.dart';

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
    try {
      // First, get data from local cache for immediate response
      final cachedPayments = await _localDataSource.getCachedAccountPayments(accountId);
      
      // Emit cached data immediately for UI responsiveness
      if (cachedPayments.isNotEmpty) {
        final entities = cachedPayments.map((model) => model.toEntity()).toList();
        _accountPaymentsController.add(entities);
      }

      // Check if device is online for background synchronization
      if (await _networkInfo.isConnected) {
        try {
          // Fetch fresh data from remote source
          final remotePayments = await _remoteDataSource.getAccountPayments(accountId);
          
          // Cache the fresh data locally
          await _localDataSource.cacheAccountPayments(accountId, remotePayments);
          
          // Emit updated data
          final entities = remotePayments.map((model) => model.toEntity()).toList();
          _accountPaymentsController.add(entities);
          
          _logger.d('Synchronized payments for account: $accountId');
          return entities;
        } catch (e) {
          _logger.w('Remote sync failed for account $accountId: $e');
          // Return cached data if remote sync fails
          if (cachedPayments.isNotEmpty) {
            return cachedPayments.map((model) => model.toEntity()).toList();
          }
          rethrow;
        }
      } else {
        _logger.d('Device offline, using cached payments for account: $accountId');
        // Return cached data if offline
        if (cachedPayments.isNotEmpty) {
          return cachedPayments.map((model) => model.toEntity()).toList();
        }
        throw Exception('No cached data available and device is offline');
      }
    } catch (e) {
      _logger.e('Error getting payments for account $accountId: $e');
      rethrow;
    }
  }

  @override
  Future<AccountPayment> getAccountPayment(String accountId, String paymentId) async {
    try {
      // First, try to get from local cache
      final cachedPayment = await _localDataSource.getCachedAccountPayment(paymentId);
      
      if (cachedPayment != null) {
        return cachedPayment.toEntity();
      }

      // If not in cache and online, fetch from remote
      if (await _networkInfo.isConnected) {
        try {
          final remotePayment = await _remoteDataSource.getAccountPayment(accountId, paymentId);
          
          // Cache the fetched data
          await _localDataSource.cacheAccountPayment(remotePayment);
          
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
  Future<List<AccountPayment>> getAccountPaymentsByStatus(String accountId, String status) async {
    try {
      // First, get data from local cache for immediate response
      final cachedPayments = await _localDataSource.getCachedPaymentsByStatus(accountId, status);
      
      // Emit cached data immediately for UI responsiveness
      if (cachedPayments.isNotEmpty) {
        final entities = cachedPayments.map((model) => model.toEntity()).toList();
        _accountPaymentsController.add(entities);
      }

      // Check if device is online for background synchronization
      if (await _networkInfo.isConnected) {
        try {
          // Fetch fresh data from remote source
          final remotePayments = await _remoteDataSource.getAccountPaymentsByStatus(accountId, status);
          
          // Cache the fresh data locally
          await _localDataSource.cacheAccountPayments(accountId, remotePayments);
          
          // Emit updated data
          final entities = remotePayments.map((model) => model.toEntity()).toList();
          _accountPaymentsController.add(entities);
          
          _logger.d('Synchronized payments by status $status for account: $accountId');
          return entities;
        } catch (e) {
          _logger.w('Remote sync failed for payments by status $status: $e');
          // Return cached data if remote sync fails
          if (cachedPayments.isNotEmpty) {
            return cachedPayments.map((model) => model.toEntity()).toList();
          }
          rethrow;
        }
      } else {
        _logger.d('Device offline, using cached payments by status $status for account: $accountId');
        // Return cached data if offline
        if (cachedPayments.isNotEmpty) {
          return cachedPayments.map((model) => model.toEntity()).toList();
        }
        throw Exception('No cached data available and device is offline');
      }
    } catch (e) {
      _logger.e('Error getting payments by status $status for account $accountId: $e');
      rethrow;
    }
  }

  @override
  Future<List<AccountPayment>> getAccountPaymentsByType(String accountId, String type) async {
    try {
      // First, get data from local cache for immediate response
      final cachedPayments = await _localDataSource.getCachedPaymentsByType(accountId, type);
      
      // Emit cached data immediately for UI responsiveness
      if (cachedPayments.isNotEmpty) {
        final entities = cachedPayments.map((model) => model.toEntity()).toList();
        _accountPaymentsController.add(entities);
      }

      // Check if device is online for background synchronization
      if (await _networkInfo.isConnected) {
        try {
          // Fetch fresh data from remote source
          final remotePayments = await _remoteDataSource.getAccountPaymentsByType(accountId, type);
          
          // Cache the fresh data locally
          await _localDataSource.cacheAccountPayments(accountId, remotePayments);
          
          // Emit updated data
          final entities = remotePayments.map((model) => model.toEntity()).toList();
          _accountPaymentsController.add(entities);
          
          _logger.d('Synchronized payments by type $type for account: $accountId');
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
        _logger.d('Device offline, using cached payments by type $type for account: $accountId');
        // Return cached data if offline
        if (cachedPayments.isNotEmpty) {
          return cachedPayments.map((model) => model.toEntity()).toList();
        }
        throw Exception('No cached data available and device is offline');
      }
    } catch (e) {
      _logger.e('Error getting payments by type $type for account $accountId: $e');
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
      final cachedPayments = await _localDataSource.getCachedPaymentsByDateRange(accountId, startDate, endDate);
      
      // Emit cached data immediately for UI responsiveness
      if (cachedPayments.isNotEmpty) {
        final entities = cachedPayments.map((model) => model.toEntity()).toList();
        _accountPaymentsController.add(entities);
      }

      // Check if device is online for background synchronization
      if (await _networkInfo.isConnected) {
        try {
          // Fetch fresh data from remote source
          final remotePayments = await _remoteDataSource.getAccountPaymentsByDateRange(
            accountId,
            startDate,
            endDate,
          );
          
          // Cache the fresh data locally
          await _localDataSource.cacheAccountPayments(accountId, remotePayments);
          
          // Emit updated data
          final entities = remotePayments.map((model) => model.toEntity()).toList();
          _accountPaymentsController.add(entities);
          
          _logger.d('Synchronized payments by date range for account: $accountId');
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
        _logger.d('Device offline, using cached payments by date range for account: $accountId');
        // Return cached data if offline
        if (cachedPayments.isNotEmpty) {
          return cachedPayments.map((model) => model.toEntity()).toList();
        }
        throw Exception('No cached data available and device is offline');
      }
    } catch (e) {
      _logger.e('Error getting payments by date range for account $accountId: $e');
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
      final cachedPayments = await _localDataSource.getCachedPaymentsWithPagination(accountId, page, pageSize);
      
      // Emit cached data immediately for UI responsiveness
      if (cachedPayments.isNotEmpty) {
        final entities = cachedPayments.map((model) => model.toEntity()).toList();
        _accountPaymentsController.add(entities);
      }

      // Check if device is online for background synchronization
      if (await _networkInfo.isConnected) {
        try {
          // Fetch fresh data from remote source
          final remotePayments = await _remoteDataSource.getAccountPaymentsWithPagination(
            accountId,
            page,
            pageSize,
          );
          
          // Cache the fresh data locally
          await _localDataSource.cacheAccountPayments(accountId, remotePayments);
          
          // Emit updated data
          final entities = remotePayments.map((model) => model.toEntity()).toList();
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
        _logger.d('Device offline, using cached paginated payments for account: $accountId');
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
  Future<Map<String, dynamic>> getAccountPaymentStatistics(String accountId) async {
    try {
      // This method requires fresh data from remote, so check online status first
      if (!await _networkInfo.isConnected) {
        throw Exception('Cannot get payment statistics while offline');
      }

      try {
        final statistics = await _remoteDataSource.getAccountPaymentStatistics(accountId);
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
  Future<List<AccountPayment>> searchAccountPayments(String accountId, String searchTerm) async {
    try {
      // First, get data from local cache for immediate response
      final cachedPayments = await _localDataSource.searchCachedPaymentsByText(accountId, searchTerm);
      
      // Emit cached data immediately for UI responsiveness
      if (cachedPayments.isNotEmpty) {
        final entities = cachedPayments.map((model) => model.toEntity()).toList();
        _accountPaymentsController.add(entities);
      }

      // Check if device is online for background synchronization
      if (await _networkInfo.isConnected) {
        try {
          // Fetch fresh data from remote source
          final remotePayments = await _remoteDataSource.searchAccountPayments(accountId, searchTerm);
          
          // Cache the fresh data locally
          await _localDataSource.cacheAccountPayments(accountId, remotePayments);
          
          // Emit updated data
          final entities = remotePayments.map((model) => model.toEntity()).toList();
          _accountPaymentsController.add(entities);
          
          _logger.d('Synchronized search results for term "$searchTerm" for account: $accountId');
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
        _logger.d('Device offline, using cached search results for term "$searchTerm" for account: $accountId');
        // Return cached data if offline
        if (cachedPayments.isNotEmpty) {
          return cachedPayments.map((model) => model.toEntity()).toList();
        }
        throw Exception('No cached data available and device is offline');
      }
    } catch (e) {
      _logger.e('Error searching payments for term "$searchTerm" for account $accountId: $e');
      rethrow;
    }
  }

  @override
  Future<List<AccountPayment>> getRefundedPayments(String accountId) async {
    try {
      // First, get data from local cache for immediate response
      final cachedPayments = await _localDataSource.getCachedRefundedPayments(accountId);
      
      // Emit cached data immediately for UI responsiveness
      if (cachedPayments.isNotEmpty) {
        final entities = cachedPayments.map((model) => model.toEntity()).toList();
        _accountPaymentsController.add(entities);
      }

      // Check if device is online for background synchronization
      if (await _networkInfo.isConnected) {
        try {
          // Fetch fresh data from remote source
          final remotePayments = await _remoteDataSource.getRefundedPayments(accountId);
          
          // Cache the fresh data locally
          await _localDataSource.cacheAccountPayments(accountId, remotePayments);
          
          // Emit updated data
          final entities = remotePayments.map((model) => model.toEntity()).toList();
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
        _logger.d('Device offline, using cached refunded payments for account: $accountId');
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
      final cachedPayments = await _localDataSource.getCachedFailedPayments(accountId);
      
      // Emit cached data immediately for UI responsiveness
      if (cachedPayments.isNotEmpty) {
        final entities = cachedPayments.map((model) => model.toEntity()).toList();
        _accountPaymentsController.add(entities);
      }

      // Check if device is online for background synchronization
      if (await _networkInfo.isConnected) {
        try {
          // Fetch fresh data from remote source
          final remotePayments = await _remoteDataSource.getFailedPayments(accountId);
          
          // Cache the fresh data locally
          await _localDataSource.cacheAccountPayments(accountId, remotePayments);
          
          // Emit updated data
          final entities = remotePayments.map((model) => model.toEntity()).toList();
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
        _logger.d('Device offline, using cached failed payments for account: $accountId');
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
      final cachedPayments = await _localDataSource.getCachedSuccessfulPayments(accountId);
      
      // Emit cached data immediately for UI responsiveness
      if (cachedPayments.isNotEmpty) {
        final entities = cachedPayments.map((model) => model.toEntity()).toList();
        _accountPaymentsController.add(entities);
      }

      // Check if device is online for background synchronization
      if (await _networkInfo.isConnected) {
        try {
          // Fetch fresh data from remote source
          final remotePayments = await _remoteDataSource.getSuccessfulPayments(accountId);
          
          // Cache the fresh data locally
          await _localDataSource.cacheAccountPayments(accountId, remotePayments);
          
          // Emit updated data
          final entities = remotePayments.map((model) => model.toEntity()).toList();
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
        _logger.d('Device offline, using cached successful payments for account: $accountId');
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
      final cachedPayments = await _localDataSource.getCachedPendingPayments(accountId);
      
      // Emit cached data immediately for UI responsiveness
      if (cachedPayments.isNotEmpty) {
        final entities = cachedPayments.map((model) => model.toEntity()).toList();
        _accountPaymentsController.add(entities);
      }

      // Check if device is online for background synchronization
      if (await _networkInfo.isConnected) {
        try {
          // Fetch fresh data from remote source
          final remotePayments = await _remoteDataSource.getPendingPayments(accountId);
          
          // Cache the fresh data locally
          await _localDataSource.cacheAccountPayments(accountId, remotePayments);
          
          // Emit updated data
          final entities = remotePayments.map((model) => model.toEntity()).toList();
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
        _logger.d('Device offline, using cached pending payments for account: $accountId');
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
      // If online, create on remote first
      if (await _networkInfo.isConnected) {
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
          
          // Cache the created payment locally
          await _localDataSource.cacheAccountPayment(remotePayment);
          
          // Emit updated data
          final cachedPayments = await _localDataSource.getCachedAccountPayments(accountId);
          final entities = cachedPayments.map((model) => model.toEntity()).toList();
          _accountPaymentsController.add(entities);
          
          _logger.d('Created payment ${remotePayment.id} for account: $accountId');
          return remotePayment.toEntity();
        } catch (e) {
          _logger.w('Remote creation failed: $e');
          rethrow;
        }
      } else {
        throw Exception('Cannot create payment while offline');
      }
    } catch (e) {
      _logger.e('Error creating payment for account $accountId: $e');
      rethrow;
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
          final cachedPayments = await _localDataSource.getCachedAccountPayments(remotePayment.accountId);
          final entities = cachedPayments.map((model) => model.toEntity()).toList();
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
