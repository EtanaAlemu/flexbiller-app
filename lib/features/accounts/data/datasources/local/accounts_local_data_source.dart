import 'dart:async';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import '../../../../../core/dao/account_dao.dart';
import '../../../../../core/services/database_service.dart';
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

  AccountsLocalDataSourceImpl(this._databaseService);

  @override
  Future<void> cacheAccounts(List<AccountModel> accounts) async {
    try {
      final db = await _databaseService.database;
      for (final account in accounts) {
        await AccountDao.insertOrUpdate(db, account);
      }
      _logger.d('Cached ${accounts.length} accounts successfully');

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
      final db = await _databaseService.database;
      return await AccountDao.getAll(db, orderBy: 'name ASC');
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
      final db = await _databaseService.database;
      return await AccountDao.getById(db, accountId);
    } catch (e) {
      _logger.e('Error getting cached account by ID: $e');
      rethrow;
    }
  }

  @override
  Future<List<AccountModel>> searchCachedAccounts(String searchKey) async {
    try {
      final db = await _databaseService.database;
      return await AccountDao.search(db, searchKey);
    } catch (e) {
      _logger.e('Error searching cached accounts: $e');
      rethrow;
    }
  }

  @override
  Future<void> cacheAccount(AccountModel account) async {
    try {
      final db = await _databaseService.database;
      await AccountDao.insertOrUpdate(db, account);
      _logger.d('Cached account successfully: ${account.accountId}');

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
      final db = await _databaseService.database;
      await AccountDao.insertOrUpdate(db, account);
      _logger.d('Updated cached account: ${account.accountId}');

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
      final db = await _databaseService.database;
      await AccountDao.deleteById(db, accountId);
      _logger.d('Deleted cached account: $accountId');

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
      final db = await _databaseService.database;
      await AccountDao.clearAll(db);
      _logger.d('Cleared all cached accounts');

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
      final db = await _databaseService.database;
      return await AccountDao.hasAccounts(db);
    } catch (e) {
      _logger.e('Error checking if has cached accounts: $e');
      return false;
    }
  }

  @override
  Future<int> getCachedAccountsCount() async {
    try {
      final db = await _databaseService.database;
      return await AccountDao.getCount(db);
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
      _logger.d(
        '🔍 DEBUG: getCachedAccountsByQuery called with params: ${params.toString()}',
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
      );

      _logger.d(
        '🔍 DEBUG: AccountDao.getByQuery returned ${result.length} accounts',
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
