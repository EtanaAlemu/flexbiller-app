import 'dart:async';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import '../../domain/entities/account_blocking_state.dart';
import '../../domain/repositories/account_blocking_states_repository.dart';
import '../datasources/local/account_blocking_states_local_data_source.dart';
import '../datasources/remote/account_blocking_states_remote_data_source.dart';
import '../../../../core/network/network_info.dart';

@LazySingleton(as: AccountBlockingStatesRepository)
class AccountBlockingStatesRepositoryImpl
    implements AccountBlockingStatesRepository {
  final AccountBlockingStatesLocalDataSource _localDataSource;
  final AccountBlockingStatesRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;
  final Logger _logger = Logger();

  // Stream controllers for reactive UI updates
  final StreamController<List<AccountBlockingState>>
  _blockingStatesStreamController =
      StreamController<List<AccountBlockingState>>.broadcast();
  final StreamController<List<AccountBlockingState>>
  _activeBlockingStatesStreamController =
      StreamController<List<AccountBlockingState>>.broadcast();

  AccountBlockingStatesRepositoryImpl({
    required AccountBlockingStatesLocalDataSource localDataSource,
    required AccountBlockingStatesRemoteDataSource remoteDataSource,
    required NetworkInfo networkInfo,
  }) : _localDataSource = localDataSource,
       _remoteDataSource = remoteDataSource,
       _networkInfo = networkInfo;

  // Stream getters for reactive UI updates
  @override
  Stream<List<AccountBlockingState>> get blockingStatesStream =>
      _blockingStatesStreamController.stream;
  @override
  Stream<List<AccountBlockingState>> get activeBlockingStatesStream =>
      _activeBlockingStatesStreamController.stream;

  @override
  Future<List<AccountBlockingState>> getAccountBlockingStates(
    String accountId,
  ) async {
    try {
      // First, try to get data from local cache
      final cachedBlockingStates = await _localDataSource
          .getCachedBlockingStates(accountId);

      if (cachedBlockingStates.isNotEmpty) {
        // Convert models to entities and add to stream
        final entities = cachedBlockingStates
            .map((model) => model.toEntity())
            .toList();
        _blockingStatesStreamController.add(entities);

        // Start background sync if online
        _syncBlockingStatesInBackground(accountId);

        return entities;
      }

      // If no cached data, check if online and fetch from remote
      if (await _networkInfo.isConnected) {
        final remoteBlockingStates = await _remoteDataSource
            .getAccountBlockingStates(accountId);

        // Cache the remote data
        await _localDataSource.cacheBlockingStates(remoteBlockingStates);

        // Convert to entities and add to stream
        final entities = remoteBlockingStates
            .map((model) => model.toEntity())
            .toList();
        _blockingStatesStreamController.add(entities);

        return entities;
      } else {
        // Offline and no cached data
        throw Exception('No data available offline');
      }
    } catch (e) {
      _logger.e('Error getting account blocking states: $e');
      rethrow;
    }
  }

  @override
  Future<AccountBlockingState> getAccountBlockingState(
    String accountId,
    String stateId,
  ) async {
    try {
      // First, try to get from local cache
      final cachedBlockingState = await _localDataSource.getCachedBlockingState(
        stateId,
      );

      if (cachedBlockingState != null) {
        return cachedBlockingState.toEntity();
      }

      // If not in cache and online, fetch from remote
      if (await _networkInfo.isConnected) {
        final remoteBlockingState = await _remoteDataSource
            .getAccountBlockingState(accountId, stateId);

        // Cache the remote data
        await _localDataSource.cacheBlockingState(remoteBlockingState);

        return remoteBlockingState.toEntity();
      } else {
        throw Exception('No data available offline');
      }
    } catch (e) {
      _logger.e('Error getting account blocking state: $e');
      rethrow;
    }
  }

  @override
  Future<AccountBlockingState> createAccountBlockingState(
    String accountId,
    String stateName,
    String service,
    bool isBlockChange,
    bool isBlockEntitlement,
    bool isBlockBilling,
    DateTime effectiveDate,
    String type,
  ) async {
    try {
      // Create locally first for immediate response
      final blockingStateModel = await _remoteDataSource
          .createAccountBlockingState(
            accountId,
            stateName,
            service,
            isBlockChange,
            isBlockEntitlement,
            isBlockBilling,
            effectiveDate,
            type,
          );

      // Cache the created blocking state
      await _localDataSource.cacheBlockingState(blockingStateModel);

      // Add to stream for reactive UI update
      final entity = blockingStateModel.toEntity();
      _blockingStatesStreamController.add([entity]);

      return entity;
    } catch (e) {
      _logger.e('Error creating account blocking state: $e');
      rethrow;
    }
  }

  @override
  Future<AccountBlockingState> updateAccountBlockingState(
    String accountId,
    String stateId,
    String stateName,
    String service,
    bool isBlockChange,
    bool isBlockEntitlement,
    bool isBlockBilling,
    DateTime effectiveDate,
  ) async {
    try {
      // Update remotely
      final updatedBlockingStateModel = await _remoteDataSource
          .updateAccountBlockingState(
            accountId,
            stateId,
            stateName,
            service,
            isBlockChange,
            isBlockEntitlement,
            isBlockBilling,
            effectiveDate,
          );

      // Update local cache
      await _localDataSource.updateCachedBlockingState(
        updatedBlockingStateModel,
      );

      // Add to stream for reactive UI update
      final entity = updatedBlockingStateModel.toEntity();
      _blockingStatesStreamController.add([entity]);

      return entity;
    } catch (e) {
      _logger.e('Error updating account blocking state: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteAccountBlockingState(
    String accountId,
    String stateId,
  ) async {
    try {
      // Delete remotely
      await _remoteDataSource.deleteAccountBlockingState(accountId, stateId);

      // Remove from local cache
      await _localDataSource.deleteCachedBlockingState(stateId);

      // Refresh stream to reflect deletion
      final remainingBlockingStates = await _localDataSource
          .getCachedBlockingStates(accountId);
      final entities = remainingBlockingStates
          .map((model) => model.toEntity())
          .toList();
      _blockingStatesStreamController.add(entities);
    } catch (e) {
      _logger.e('Error deleting account blocking state: $e');
      rethrow;
    }
  }

  @override
  Future<List<AccountBlockingState>> getBlockingStatesByService(
    String accountId,
    String service,
  ) async {
    try {
      // First, try to get from local cache
      final cachedBlockingStates = await _localDataSource
          .getCachedBlockingStatesByService(accountId, service);

      if (cachedBlockingStates.isNotEmpty) {
        final entities = cachedBlockingStates
            .map((model) => model.toEntity())
            .toList();

        // Start background sync if online
        _syncBlockingStatesInBackground(accountId);

        return entities;
      }

      // If no cached data and online, fetch from remote
      if (await _networkInfo.isConnected) {
        final remoteBlockingStates = await _remoteDataSource
            .getBlockingStatesByService(accountId, service);

        // Cache the remote data
        await _localDataSource.cacheBlockingStates(remoteBlockingStates);

        return remoteBlockingStates.map((model) => model.toEntity()).toList();
      } else {
        throw Exception('No data available offline');
      }
    } catch (e) {
      _logger.e('Error getting blocking states by service: $e');
      rethrow;
    }
  }

  @override
  Future<List<AccountBlockingState>> getActiveBlockingStates(
    String accountId,
  ) async {
    try {
      // First, try to get from local cache
      final cachedActiveBlockingStates = await _localDataSource
          .getCachedActiveBlockingStates(accountId);

      if (cachedActiveBlockingStates.isNotEmpty) {
        final entities = cachedActiveBlockingStates
            .map((model) => model.toEntity())
            .toList();

        // Add to active blocking states stream
        _activeBlockingStatesStreamController.add(entities);

        // Start background sync if online
        _syncActiveBlockingStatesInBackground(accountId);

        return entities;
      }

      // If no cached data and online, fetch from remote
      if (await _networkInfo.isConnected) {
        final remoteActiveBlockingStates = await _remoteDataSource
            .getActiveBlockingStates(accountId);

        // Cache the remote data
        await _localDataSource.cacheBlockingStates(remoteActiveBlockingStates);

        final entities = remoteActiveBlockingStates
            .map((model) => model.toEntity())
            .toList();

        // Add to active blocking states stream
        _activeBlockingStatesStreamController.add(entities);

        return entities;
      } else {
        throw Exception('No data available offline');
      }
    } catch (e) {
      _logger.e('Error getting active blocking states: $e');
      rethrow;
    }
  }

  /// Background synchronization method for blocking states
  Future<void> _syncBlockingStatesInBackground(String accountId) async {
    try {
      if (await _networkInfo.isConnected) {
        final remoteBlockingStates = await _remoteDataSource
            .getAccountBlockingStates(accountId);

        // Update local cache
        await _localDataSource.cacheBlockingStates(remoteBlockingStates);

        // Convert to entities and add to stream for reactive UI update
        final entities = remoteBlockingStates
            .map((model) => model.toEntity())
            .toList();
        _blockingStatesStreamController.add(entities);

        _logger.d(
          'Background sync completed for account blocking states: $accountId',
        );
      }
    } catch (e) {
      _logger.w('Background sync failed for account blocking states: $e');
    }
  }

  /// Background synchronization method for active blocking states
  Future<void> _syncActiveBlockingStatesInBackground(String accountId) async {
    try {
      if (await _networkInfo.isConnected) {
        final remoteActiveBlockingStates = await _remoteDataSource
            .getActiveBlockingStates(accountId);

        // Update local cache
        await _localDataSource.cacheBlockingStates(remoteActiveBlockingStates);

        // Convert to entities and add to stream for reactive UI update
        final entities = remoteActiveBlockingStates
            .map((model) => model.toEntity())
            .toList();
        _activeBlockingStatesStreamController.add(entities);

        _logger.d(
          'Background sync completed for active blocking states: $accountId',
        );
      }
    } catch (e) {
      _logger.w('Background sync failed for active blocking states: $e');
    }
  }

  /// Dispose method to clean up stream controllers
  void dispose() {
    _logger.d('🛑 [Account Blocking States Repository] Disposing resources...');
    if (!_blockingStatesStreamController.isClosed) {
      _blockingStatesStreamController.close();
    }
    if (!_activeBlockingStatesStreamController.isClosed) {
      _activeBlockingStatesStreamController.close();
    }
    _logger.i(
      '✅ [Account Blocking States Repository] All StreamControllers closed',
    );
  }
}
