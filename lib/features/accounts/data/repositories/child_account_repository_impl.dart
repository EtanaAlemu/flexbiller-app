import 'dart:async';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/child_account.dart';
import '../../domain/repositories/child_account_repository.dart';
import '../datasources/remote/child_account_remote_data_source.dart';
import '../datasources/local/child_account_local_data_source.dart';
import '../models/child_account_model.dart';

@Injectable(as: ChildAccountRepository)
class ChildAccountRepositoryImpl implements ChildAccountRepository {
  final ChildAccountRemoteDataSource _remoteDataSource;
  final ChildAccountLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;
  final Logger _logger = Logger();

  // Stream controllers for reactive UI updates
  final StreamController<List<ChildAccount>> _childAccountsStreamController =
      StreamController<List<ChildAccount>>.broadcast();
  final StreamController<ChildAccount> _childAccountStreamController =
      StreamController<ChildAccount>.broadcast();

  ChildAccountRepositoryImpl({
    required ChildAccountRemoteDataSource remoteDataSource,
    required ChildAccountLocalDataSource localDataSource,
    required NetworkInfo networkInfo,
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource,
       _networkInfo = networkInfo;

  // Stream getters for reactive UI updates
  Stream<List<ChildAccount>> get childAccountsStream =>
      _childAccountsStreamController.stream;
  Stream<ChildAccount> get childAccountStream =>
      _childAccountStreamController.stream;

  @override
  Future<ChildAccount> createChildAccount(ChildAccount childAccount) async {
    try {
      final childAccountModel = ChildAccountModel.fromEntity(childAccount);

      // Check if we're online before attempting to create child account
      if (!await _networkInfo.isConnected) {
        throw NetworkException(
          'No network connection available. Please check your internet connection and try again.',
        );
      }

      _logger.d(
        'Creating child account on remote server: ${childAccountModel.email}',
      );

      // Create child account on remote server first and wait for response
      final remoteChildAccount = await _remoteDataSource.createChildAccount(
        childAccountModel,
      );
      _logger.d(
        'Child account created successfully on remote server: ${remoteChildAccount.email}',
      );

      // Save the remote response to local cache
      await _localDataSource.cacheChildAccount(remoteChildAccount);
      _logger.d(
        'Child account saved to local cache: ${remoteChildAccount.email}',
      );

      // Emit updated list for UI refresh
      final updatedChildAccounts = await _localDataSource
          .getCachedChildAccountsByParent(childAccount.parentAccountId);
      final entities = updatedChildAccounts
          .map((model) => model.toEntity())
          .toList();
      _childAccountsStreamController.add(entities);

      return remoteChildAccount.toEntity();
    } on ValidationException catch (e) {
      _logger.e('Validation error while creating child account: ${e.message}');
      rethrow;
    } on ServerException catch (e) {
      _logger.e('Server error while creating child account: ${e.message}');
      rethrow;
    } on NetworkException catch (e) {
      _logger.e('Network error while creating child account: ${e.message}');
      rethrow;
    } on AuthException catch (e) {
      _logger.e('Auth error while creating child account: ${e.message}');
      rethrow;
    } catch (e) {
      _logger.e('Error creating child account: $e');
      rethrow;
    }
  }

  // Background synchronization method for fetching child accounts
  Future<void> _syncChildAccountsInBackground(String parentAccountId) async {
    try {
      _logger.d(
        'Syncing child accounts in background for parent: $parentAccountId',
      );
      final remoteChildAccounts = await _remoteDataSource.getChildAccounts(
        parentAccountId,
      );

      // Update local cache with fresh data from server
      await _localDataSource.cacheChildAccounts(remoteChildAccounts);

      // 🔥 KEY: Update UI with fresh data via stream
      final freshChildAccounts = remoteChildAccounts
          .map((model) => model.toEntity())
          .toList();
      _childAccountsStreamController.add(freshChildAccounts);

      _logger.d(
        'Synced ${remoteChildAccounts.length} child accounts for parent: $parentAccountId - UI updated with fresh data',
      );
    } catch (e) {
      _logger.w(
        'Background sync failed for child accounts of parent $parentAccountId: $e',
      );
      // Don't rethrow - background sync failures shouldn't affect main flow
    }
  }

  @override
  Future<List<ChildAccount>> getChildAccounts(String parentAccountId) async {
    try {
      // 1. IMMEDIATELY return cached data from local database (Local-First)
      final cachedChildAccounts = await _localDataSource
          .getCachedChildAccountsByParent(parentAccountId);
      _logger.d(
        'Returning ${cachedChildAccounts.length} cached child accounts for parent: $parentAccountId',
      );

      // 2. Convert to domain entities for immediate UI update
      final localChildAccounts = cachedChildAccounts
          .map((model) => model.toEntity())
          .toList();

      // 3. Attempt remote sync in background if online
      if (await _networkInfo.isConnected) {
        _syncChildAccountsInBackground(parentAccountId);
      }

      return localChildAccounts;
    } catch (e) {
      _logger.e('Error getting cached child accounts: $e');
      rethrow;
    }
  }

  // Clean up stream controllers
  void dispose() {
    _logger.d('🛑 [Child Account Repository] Disposing resources...');
    if (!_childAccountsStreamController.isClosed) {
      _childAccountsStreamController.close();
    }
    if (!_childAccountStreamController.isClosed) {
      _childAccountStreamController.close();
    }
    _logger.i('✅ [Child Account Repository] All StreamControllers closed');
  }
}
