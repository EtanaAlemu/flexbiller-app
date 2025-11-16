import 'dart:async';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import '../../../../../core/network/network_info.dart';
import '../../domain/entities/account_payment_method.dart';
import '../../domain/repositories/account_payment_methods_repository.dart';
import '../datasources/remote/account_payment_methods_remote_data_source.dart';
import '../datasources/local/account_payment_methods_local_data_source.dart';

@Injectable(as: AccountPaymentMethodsRepository)
class AccountPaymentMethodsRepositoryImpl
    implements AccountPaymentMethodsRepository {
  final AccountPaymentMethodsRemoteDataSource _remoteDataSource;
  final AccountPaymentMethodsLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;
  final Logger _logger;

  final StreamController<List<AccountPaymentMethod>>
  _accountPaymentMethodsController =
      StreamController<List<AccountPaymentMethod>>.broadcast();

  AccountPaymentMethodsRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
    this._networkInfo,
    this._logger,
  );

  @override
  Stream<List<AccountPaymentMethod>> get accountPaymentMethodsStream =>
      _accountPaymentMethodsController.stream;

  @override
  Future<List<AccountPaymentMethod>> getAccountPaymentMethods(
    String accountId,
  ) async {
    _logger.d(
      '🔍 AccountPaymentMethodsRepositoryImpl: getAccountPaymentMethods called for accountId: $accountId',
    );
    try {
      // LOCAL-FIRST: Always read from local cache first (single source of truth)
      _logger.d(
        '🔍 AccountPaymentMethodsRepositoryImpl: Getting cached payment methods from local data source',
      );
      final cachedMethods = await _localDataSource
          .getCachedAccountPaymentMethods(accountId);
      _logger.d(
        '🔍 AccountPaymentMethodsRepositoryImpl: Found ${cachedMethods.length} cached payment methods',
      );

      // Convert to entities and emit immediately for instant UI response
      final entities = cachedMethods.map((model) => model.toEntity()).toList();

      _logger.d(
        '🔍 AccountPaymentMethodsRepositoryImpl: Emitting cached data to stream immediately',
      );
      _accountPaymentMethodsController.add(entities);

      // Return local data immediately (local-first principle)
      _logger.d(
        '🔍 AccountPaymentMethodsRepositoryImpl: Returning ${entities.length} payment methods from local cache',
      );

      // BACKGROUND SYNC: Check if device is online for background synchronization
      _logger.d(
        '🔍 AccountPaymentMethodsRepositoryImpl: Checking network connectivity',
      );
      if (await _networkInfo.isConnected) {
        _logger.d(
          '🔍 AccountPaymentMethodsRepositoryImpl: Device is online, starting background sync',
        );

        // Perform background sync without blocking the UI
        _performBackgroundSync(accountId);
      } else {
        _logger.d(
          'Device offline, using cached payment methods for account: $accountId',
        );
      }

      // Always return local data (even if empty)
      return entities;
    } catch (e) {
      _logger.e('Error getting payment methods for account $accountId: $e');
      rethrow;
    }
  }

  /// Performs background synchronization with remote server
  Future<void> _performBackgroundSync(String accountId) async {
    try {
      _logger.d(
        '🔍 AccountPaymentMethodsRepositoryImpl: Starting background sync',
      );

      // Fetch fresh data from remote source
      final remoteMethods = await _remoteDataSource.getAccountPaymentMethods(
        accountId,
      );
      _logger.d(
        '🔍 AccountPaymentMethodsRepositoryImpl: Remote data source returned ${remoteMethods.length} payment methods',
      );

      // Cache the fresh data locally (this becomes the new source of truth)
      _logger.d(
        '🔍 AccountPaymentMethodsRepositoryImpl: Caching remote data locally',
      );
      await _localDataSource.cacheAccountPaymentMethods(
        accountId,
        remoteMethods,
      );

      // Emit updated data to stream (UI will reactively update)
      _logger.d(
        '🔍 AccountPaymentMethodsRepositoryImpl: Emitting updated data to stream',
      );
      final entities = remoteMethods.map((model) => model.toEntity()).toList();
      _accountPaymentMethodsController.add(entities);

      _logger.i(
        '🔍 AccountPaymentMethodsRepositoryImpl: Background sync completed for account: $accountId',
      );
      _logger.d('Background sync completed for account: $accountId');
    } catch (e) {
      _logger.w('Background sync failed for account $accountId: $e');
      // Don't throw - background sync failures shouldn't affect the UI
    }
  }

  @override
  Future<AccountPaymentMethod> getAccountPaymentMethod(
    String accountId,
    String paymentMethodId,
  ) async {
    try {
      // First, try to get from local cache
      final cachedMethod = await _localDataSource.getCachedAccountPaymentMethod(
        paymentMethodId,
      );

      if (cachedMethod != null) {
        return cachedMethod.toEntity();
      }

      // If not in cache and online, fetch from remote
      if (await _networkInfo.isConnected) {
        try {
          final remoteMethod = await _remoteDataSource.getAccountPaymentMethod(
            accountId,
            paymentMethodId,
          );

          // Cache the fetched data
          await _localDataSource.cacheAccountPaymentMethod(remoteMethod);

          return remoteMethod.toEntity();
        } catch (e) {
          _logger.w(
            'Remote fetch failed for payment method $paymentMethodId: $e',
          );
          rethrow;
        }
      } else {
        throw Exception(
          'Payment method not found in cache and device is offline',
        );
      }
    } catch (e) {
      _logger.e('Error getting payment method $paymentMethodId: $e');
      rethrow;
    }
  }

  @override
  Future<AccountPaymentMethod?> getDefaultPaymentMethod(
    String accountId,
  ) async {
    try {
      // First, try to get from local cache
      final cachedMethod = await _localDataSource.getCachedDefaultPaymentMethod(
        accountId,
      );

      if (cachedMethod != null) {
        return cachedMethod.toEntity();
      }

      // If not in cache and online, fetch from remote
      if (await _networkInfo.isConnected) {
        try {
          final remoteMethod = await _remoteDataSource.getDefaultPaymentMethod(
            accountId,
          );

          if (remoteMethod != null) {
            // Cache the fetched data
            await _localDataSource.cacheAccountPaymentMethod(remoteMethod);
          }

          return remoteMethod?.toEntity();
        } catch (e) {
          _logger.w('Remote fetch failed for default payment method: $e');
          return null;
        }
      } else {
        return null;
      }
    } catch (e) {
      _logger.e(
        'Error getting default payment method for account $accountId: $e',
      );
      rethrow;
    }
  }

  @override
  Future<List<AccountPaymentMethod>> getActivePaymentMethods(
    String accountId,
  ) async {
    try {
      // First, get data from local cache for immediate response
      final cachedMethods = await _localDataSource
          .getCachedActivePaymentMethods(accountId);

      // Emit cached data immediately for UI responsiveness
      if (cachedMethods.isNotEmpty) {
        final entities = cachedMethods
            .map((model) => model.toEntity())
            .toList();
        _accountPaymentMethodsController.add(entities);
      }

      // Check if device is online for background synchronization
      if (await _networkInfo.isConnected) {
        try {
          // Fetch fresh data from remote source
          final remoteMethods = await _remoteDataSource.getActivePaymentMethods(
            accountId,
          );

          // Cache the fresh data locally
          await _localDataSource.cacheAccountPaymentMethods(
            accountId,
            remoteMethods,
          );

          // Emit updated data
          final entities = remoteMethods
              .map((model) => model.toEntity())
              .toList();
          _accountPaymentMethodsController.add(entities);

          _logger.d(
            'Synchronized active payment methods for account: $accountId',
          );
          return entities;
        } catch (e) {
          _logger.w('Remote sync failed for active payment methods: $e');
          // Return cached data if remote sync fails
          if (cachedMethods.isNotEmpty) {
            return cachedMethods.map((model) => model.toEntity()).toList();
          }
          rethrow;
        }
      } else {
        _logger.d(
          'Device offline, using cached active payment methods for account: $accountId',
        );
        // Return cached data if offline
        if (cachedMethods.isNotEmpty) {
          return cachedMethods.map((model) => model.toEntity()).toList();
        }
        throw Exception('No cached data available and device is offline');
      }
    } catch (e) {
      _logger.e(
        'Error getting active payment methods for account $accountId: $e',
      );
      rethrow;
    }
  }

  @override
  Future<List<AccountPaymentMethod>> getPaymentMethodsByType(
    String accountId,
    String type,
  ) async {
    try {
      // First, get data from local cache for immediate response
      final cachedMethods = await _localDataSource
          .getCachedPaymentMethodsByType(accountId, type);

      // Emit cached data immediately for UI responsiveness
      if (cachedMethods.isNotEmpty) {
        final entities = cachedMethods
            .map((model) => model.toEntity())
            .toList();
        _accountPaymentMethodsController.add(entities);
      }

      // Check if device is online for background synchronization
      if (await _networkInfo.isConnected) {
        try {
          // Fetch fresh data from remote source
          final remoteMethods = await _remoteDataSource.getPaymentMethodsByType(
            accountId,
            type,
          );

          // Cache the fresh data locally
          await _localDataSource.cacheAccountPaymentMethods(
            accountId,
            remoteMethods,
          );

          // Emit updated data
          final entities = remoteMethods
              .map((model) => model.toEntity())
              .toList();
          _accountPaymentMethodsController.add(entities);

          _logger.d(
            'Synchronized payment methods by type $type for account: $accountId',
          );
          return entities;
        } catch (e) {
          _logger.w('Remote sync failed for payment methods by type $type: $e');
          // Return cached data if remote sync fails
          if (cachedMethods.isNotEmpty) {
            return cachedMethods.map((model) => model.toEntity()).toList();
          }
          rethrow;
        }
      } else {
        _logger.d(
          'Device offline, using cached payment methods by type $type for account: $accountId',
        );
        // Return cached data if offline
        if (cachedMethods.isNotEmpty) {
          return cachedMethods.map((model) => model.toEntity()).toList();
        }
        throw Exception('No cached data available and device is offline');
      }
    } catch (e) {
      _logger.e(
        'Error getting payment methods by type $type for account $accountId: $e',
      );
      rethrow;
    }
  }

  @override
  Future<AccountPaymentMethod> setDefaultPaymentMethod(
    String accountId,
    String paymentMethodId,
    bool payAllUnpaidInvoices,
  ) async {
    try {
      // First, update local cache for immediate UI response
      await _localDataSource.setCachedDefaultPaymentMethod(
        accountId,
        paymentMethodId,
      );

      // Emit updated data immediately
      final cachedMethods = await _localDataSource
          .getCachedAccountPaymentMethods(accountId);
      if (cachedMethods.isNotEmpty) {
        final entities = cachedMethods
            .map((model) => model.toEntity())
            .toList();
        _accountPaymentMethodsController.add(entities);
      }

      // If online, synchronize with remote
      if (await _networkInfo.isConnected) {
        try {
          final remoteMethod = await _remoteDataSource.setDefaultPaymentMethod(
            accountId,
            paymentMethodId,
            payAllUnpaidInvoices,
          );

          // Update local cache with remote response
          await _localDataSource.cacheAccountPaymentMethod(remoteMethod);

          // Emit final updated data
          final finalMethods = await _localDataSource
              .getCachedAccountPaymentMethods(accountId);
          final entities = finalMethods
              .map((model) => model.toEntity())
              .toList();
          _accountPaymentMethodsController.add(entities);

          _logger.d(
            'Set default payment method $paymentMethodId for account: $accountId',
          );
          return remoteMethod.toEntity();
        } catch (e) {
          _logger.w(
            'Remote sync failed for setting default payment method: $e',
          );
          // Return cached data if remote sync fails
          final cachedMethod = await _localDataSource
              .getCachedAccountPaymentMethod(paymentMethodId);
          if (cachedMethod != null) {
            return cachedMethod.toEntity();
          }
          rethrow;
        }
      } else {
        _logger.d(
          'Device offline, updated local cache for default payment method',
        );
        // Return cached data if offline
        final cachedMethod = await _localDataSource
            .getCachedAccountPaymentMethod(paymentMethodId);
        if (cachedMethod != null) {
          return cachedMethod.toEntity();
        }
        throw Exception('Payment method not found in cache');
      }
    } catch (e) {
      _logger.e('Error setting default payment method $paymentMethodId: $e');
      rethrow;
    }
  }

  @override
  Future<AccountPaymentMethod> createPaymentMethod(
    String accountId,
    String paymentMethodType,
    String paymentMethodName,
    Map<String, dynamic> paymentDetails,
  ) async {
    try {
      // If online, create on remote first
      if (await _networkInfo.isConnected) {
        try {
          final remoteMethod = await _remoteDataSource.createPaymentMethod(
            accountId,
            paymentMethodType,
            paymentMethodName,
            paymentDetails,
          );

          // Cache the created payment method locally
          await _localDataSource.cacheAccountPaymentMethod(remoteMethod);

          // Emit updated data
          final cachedMethods = await _localDataSource
              .getCachedAccountPaymentMethods(accountId);
          final entities = cachedMethods
              .map((model) => model.toEntity())
              .toList();
          _accountPaymentMethodsController.add(entities);

          _logger.d(
            'Created payment method ${remoteMethod.id} for account: $accountId',
          );
          return remoteMethod.toEntity();
        } catch (e) {
          _logger.w('Remote creation failed: $e');
          rethrow;
        }
      } else {
        throw Exception('Cannot create payment method while offline');
      }
    } catch (e) {
      _logger.e('Error creating payment method for account $accountId: $e');
      rethrow;
    }
  }

  @override
  Future<AccountPaymentMethod> updatePaymentMethod(
    String accountId,
    String paymentMethodId,
    Map<String, dynamic> updates,
  ) async {
    try {
      // If online, update on remote first
      if (await _networkInfo.isConnected) {
        try {
          final remoteMethod = await _remoteDataSource.updatePaymentMethod(
            accountId,
            paymentMethodId,
            updates,
          );

          // Update local cache
          await _localDataSource.updateCachedPaymentMethod(remoteMethod);

          // Emit updated data
          final cachedMethods = await _localDataSource
              .getCachedAccountPaymentMethods(accountId);
          final entities = cachedMethods
              .map((model) => model.toEntity())
              .toList();
          _accountPaymentMethodsController.add(entities);

          _logger.d(
            'Updated payment method $paymentMethodId for account: $accountId',
          );
          return remoteMethod.toEntity();
        } catch (e) {
          _logger.w('Remote update failed: $e');
          rethrow;
        }
      } else {
        throw Exception('Cannot update payment method while offline');
      }
    } catch (e) {
      _logger.e('Error updating payment method $paymentMethodId: $e');
      rethrow;
    }
  }

  @override
  Future<void> deletePaymentMethod(
    String accountId,
    String paymentMethodId,
  ) async {
    try {
      // If online, delete on remote first
      if (await _networkInfo.isConnected) {
        try {
          await _remoteDataSource.deletePaymentMethod(
            accountId,
            paymentMethodId,
          );

          // Remove from local cache
          await _localDataSource.deleteCachedPaymentMethod(paymentMethodId);

          // Emit updated data
          final cachedMethods = await _localDataSource
              .getCachedAccountPaymentMethods(accountId);
          final entities = cachedMethods
              .map((model) => model.toEntity())
              .toList();
          _accountPaymentMethodsController.add(entities);

          _logger.d(
            'Deleted payment method $paymentMethodId for account: $accountId',
          );
        } catch (e) {
          _logger.w('Remote deletion failed: $e');
          rethrow;
        }
      } else {
        throw Exception('Cannot delete payment method while offline');
      }
    } catch (e) {
      _logger.e('Error deleting payment method $paymentMethodId: $e');
      rethrow;
    }
  }

  @override
  Future<AccountPaymentMethod> deactivatePaymentMethod(
    String accountId,
    String paymentMethodId,
  ) async {
    try {
      // If online, deactivate on remote first
      if (await _networkInfo.isConnected) {
        try {
          final remoteMethod = await _remoteDataSource.deactivatePaymentMethod(
            accountId,
            paymentMethodId,
          );

          // Update local cache
          await _localDataSource.updateCachedPaymentMethod(remoteMethod);

          // Emit updated data
          final cachedMethods = await _localDataSource
              .getCachedAccountPaymentMethods(accountId);
          final entities = cachedMethods
              .map((model) => model.toEntity())
              .toList();
          _accountPaymentMethodsController.add(entities);

          _logger.d(
            'Deactivated payment method $paymentMethodId for account: $accountId',
          );
          return remoteMethod.toEntity();
        } catch (e) {
          _logger.w('Remote deactivation failed: $e');
          rethrow;
        }
      } else {
        throw Exception('Cannot deactivate payment method while offline');
      }
    } catch (e) {
      _logger.e('Error deactivating payment method $paymentMethodId: $e');
      rethrow;
    }
  }

  @override
  Future<AccountPaymentMethod> reactivatePaymentMethod(
    String accountId,
    String paymentMethodId,
  ) async {
    try {
      // If online, reactivate on remote first
      if (await _networkInfo.isConnected) {
        try {
          final remoteMethod = await _remoteDataSource.reactivatePaymentMethod(
            accountId,
            paymentMethodId,
          );

          // Update local cache
          await _localDataSource.updateCachedPaymentMethod(remoteMethod);

          // Emit updated data
          final cachedMethods = await _localDataSource
              .getCachedAccountPaymentMethods(accountId);
          final entities = cachedMethods
              .map((model) => model.toEntity())
              .toList();
          _accountPaymentMethodsController.add(entities);

          _logger.d(
            'Reactivated payment method $paymentMethodId for account: $accountId',
          );
          return remoteMethod.toEntity();
        } catch (e) {
          _logger.w('Remote reactivation failed: $e');
          rethrow;
        }
      } else {
        throw Exception('Cannot reactivate payment method while offline');
      }
    } catch (e) {
      _logger.e('Error reactivating payment method $paymentMethodId: $e');
      rethrow;
    }
  }

  @override
  Future<List<AccountPaymentMethod>> refreshPaymentMethods(
    String accountId,
  ) async {
    try {
      // This method is specifically for refreshing from remote, so require online connection
      if (!await _networkInfo.isConnected) {
        throw Exception('Cannot refresh payment methods while offline');
      }

      try {
        final remoteMethods = await _remoteDataSource.refreshPaymentMethods(
          accountId,
        );

        // Cache the fresh data locally
        await _localDataSource.cacheAccountPaymentMethods(
          accountId,
          remoteMethods,
        );

        // Emit updated data
        final entities = remoteMethods
            .map((model) => model.toEntity())
            .toList();
        _accountPaymentMethodsController.add(entities);

        _logger.d('Refreshed payment methods for account: $accountId');
        return entities;
      } catch (e) {
        _logger.w('Remote refresh failed: $e');
        rethrow;
      }
    } catch (e) {
      _logger.e('Error refreshing payment methods for account $accountId: $e');
      rethrow;
    }
  }

  /// Dispose of the stream controller
  void dispose() {
    _logger.d('🛑 [Account Payment Methods Repository] Disposing resources...');
    if (!_accountPaymentMethodsController.isClosed) {
      _accountPaymentMethodsController.close();
      _logger.i(
        '✅ [Account Payment Methods Repository] StreamController closed',
      );
    }
  }
}
