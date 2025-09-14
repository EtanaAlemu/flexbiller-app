import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import '../../../../../core/services/database_service.dart';
import '../../../../../core/services/user_session_service.dart';
import '../../../../../core/dao/child_account_dao.dart';
import '../../models/child_account_model.dart';

abstract class ChildAccountLocalDataSource {
  Future<void> cacheChildAccount(ChildAccountModel childAccount);
  Future<void> cacheChildAccounts(List<ChildAccountModel> childAccounts);
  Future<ChildAccountModel?> getCachedChildAccount(String email);
  Future<List<ChildAccountModel>> getCachedChildAccounts();
  Future<List<ChildAccountModel>> getCachedChildAccountsByParent(
    String parentAccountId,
  );
  Future<List<ChildAccountModel>> searchCachedChildAccounts(String searchKey);
  Future<void> deleteCachedChildAccount(String email);
  Future<void> clearAllCachedChildAccounts();
  Future<bool> hasCachedChildAccounts();
  Future<int> getCachedChildAccountsCount();
}

@Injectable(as: ChildAccountLocalDataSource)
class ChildAccountLocalDataSourceImpl implements ChildAccountLocalDataSource {
  final DatabaseService _databaseService;
  final UserSessionService _userSessionService;
  final Logger _logger = Logger();

  ChildAccountLocalDataSourceImpl(
    this._databaseService,
    this._userSessionService,
  );

  @override
  Future<void> cacheChildAccount(ChildAccountModel childAccount) async {
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
              'Failed to restore user context, skipping child account caching',
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
      await ChildAccountDao.insertOrUpdate(db, childAccount);
      _logger.d('Child account cached successfully: ${childAccount.email}');
    } catch (e) {
      _logger.e('Error caching child account: $e');
      rethrow;
    }
  }

  @override
  Future<void> cacheChildAccounts(List<ChildAccountModel> childAccounts) async {
    try {
      final db = await _databaseService.database;
      for (final childAccount in childAccounts) {
        await ChildAccountDao.insertOrUpdate(db, childAccount);
      }
      _logger.d('${childAccounts.length} child accounts cached successfully');
    } catch (e) {
      _logger.e('Error caching child accounts: $e');
      rethrow;
    }
  }

  @override
  Future<ChildAccountModel?> getCachedChildAccount(String email) async {
    try {
      final db = await _databaseService.database;
      return await ChildAccountDao.getByEmail(db, email);
    } catch (e) {
      _logger.e('Error getting cached child account: $e');
      // If table doesn't exist, return null instead of throwing
      if (e.toString().contains('no such table: child_accounts')) {
        _logger.w('Child accounts table does not exist yet, returning null');
        return null;
      }
      rethrow;
    }
  }

  @override
  Future<List<ChildAccountModel>> getCachedChildAccounts() async {
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
              'Failed to restore user context, returning empty child accounts list',
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
      return await ChildAccountDao.getAll(db, orderBy: 'name ASC');
    } catch (e) {
      _logger.e('Error getting cached child accounts: $e');
      // If table doesn't exist, return empty list instead of throwing
      if (e.toString().contains('no such table: child_accounts')) {
        _logger.w(
          'Child accounts table does not exist yet, returning empty list',
        );
        return [];
      }
      rethrow;
    }
  }

  @override
  Future<List<ChildAccountModel>> getCachedChildAccountsByParent(
    String parentAccountId,
  ) async {
    try {
      final db = await _databaseService.database;
      return await ChildAccountDao.getByParentAccountId(db, parentAccountId);
    } catch (e) {
      _logger.e('Error getting cached child accounts by parent: $e');
      // If table doesn't exist, return empty list instead of throwing
      if (e.toString().contains('no such table: child_accounts')) {
        _logger.w(
          'Child accounts table does not exist yet, returning empty list',
        );
        return [];
      }
      rethrow;
    }
  }

  @override
  Future<List<ChildAccountModel>> searchCachedChildAccounts(
    String searchKey,
  ) async {
    try {
      final db = await _databaseService.database;
      return await ChildAccountDao.search(db, searchKey);
    } catch (e) {
      _logger.e('Error searching cached child accounts: $e');
      // If table doesn't exist, return empty list instead of throwing
      if (e.toString().contains('no such table: child_accounts')) {
        _logger.w(
          'Child accounts table does not exist yet, returning empty list',
        );
        return [];
      }
      rethrow;
    }
  }

  @override
  Future<void> deleteCachedChildAccount(String email) async {
    try {
      final db = await _databaseService.database;
      await ChildAccountDao.deleteByEmail(db, email);
      _logger.d('Child account deleted from cache: $email');
    } catch (e) {
      _logger.e('Error deleting cached child account: $e');
      rethrow;
    }
  }

  @override
  Future<void> clearAllCachedChildAccounts() async {
    try {
      final db = await _databaseService.database;
      await ChildAccountDao.clearAll(db);
      _logger.d('All cached child accounts cleared');
    } catch (e) {
      _logger.e('Error clearing cached child accounts: $e');
      rethrow;
    }
  }

  @override
  Future<bool> hasCachedChildAccounts() async {
    try {
      final db = await _databaseService.database;
      return await ChildAccountDao.hasChildAccounts(db);
    } catch (e) {
      _logger.e('Error checking if cached child accounts exist: $e');
      // If table doesn't exist, return false instead of throwing
      if (e.toString().contains('no such table: child_accounts')) {
        _logger.w('Child accounts table does not exist yet, returning false');
        return false;
      }
      rethrow;
    }
  }

  @override
  Future<int> getCachedChildAccountsCount() async {
    try {
      final db = await _databaseService.database;
      return await ChildAccountDao.getCount(db);
    } catch (e) {
      _logger.e('Error getting cached child accounts count: $e');
      // If table doesn't exist, return 0 instead of throwing
      if (e.toString().contains('no such table: child_accounts')) {
        _logger.w('Child accounts table does not exist yet, returning 0');
        return 0;
      }
      rethrow;
    }
  }
}
