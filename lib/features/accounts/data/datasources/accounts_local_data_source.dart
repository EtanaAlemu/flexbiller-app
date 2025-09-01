import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import '../../../../core/dao/account_dao.dart';
import '../../../../core/services/database_service.dart';
import '../models/account_model.dart';
import '../../domain/entities/accounts_query_params.dart';

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
}

@Injectable(as: AccountsLocalDataSource)
class AccountsLocalDataSourceImpl implements AccountsLocalDataSource {
  final DatabaseService _databaseService;
  final Logger _logger = Logger();

  AccountsLocalDataSourceImpl(this._databaseService);

  @override
  Future<void> cacheAccounts(List<AccountModel> accounts) async {
    try {
      final db = await _databaseService.database;
      for (final account in accounts) {
        await AccountDao.insertOrUpdate(db, account);
      }
      _logger.d('Cached ${accounts.length} accounts successfully');
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
      final db = await _databaseService.database;
      return await AccountDao.getByQuery(
        db,
        limit: params.limit,
        offset: params.offset,
        orderBy: 'name ASC',
      );
    } catch (e) {
      _logger.e('Error getting cached accounts by query: $e');
      rethrow;
    }
  }
}
