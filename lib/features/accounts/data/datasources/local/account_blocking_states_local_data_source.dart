import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import '../../../../../core/dao/account_blocking_state_dao.dart';
import '../../../../../core/services/database_service.dart';
import '../../models/account_blocking_state_model.dart';

abstract class AccountBlockingStatesLocalDataSource {
  Future<void> cacheBlockingStates(
    List<AccountBlockingStateModel> blockingStates,
  );
  Future<void> cacheBlockingState(AccountBlockingStateModel blockingState);
  Future<List<AccountBlockingStateModel>> getCachedBlockingStates(
    String accountId,
  );
  Future<AccountBlockingStateModel?> getCachedBlockingState(
    String blockingStateId,
  );
  Future<List<AccountBlockingStateModel>> getCachedBlockingStatesByState(
    String accountId,
    String state,
  );
  Future<List<AccountBlockingStateModel>> getCachedActiveBlockingStates(
    String accountId,
  );
  Future<List<AccountBlockingStateModel>> getCachedBlockingStatesByService(
    String accountId,
    String service,
  );
  Future<List<AccountBlockingStateModel>> getCachedBlockingStatesByDateRange(
    String accountId,
    DateTime startDate,
    DateTime endDate,
  );
  Future<List<AccountBlockingStateModel>> getCachedBlockingStatesWithPagination(
    String accountId,
    int page,
    int pageSize,
  );
  Future<List<AccountBlockingStateModel>> searchCachedBlockingStates(
    String accountId,
    String searchTerm,
  );
  Future<int> getCachedBlockingStatesCount(String accountId);
  Future<int> getCachedActiveBlockingStatesCount(String accountId);
  Future<void> updateCachedBlockingState(
    AccountBlockingStateModel blockingState,
  );
  Future<void> deleteCachedBlockingState(String blockingStateId);
  Future<void> deleteCachedBlockingStatesByAccount(String accountId);
  Future<void> clearAllCachedBlockingStates();
  Future<bool> hasCachedBlockingStates(String accountId);
}

@Injectable(as: AccountBlockingStatesLocalDataSource)
class AccountBlockingStatesLocalDataSourceImpl
    implements AccountBlockingStatesLocalDataSource {
  final DatabaseService _databaseService;
  final Logger _logger = Logger();

  AccountBlockingStatesLocalDataSourceImpl(this._databaseService);

  @override
  Future<void> cacheBlockingStates(
    List<AccountBlockingStateModel> blockingStates,
  ) async {
    try {
      final db = await _databaseService.database;
      await AccountBlockingStateDao.insertMultipleBlockingStates(
        db,
        blockingStates,
      );
      _logger.d('Cached ${blockingStates.length} blocking states successfully');
    } catch (e) {
      _logger.e('Error caching blocking states: $e');
      rethrow;
    }
  }

  @override
  Future<void> cacheBlockingState(
    AccountBlockingStateModel blockingState,
  ) async {
    try {
      final db = await _databaseService.database;
      await AccountBlockingStateDao.insertBlockingState(db, blockingState);
      _logger.d(
        'Cached blocking state: ${blockingState.stateName} for service: ${blockingState.service} successfully',
      );
    } catch (e) {
      _logger.e(
        'Error caching blocking state: ${blockingState.stateName} - $e',
      );
      rethrow;
    }
  }

  @override
  Future<List<AccountBlockingStateModel>> getCachedBlockingStates(
    String accountId,
  ) async {
    try {
      final db = await _databaseService.database;
      final blockingStates =
          await AccountBlockingStateDao.getBlockingStatesByAccount(
            db,
            accountId,
          );
      _logger.d(
        'Retrieved ${blockingStates.length} cached blocking states for account: $accountId',
      );
      return blockingStates;
    } catch (e) {
      _logger.w(
        'Error retrieving cached blocking states for account: $accountId - $e',
      );
      // Return empty list if there's an error (e.g., table doesn't exist yet)
      return [];
    }
  }

  @override
  Future<AccountBlockingStateModel?> getCachedBlockingState(
    String blockingStateId,
  ) async {
    try {
      final db = await _databaseService.database;
      final blockingState = await AccountBlockingStateDao.getBlockingStateById(
        db,
        blockingStateId,
      );

      if (blockingState != null) {
        _logger.d('Retrieved cached blocking state: $blockingStateId');
        return blockingState;
      }

      _logger.d('No cached blocking state found for: $blockingStateId');
      return null;
    } catch (e) {
      _logger.w(
        'Error retrieving cached blocking state: $blockingStateId - $e',
      );
      return null;
    }
  }

  @override
  Future<List<AccountBlockingStateModel>> getCachedBlockingStatesByState(
    String accountId,
    String state,
  ) async {
    try {
      final db = await _databaseService.database;
      final blockingStates =
          await AccountBlockingStateDao.getBlockingStatesByState(
            db,
            accountId,
            state,
          );
      _logger.d(
        'Retrieved ${blockingStates.length} cached blocking states by state: $state for account: $accountId',
      );
      return blockingStates;
    } catch (e) {
      _logger.w(
        'Error retrieving cached blocking states by state for account: $accountId, state: $state - $e',
      );
      return [];
    }
  }

  @override
  Future<List<AccountBlockingStateModel>> getCachedActiveBlockingStates(
    String accountId,
  ) async {
    try {
      final db = await _databaseService.database;
      final blockingStates =
          await AccountBlockingStateDao.getActiveBlockingStates(db, accountId);
      _logger.d(
        'Retrieved ${blockingStates.length} cached active blocking states for account: $accountId',
      );
      return blockingStates;
    } catch (e) {
      _logger.w(
        'Error retrieving cached active blocking states for account: $accountId - $e',
      );
      return [];
    }
  }

  @override
  Future<List<AccountBlockingStateModel>> getCachedBlockingStatesByService(
    String accountId,
    String service,
  ) async {
    try {
      final db = await _databaseService.database;
      final blockingStates =
          await AccountBlockingStateDao.getBlockingStatesByService(
            db,
            accountId,
            service,
          );
      _logger.d(
        'Retrieved ${blockingStates.length} cached blocking states by service: $service for account: $accountId',
      );
      return blockingStates;
    } catch (e) {
      _logger.w(
        'Error retrieving cached blocking states by service for account: $accountId, service: $service - $e',
      );
      return [];
    }
  }

  @override
  Future<List<AccountBlockingStateModel>> getCachedBlockingStatesByDateRange(
    String accountId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final db = await _databaseService.database;
      final blockingStates =
          await AccountBlockingStateDao.getBlockingStatesByDateRange(
            db,
            accountId,
            startDate,
            endDate,
          );
      _logger.d(
        'Retrieved ${blockingStates.length} cached blocking states by date range for account: $accountId',
      );
      return blockingStates;
    } catch (e) {
      _logger.w(
        'Error retrieving cached blocking states by date range for account: $accountId - $e',
      );
      return [];
    }
  }

  @override
  Future<List<AccountBlockingStateModel>> getCachedBlockingStatesWithPagination(
    String accountId,
    int page,
    int pageSize,
  ) async {
    try {
      final db = await _databaseService.database;
      final offset = page * pageSize;
      final blockingStates =
          await AccountBlockingStateDao.getBlockingStatesWithPagination(
            db,
            accountId,
            offset,
            pageSize,
          );
      _logger.d(
        'Retrieved ${blockingStates.length} cached blocking states with pagination for account: $accountId (page: $page, size: $pageSize)',
      );
      return blockingStates;
    } catch (e) {
      _logger.w(
        'Error retrieving cached blocking states with pagination for account: $accountId - $e',
      );
      return [];
    }
  }

  @override
  Future<List<AccountBlockingStateModel>> searchCachedBlockingStates(
    String accountId,
    String searchTerm,
  ) async {
    try {
      final db = await _databaseService.database;
      final blockingStates = await AccountBlockingStateDao.searchBlockingStates(
        db,
        accountId,
        searchTerm,
      );
      _logger.d(
        'Retrieved ${blockingStates.length} cached blocking states by search term: $searchTerm for account: $accountId',
      );
      return blockingStates;
    } catch (e) {
      _logger.w(
        'Error searching cached blocking states for account: $accountId, searchTerm: $searchTerm - $e',
      );
      return [];
    }
  }

  @override
  Future<int> getCachedBlockingStatesCount(String accountId) async {
    try {
      final db = await _databaseService.database;
      final count = await AccountBlockingStateDao.getBlockingStatesCount(
        db,
        accountId,
      );
      _logger.d(
        'Retrieved cached blocking states count: $count for account: $accountId',
      );
      return count;
    } catch (e) {
      _logger.w(
        'Error retrieving cached blocking states count for account: $accountId - $e',
      );
      return 0;
    }
  }

  @override
  Future<int> getCachedActiveBlockingStatesCount(String accountId) async {
    try {
      final db = await _databaseService.database;
      final count = await AccountBlockingStateDao.getActiveBlockingStatesCount(
        db,
        accountId,
      );
      _logger.d(
        'Retrieved cached active blocking states count: $count for account: $accountId',
      );
      return count;
    } catch (e) {
      _logger.w(
        'Error retrieving cached active blocking states count for account: $accountId - $e',
      );
      return 0;
    }
  }

  @override
  Future<void> updateCachedBlockingState(
    AccountBlockingStateModel blockingState,
  ) async {
    try {
      final db = await _databaseService.database;
      await AccountBlockingStateDao.updateBlockingState(db, blockingState);
      _logger.d(
        'Updated cached blocking state: ${blockingState.stateName} for service: ${blockingState.service} successfully',
      );
    } catch (e) {
      _logger.e(
        'Error updating cached blocking state: ${blockingState.stateName} - $e',
      );
      rethrow;
    }
  }

  @override
  Future<void> deleteCachedBlockingState(String blockingStateId) async {
    try {
      final db = await _databaseService.database;
      await AccountBlockingStateDao.deleteBlockingState(db, blockingStateId);
      _logger.d('Deleted cached blocking state: $blockingStateId successfully');
    } catch (e) {
      _logger.e('Error deleting cached blocking state: $blockingStateId - $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteCachedBlockingStatesByAccount(String accountId) async {
    try {
      final db = await _databaseService.database;
      await AccountBlockingStateDao.deleteBlockingStatesByAccount(
        db,
        accountId,
      );
      _logger.d(
        'Deleted cached blocking states for account: $accountId successfully',
      );
    } catch (e) {
      _logger.e(
        'Error deleting cached blocking states for account: $accountId - $e',
      );
      rethrow;
    }
  }

  @override
  Future<void> clearAllCachedBlockingStates() async {
    try {
      final db = await _databaseService.database;
      await AccountBlockingStateDao.clearAllBlockingStates(db);
      _logger.d('Cleared all cached blocking states successfully');
    } catch (e) {
      _logger.e('Error clearing cached blocking states: $e');
      rethrow;
    }
  }

  @override
  Future<bool> hasCachedBlockingStates(String accountId) async {
    try {
      final db = await _databaseService.database;
      final count = await AccountBlockingStateDao.getBlockingStatesCount(
        db,
        accountId,
      );
      return count > 0;
    } catch (e) {
      _logger.e(
        'Error checking if cached blocking states exist for account: $accountId - $e',
      );
      // If table doesn't exist, return false instead of throwing
      if (e.toString().contains('no such table: account_blocking_states')) {
        _logger.w(
          'Account blocking states table does not exist yet, returning false',
        );
        return false;
      }
      rethrow;
    }
  }
}
