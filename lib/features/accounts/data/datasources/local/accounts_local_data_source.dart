import 'dart:async';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import '../../../../../core/dao/account_dao.dart';
import '../../../../../core/services/database_service.dart';
import '../../../../../core/services/user_session_service.dart';
import '../../models/account_model.dart';
import '../../../domain/entities/accounts_query_params.dart';

abstract class AccountsLocalDataSource {
  Future<void> cacheAccounts(List<AccountModel> accounts);
  Future<List<AccountModel>> getCachedAccounts();
  Future<AccountModel?> getCachedAccountById(String accountId);
  Future<List<AccountModel>> searchCachedAccounts(String searchKey);
  Future<void> cacheAccount(AccountModel account);
  Future<void> updateCachedAccount(AccountModel account);
  Future<void> deleteCachedAccount(String accountId);
  Future<void> clearAllCachedAccounts();
  Future<bool> hasCachedAccounts();
  Future<int> getCachedAccountsCount();
  Future<List<AccountModel>> getCachedAccountsByQuery(
    AccountsQueryParams params,
  );

  // Reactive stream methods for real-time updates
  Stream<List<AccountModel>> watchAccounts();
  Stream<AccountModel?> watchAccountById(String accountId);
  Stream<List<AccountModel>> watchAccountsByQuery(AccountsQueryParams params);
  Stream<List<AccountModel>> watchSearchResults(String searchKey);
}

@Injectable(as: AccountsLocalDataSource)
class AccountsLocalDataSourceImpl implements AccountsLocalDataSource {
  final DatabaseService _databaseService;
  final UserSessionService _userSessionService;
  final Logger _logger = Logger();

  // Stream controllers for reactive updates
  final StreamController<List<AccountModel>> _accountsStreamController =
      StreamController<List<AccountModel>>.broadcast();
  final StreamController<Map<String, AccountModel>>
  _accountByIdStreamController =
      StreamController<Map<String, AccountModel>>.broadcast();
  final StreamController<Map<String, List<AccountModel>>>
  _queryStreamController =
      StreamController<Map<String, List<AccountModel>>>.broadcast();
  final StreamController<Map<String, List<AccountModel>>>
  _searchStreamController =
      StreamController<Map<String, List<AccountModel>>>.broadcast();

  AccountsLocalDataSourceImpl(this._databaseService, this._userSessionService);

  @override
  Future<void> cacheAccounts(List<AccountModel> accounts) async {
    try {
      var currentUserId = _userSessionService.getCurrentUserIdOrNull();
      if (currentUserId == null) {
        _logger.w('No active user context, attempting to restore user context');

        // Try to restore user context from stored data
        try {
          await _userSessionService.restoreCurrentUserContext();
          currentUserId = _userSessionService.getCurrentUserIdOrNull();

          if (currentUserId == null) {
            _logger.w(
              'Failed to restore user context, skipping account caching',
            );
            return;
          } else {
            _logger.i('User context restored successfully: $currentUserId');
          }
        } catch (e) {
          _logger.e('Error restoring user context: $e');
          return;
        }
      }

      // If we have a user ID, proceed even if hasActiveUser is false
      // This handles the case where the user ID is restored but the full user object is not loaded
      if (currentUserId != null) {
        _logger.d('Using restored user ID: $currentUserId');
      }

      final db = await _databaseService.database;
      for (final account in accounts) {
        await AccountDao.insertOrUpdate(db, account, userId: currentUserId);
      }
      _logger.d(
        'Cached ${accounts.length} accounts successfully for user: $currentUserId',
      );

      // Emit to streams for reactive updates
      _emitAccountsUpdate();
    } catch (e) {
      _logger.e('Error caching accounts: $e');
      rethrow;
    }
  }

  @override
  Future<List<AccountModel>> getCachedAccounts() async {
    try {
      final currentUserId = _userSessionService.getCurrentUserIdOrNull();
      if (currentUserId == null) {
        _logger.w('No active user context, returning empty accounts list');
        return [];
      }

      final db = await _databaseService.database;
      return await AccountDao.getAll(
        db,
        orderBy: 'name ASC',
        userId: currentUserId,
      );
    } catch (e) {
      _logger.e('Error getting cached accounts: $e');

      // If table doesn't exist, return empty list instead of throwing
      if (e.toString().contains('no such table: accounts')) {
        _logger.w('Accounts table does not exist yet, returning empty list');
        return [];
      }

      rethrow;
    }
  }

  @override
  Future<AccountModel?> getCachedAccountById(String accountId) async {
    try {
      // Check for user context and restore if needed
      var currentUserId = _userSessionService.getCurrentUserIdOrNull();
      if (currentUserId == null) {
        _logger.w('No active user context, attempting to restore user context');
        try {
          await _userSessionService.restoreCurrentUserContext();
          currentUserId = _userSessionService.getCurrentUserIdOrNull();
          if (currentUserId == null) {
            _logger.w(
              'Failed to restore user context, returning null for account: $accountId',
            );
            return null;
          } else {
            _logger.i('User context restored successfully: $currentUserId');
          }
        } catch (e) {
          _logger.e('Error restoring user context: $e');
          return null;
        }
      }
      // If we have a user ID, proceed even if hasActiveUser is false
      if (currentUserId != null) {
        _logger.d('Using restored user ID: $currentUserId');
      }

      final db = await _databaseService.database;
      final account = await AccountDao.getById(db, accountId);

      // Verify the account belongs to the current user
      if (account != null && account.userId != currentUserId) {
        _logger.w(
          'Account $accountId does not belong to current user $currentUserId',
        );
        return null;
      }

      return account;
    } catch (e) {
      _logger.e('Error getting cached account by ID: $e');
      rethrow;
    }
  }

  @override
  Future<List<AccountModel>> searchCachedAccounts(String searchKey) async {
    try {
      // Check for user context and restore if needed
      var currentUserId = _userSessionService.getCurrentUserIdOrNull();
      if (currentUserId == null) {
        _logger.w('No active user context, attempting to restore user context');
        try {
          await _userSessionService.restoreCurrentUserContext();
          currentUserId = _userSessionService.getCurrentUserIdOrNull();
          if (currentUserId == null) {
            _logger.w(
              'Failed to restore user context, returning empty search results',
            );
            return [];
          } else {
            _logger.i('User context restored successfully: $currentUserId');
          }
        } catch (e) {
          _logger.e('Error restoring user context: $e');
          return [];
        }
      }
      // If we have a user ID, proceed even if hasActiveUser is false
      if (currentUserId != null) {
        _logger.d('Using restored user ID: $currentUserId');
      }

      final db = await _databaseService.database;
      return await AccountDao.search(db, searchKey, userId: currentUserId);
    } catch (e) {
      _logger.e('Error searching cached accounts: $e');
      rethrow;
    }
  }

  @override
  Future<void> cacheAccount(AccountModel account) async {
    try {
      // Check for user context and restore if needed
      var currentUserId = _userSessionService.getCurrentUserIdOrNull();
      if (currentUserId == null) {
        _logger.w('No active user context, attempting to restore user context');
        try {
          await _userSessionService.restoreCurrentUserContext();
          currentUserId = _userSessionService.getCurrentUserIdOrNull();
          if (currentUserId == null) {
            _logger.w(
              'Failed to restore user context, skipping account caching: ${account.accountId}',
            );
            return;
          } else {
            _logger.i('User context restored successfully: $currentUserId');
          }
        } catch (e) {
          _logger.e('Error restoring user context: $e');
          return;
        }
      }
      // If we have a user ID, proceed even if hasActiveUser is false
      if (currentUserId != null) {
        _logger.d('Using restored user ID: $currentUserId');
      }

      final db = await _databaseService.database;
      await AccountDao.insertOrUpdate(db, account, userId: currentUserId);
      _logger.d(
        'Cached account successfully: ${account.accountId} for user: $currentUserId',
      );

      // Emit only individual account update, not accounts list update
      _emitAccountUpdate(account);
    } catch (e) {
      _logger.e('Error caching account: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateCachedAccount(AccountModel account) async {
    try {
      // Check for user context and restore if needed
      var currentUserId = _userSessionService.getCurrentUserIdOrNull();
      if (currentUserId == null) {
        _logger.w('No active user context, attempting to restore user context');
        try {
          await _userSessionService.restoreCurrentUserContext();
          currentUserId = _userSessionService.getCurrentUserIdOrNull();
          if (currentUserId == null) {
            _logger.w(
              'Failed to restore user context, skipping account update: ${account.accountId}',
            );
            return;
          } else {
            _logger.i('User context restored successfully: $currentUserId');
          }
        } catch (e) {
          _logger.e('Error restoring user context: $e');
          return;
        }
      }
      // If we have a user ID, proceed even if hasActiveUser is false
      if (currentUserId != null) {
        _logger.d('Using restored user ID: $currentUserId');
      }

      final db = await _databaseService.database;
      await AccountDao.insertOrUpdate(db, account, userId: currentUserId);
      _logger.d(
        'Updated cached account: ${account.accountId} for user: $currentUserId',
      );

      // Emit only individual account update, not accounts list update
      _emitAccountUpdate(account);
    } catch (e) {
      _logger.e('Error updating cached account: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteCachedAccount(String accountId) async {
    try {
      // Check for user context and restore if needed
      var currentUserId = _userSessionService.getCurrentUserIdOrNull();
      if (currentUserId == null) {
        _logger.w('No active user context, attempting to restore user context');
        try {
          await _userSessionService.restoreCurrentUserContext();
          currentUserId = _userSessionService.getCurrentUserIdOrNull();
          if (currentUserId == null) {
            _logger.w(
              'Failed to restore user context, skipping account deletion: $accountId',
            );
            return;
          } else {
            _logger.i('User context restored successfully: $currentUserId');
          }
        } catch (e) {
          _logger.e('Error restoring user context: $e');
          return;
        }
      }
      // If we have a user ID, proceed even if hasActiveUser is false
      if (currentUserId != null) {
        _logger.d('Using restored user ID: $currentUserId');
      }

      final db = await _databaseService.database;

      // Verify the account belongs to the current user before deleting
      final account = await AccountDao.getById(db, accountId);
      if (account != null && account.userId != currentUserId) {
        _logger.w(
          'Cannot delete account $accountId - does not belong to current user $currentUserId',
        );
        return;
      }

      await AccountDao.deleteById(db, accountId);
      _logger.d('Deleted cached account: $accountId for user: $currentUserId');

      // Emit only individual account deletion, not accounts list update
      _emitAccountDeletion(accountId);
    } catch (e) {
      _logger.e('Error deleting cached account: $e');
      rethrow;
    }
  }

  @override
  Future<void> clearAllCachedAccounts() async {
    try {
      final currentUserId = _userSessionService.getCurrentUserIdOrNull();
      if (currentUserId == null) {
        _logger.w('No active user context, skipping clearing all accounts');
        return;
      }
      final db = await _databaseService.database;

      // Only clear accounts for the current user
      await db.delete(
        'accounts',
        where: 'user_id = ?',
        whereArgs: [currentUserId],
      );
      _logger.d('Cleared all cached accounts for user: $currentUserId');

      // Emit to streams for reactive updates
      _emitAccountsUpdate();
    } catch (e) {
      _logger.e('Error clearing cached accounts: $e');
      rethrow;
    }
  }

  @override
  Future<bool> hasCachedAccounts() async {
    try {
      final currentUserId = _userSessionService.getCurrentUserIdOrNull();
      if (currentUserId == null) {
        _logger.w(
          'No active user context, returning false for hasCachedAccounts',
        );
        return false;
      }
      final db = await _databaseService.database;
      return await AccountDao.hasAccounts(db, userId: currentUserId);
    } catch (e) {
      _logger.e('Error checking if has cached accounts: $e');
      return false;
    }
  }

  @override
  Future<int> getCachedAccountsCount() async {
    try {
      final currentUserId = _userSessionService.getCurrentUserIdOrNull();
      if (currentUserId == null) {
        _logger.w('No active user context, returning 0 for accounts count');
        return 0;
      }
      final db = await _databaseService.database;
      return await AccountDao.getCount(db, userId: currentUserId);
    } catch (e) {
      _logger.e('Error getting cached accounts count: $e');
      return 0;
    }
  }

  @override
  Future<List<AccountModel>> getCachedAccountsByQuery(
    AccountsQueryParams params,
  ) async {
    try {
      var currentUserId = _userSessionService.getCurrentUserIdOrNull();
      if (currentUserId == null) {
        _logger.w('No active user context, attempting to restore user context');

        // Try to restore user context from stored data
        try {
          await _userSessionService.restoreCurrentUserContext();
          currentUserId = _userSessionService.getCurrentUserIdOrNull();

          if (currentUserId == null) {
            _logger.w(
              'Failed to restore user context, returning empty accounts list',
            );
            return [];
          } else {
            _logger.i('User context restored successfully: $currentUserId');
          }
        } catch (e) {
          _logger.e('Error restoring user context: $e');
          return [];
        }
      }

      // If we have a user ID, proceed even if hasActiveUser is false
      // This handles the case where the user ID is restored but the full user object is not loaded
      if (currentUserId != null) {
        _logger.d('Using restored user ID: $currentUserId');
      }

      _logger.d(
        '🔍 DEBUG: getCachedAccountsByQuery called with params: ${params.toString()} for user: $currentUserId',
      );
      final db = await _databaseService.database;
      final orderBy = '${params.sortBy} ${params.sortOrder}';
      _logger.d(
        '🔍 DEBUG: Query orderBy: $orderBy, limit: ${params.limit}, offset: ${params.offset}',
      );

      final result = await AccountDao.getByQuery(
        db,
        limit: params.limit,
        offset: params.offset,
        orderBy: orderBy,
        userId: currentUserId,
      );

      _logger.d(
        '🔍 DEBUG: AccountDao.getByQuery returned ${result.length} accounts for user: $currentUserId',
      );
      return result;
    } catch (e) {
      _logger.e('Error getting cached accounts by query: $e');

      // If table doesn't exist, return empty list instead of throwing
      if (e.toString().contains('no such table: accounts')) {
        _logger.w('Accounts table does not exist yet, returning empty list');
        return [];
      }

      rethrow;
    }
  }

  // Stream implementations for reactive updates
  @override
  Stream<List<AccountModel>> watchAccounts() {
    return _accountsStreamController.stream;
  }

  @override
  Stream<AccountModel?> watchAccountById(String accountId) {
    return _accountByIdStreamController.stream
        .map((accountMap) => accountMap[accountId])
        .distinct();
  }

  @override
  Stream<List<AccountModel>> watchAccountsByQuery(AccountsQueryParams params) {
    final queryKey = _getQueryKey(params);
    return _queryStreamController.stream
        .map((queryMap) => queryMap[queryKey] ?? [])
        .distinct();
  }

  @override
  Stream<List<AccountModel>> watchSearchResults(String searchKey) {
    return _searchStreamController.stream
        .map((searchMap) => searchMap[searchKey] ?? [])
        .distinct();
  }

  // Helper methods for emitting updates
  Future<void> _emitAccountsUpdate() async {
    try {
      final accounts = await getCachedAccounts();
      _accountsStreamController.add(accounts);
      _logger.d('Emitted accounts update: ${accounts.length} accounts');
    } catch (e) {
      _logger.e('Error emitting accounts update: $e');
    }
  }

  Future<void> _emitAccountUpdate(AccountModel account) async {
    try {
      final accountMap = {account.accountId: account};
      _accountByIdStreamController.add(accountMap);
      _logger.d('Emitted account update: ${account.accountId}');
    } catch (e) {
      _logger.e('Error emitting account update: $e');
    }
  }

  Future<void> _emitAccountDeletion(String accountId) async {
    try {
      final accountMap = <String, AccountModel>{};
      _accountByIdStreamController.add(accountMap);
      _logger.d('Emitted account deletion: $accountId');
    } catch (e) {
      _logger.e('Error emitting account deletion: $e');
    }
  }

  String _getQueryKey(AccountsQueryParams params) {
    return '${params.offset}_${params.limit}_${params.sortBy}_${params.sortOrder}';
  }

  // Clean up stream controllers
  void dispose() {
    _accountsStreamController.close();
    _accountByIdStreamController.close();
    _queryStreamController.close();
    _searchStreamController.close();
  }
}
