import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import '../../../../../core/services/database_service.dart';
import '../../../../../core/services/user_session_service.dart';
import '../../../../../core/dao/account_payment_method_dao.dart';
import '../../models/account_payment_method_model.dart';

abstract class AccountPaymentMethodsLocalDataSource {
  Future<void> cacheAccountPaymentMethods(
    String accountId,
    List<AccountPaymentMethodModel> paymentMethods,
  );
  Future<void> cacheAccountPaymentMethod(
    AccountPaymentMethodModel paymentMethod,
  );
  Future<List<AccountPaymentMethodModel>> getCachedAccountPaymentMethods(
    String accountId,
  );
  Future<AccountPaymentMethodModel?> getCachedAccountPaymentMethod(String id);
  Future<AccountPaymentMethodModel?> getCachedDefaultPaymentMethod(
    String accountId,
  );
  Future<List<AccountPaymentMethodModel>> getCachedActivePaymentMethods(
    String accountId,
  );
  Future<List<AccountPaymentMethodModel>> getCachedPaymentMethodsByType(
    String accountId,
    String paymentMethodType,
  );
  Future<List<AccountPaymentMethodModel>> getCachedPaymentMethodsByPluginName(
    String accountId,
    String pluginName,
  );
  Future<List<AccountPaymentMethodModel>> getCachedPaymentMethodsWithPagination(
    String accountId,
    int page,
    int pageSize,
  );
  Future<List<AccountPaymentMethodModel>> getAllCachedPaymentMethods();
  Future<List<AccountPaymentMethodModel>> searchCachedPaymentMethodsByName(
    String accountId,
    String searchTerm,
  );
  Future<AccountPaymentMethodModel?> getCachedPaymentMethodByExternalKey(
    String externalKey,
  );
  Future<List<AccountPaymentMethodModel>> getCachedPaymentMethodsByCardBrand(
    String accountId,
    String cardBrand,
  );
  Future<List<AccountPaymentMethodModel>> getCachedPaymentMethodsByBankName(
    String accountId,
    String bankName,
  );
  Future<void> updateCachedPaymentMethod(
    AccountPaymentMethodModel paymentMethod,
  );
  Future<void> setCachedDefaultPaymentMethod(
    String accountId,
    String paymentMethodId,
  );
  Future<void> deleteCachedPaymentMethod(String id);
  Future<void> deleteCachedPaymentMethods(String accountId);
  Future<void> clearAllCachedPaymentMethods();
  Future<int> getCachedPaymentMethodsCount(String accountId);
  Future<int> getCachedPaymentMethodsCountByType(
    String accountId,
    String paymentMethodType,
  );
  Future<int> getCachedActivePaymentMethodsCount(String accountId);
  Future<int> getTotalCachedPaymentMethodsCount();
  Future<bool> hasCachedPaymentMethods(String accountId);
  Future<bool> hasCachedDefaultPaymentMethod(String accountId);
}

@Injectable(as: AccountPaymentMethodsLocalDataSource)
class AccountPaymentMethodsLocalDataSourceImpl
    implements AccountPaymentMethodsLocalDataSource {
  final DatabaseService _databaseService;
  final UserSessionService _userSessionService;
  final Logger _logger;

  AccountPaymentMethodsLocalDataSourceImpl(
    this._databaseService,
    this._userSessionService,
    this._logger,
  );

  @override
  Future<void> cacheAccountPaymentMethods(
    String accountId,
    List<AccountPaymentMethodModel> paymentMethods,
  ) async {
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
              'Failed to restore user context, skipping payment methods caching',
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
      await AccountPaymentMethodDao.insertMultiple(db, paymentMethods);
      _logger.d(
        'Cached ${paymentMethods.length} payment methods for account: $accountId',
      );
    } catch (e) {
      _logger.e('Error caching payment methods for account $accountId: $e');
      rethrow;
    }
  }

  @override
  Future<void> cacheAccountPaymentMethod(
    AccountPaymentMethodModel paymentMethod,
  ) async {
    try {
      final db = await _databaseService.database;
      await AccountPaymentMethodDao.insertOrUpdate(db, paymentMethod);
      _logger.d(
        'Cached payment method: ${paymentMethod.id} for account: ${paymentMethod.accountId}',
      );
    } catch (e) {
      _logger.e('Error caching payment method ${paymentMethod.id}: $e');
      rethrow;
    }
  }

  @override
  Future<List<AccountPaymentMethodModel>> getCachedAccountPaymentMethods(
    String accountId,
  ) async {
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
              'Failed to restore user context, returning empty payment methods list',
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
      final paymentMethods = await AccountPaymentMethodDao.getByAccountId(
        db,
        accountId,
      );
      _logger.d(
        'Retrieved ${paymentMethods.length} cached payment methods for account: $accountId',
      );
      return paymentMethods;
    } catch (e) {
      _logger.e(
        'Error retrieving cached payment methods for account $accountId: $e',
      );
      rethrow;
    }
  }

  @override
  Future<AccountPaymentMethodModel?> getCachedAccountPaymentMethod(
    String id,
  ) async {
    try {
      final db = await _databaseService.database;
      final paymentMethod = await AccountPaymentMethodDao.getById(db, id);
      if (paymentMethod != null) {
        _logger.d('Retrieved cached payment method: $id');
      } else {
        _logger.d('No cached payment method found: $id');
      }
      return paymentMethod;
    } catch (e) {
      _logger.e('Error retrieving cached payment method $id: $e');
      rethrow;
    }
  }

  @override
  Future<AccountPaymentMethodModel?> getCachedDefaultPaymentMethod(
    String accountId,
  ) async {
    try {
      final db = await _databaseService.database;
      final paymentMethod = await AccountPaymentMethodDao.getDefaultByAccountId(
        db,
        accountId,
      );
      if (paymentMethod != null) {
        _logger.d(
          'Retrieved cached default payment method for account: $accountId',
        );
      } else {
        _logger.d(
          'No cached default payment method found for account: $accountId',
        );
      }
      return paymentMethod;
    } catch (e) {
      _logger.e(
        'Error retrieving cached default payment method for account $accountId: $e',
      );
      rethrow;
    }
  }

  @override
  Future<List<AccountPaymentMethodModel>> getCachedActivePaymentMethods(
    String accountId,
  ) async {
    try {
      final db = await _databaseService.database;
      final paymentMethods = await AccountPaymentMethodDao.getActiveByAccountId(
        db,
        accountId,
      );
      _logger.d(
        'Retrieved ${paymentMethods.length} cached active payment methods for account: $accountId',
      );
      return paymentMethods;
    } catch (e) {
      _logger.e(
        'Error retrieving cached active payment methods for account $accountId: $e',
      );
      rethrow;
    }
  }

  @override
  Future<List<AccountPaymentMethodModel>> getCachedPaymentMethodsByType(
    String accountId,
    String paymentMethodType,
  ) async {
    try {
      final db = await _databaseService.database;
      final paymentMethods = await AccountPaymentMethodDao.getByType(
        db,
        accountId,
        paymentMethodType,
      );
      _logger.d(
        'Retrieved ${paymentMethods.length} cached payment methods with type $paymentMethodType for account: $accountId',
      );
      return paymentMethods;
    } catch (e) {
      _logger.e(
        'Error retrieving cached payment methods with type $paymentMethodType for account $accountId: $e',
      );
      rethrow;
    }
  }

  @override
  Future<List<AccountPaymentMethodModel>> getCachedPaymentMethodsByPluginName(
    String accountId,
    String pluginName,
  ) async {
    try {
      final db = await _databaseService.database;
      final paymentMethods = await AccountPaymentMethodDao.getByPluginName(
        db,
        accountId,
        pluginName,
      );
      _logger.d(
        'Retrieved ${paymentMethods.length} cached payment methods with plugin $pluginName for account: $accountId',
      );
      return paymentMethods;
    } catch (e) {
      _logger.e(
        'Error retrieving cached payment methods with plugin $pluginName for account $accountId: $e',
      );
      rethrow;
    }
  }

  @override
  Future<List<AccountPaymentMethodModel>> getCachedPaymentMethodsWithPagination(
    String accountId,
    int page,
    int pageSize,
  ) async {
    try {
      final db = await _databaseService.database;
      final paymentMethods = await AccountPaymentMethodDao.getWithPagination(
        db,
        accountId,
        page,
        pageSize,
      );
      _logger.d(
        'Retrieved ${paymentMethods.length} cached payment methods (page $page, size $pageSize) for account: $accountId',
      );
      return paymentMethods;
    } catch (e) {
      _logger.e(
        'Error retrieving cached payment methods with pagination for account $accountId: $e',
      );
      rethrow;
    }
  }

  @override
  Future<List<AccountPaymentMethodModel>> getAllCachedPaymentMethods() async {
    try {
      final db = await _databaseService.database;
      final paymentMethods = await AccountPaymentMethodDao.getAll(db);
      _logger.d(
        'Retrieved ${paymentMethods.length} total cached payment methods',
      );
      return paymentMethods;
    } catch (e) {
      _logger.e('Error retrieving all cached payment methods: $e');
      rethrow;
    }
  }

  @override
  Future<List<AccountPaymentMethodModel>> searchCachedPaymentMethodsByName(
    String accountId,
    String searchTerm,
  ) async {
    try {
      final db = await _databaseService.database;
      final paymentMethods = await AccountPaymentMethodDao.searchByName(
        db,
        accountId,
        searchTerm,
      );
      _logger.d(
        'Searched cached payment methods by name: $searchTerm, found ${paymentMethods.length} results for account: $accountId',
      );
      return paymentMethods;
    } catch (e) {
      _logger.e(
        'Error searching cached payment methods by name $searchTerm for account $accountId: $e',
      );
      rethrow;
    }
  }

  @override
  Future<AccountPaymentMethodModel?> getCachedPaymentMethodByExternalKey(
    String externalKey,
  ) async {
    try {
      final db = await _databaseService.database;
      final paymentMethod = await AccountPaymentMethodDao.getByExternalKey(
        db,
        externalKey,
      );
      if (paymentMethod != null) {
        _logger.d(
          'Retrieved cached payment method by external key: $externalKey',
        );
      } else {
        _logger.d(
          'No cached payment method found by external key: $externalKey',
        );
      }
      return paymentMethod;
    } catch (e) {
      _logger.e(
        'Error retrieving cached payment method by external key $externalKey: $e',
      );
      rethrow;
    }
  }

  @override
  Future<List<AccountPaymentMethodModel>> getCachedPaymentMethodsByCardBrand(
    String accountId,
    String cardBrand,
  ) async {
    try {
      final db = await _databaseService.database;
      final paymentMethods = await AccountPaymentMethodDao.getByCardBrand(
        db,
        accountId,
        cardBrand,
      );
      _logger.d(
        'Retrieved ${paymentMethods.length} cached payment methods with card brand $cardBrand for account: $accountId',
      );
      return paymentMethods;
    } catch (e) {
      _logger.e(
        'Error retrieving cached payment methods with card brand $cardBrand for account $accountId: $e',
      );
      rethrow;
    }
  }

  @override
  Future<List<AccountPaymentMethodModel>> getCachedPaymentMethodsByBankName(
    String accountId,
    String bankName,
  ) async {
    try {
      final db = await _databaseService.database;
      final paymentMethods = await AccountPaymentMethodDao.getByBankName(
        db,
        accountId,
        bankName,
      );
      _logger.d(
        'Retrieved ${paymentMethods.length} cached payment methods with bank name $bankName for account: $accountId',
      );
      return paymentMethods;
    } catch (e) {
      _logger.e(
        'Error retrieving cached payment methods with bank name $bankName for account $accountId: $e',
      );
      rethrow;
    }
  }

  @override
  Future<void> updateCachedPaymentMethod(
    AccountPaymentMethodModel paymentMethod,
  ) async {
    try {
      final db = await _databaseService.database;
      await AccountPaymentMethodDao.update(db, paymentMethod);
      _logger.d(
        'Updated cached payment method: ${paymentMethod.id} for account: ${paymentMethod.accountId}',
      );
    } catch (e) {
      _logger.e('Error updating cached payment method ${paymentMethod.id}: $e');
      rethrow;
    }
  }

  @override
  Future<void> setCachedDefaultPaymentMethod(
    String accountId,
    String paymentMethodId,
  ) async {
    try {
      final db = await _databaseService.database;
      await AccountPaymentMethodDao.setDefault(db, accountId, paymentMethodId);
      _logger.d(
        'Set cached default payment method: $paymentMethodId for account: $accountId',
      );
    } catch (e) {
      _logger.e(
        'Error setting cached default payment method $paymentMethodId for account $accountId: $e',
      );
      rethrow;
    }
  }

  @override
  Future<void> deleteCachedPaymentMethod(String id) async {
    try {
      final db = await _databaseService.database;
      await AccountPaymentMethodDao.delete(db, id);
      _logger.d('Deleted cached payment method: $id');
    } catch (e) {
      _logger.e('Error deleting cached payment method $id: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteCachedPaymentMethods(String accountId) async {
    try {
      final db = await _databaseService.database;
      await AccountPaymentMethodDao.deleteByAccountId(db, accountId);
      _logger.d('Deleted all cached payment methods for account: $accountId');
    } catch (e) {
      _logger.e(
        'Error deleting cached payment methods for account $accountId: $e',
      );
      rethrow;
    }
  }

  @override
  Future<void> clearAllCachedPaymentMethods() async {
    try {
      final db = await _databaseService.database;
      await AccountPaymentMethodDao.deleteAll(db);
      _logger.d('Cleared all cached payment methods');
    } catch (e) {
      _logger.e('Error clearing all cached payment methods: $e');
      rethrow;
    }
  }

  @override
  Future<int> getCachedPaymentMethodsCount(String accountId) async {
    try {
      final db = await _databaseService.database;
      final count = await AccountPaymentMethodDao.getCountByAccountId(
        db,
        accountId,
      );
      _logger.d(
        'Retrieved cached payment methods count for account $accountId: $count',
      );
      return count;
    } catch (e) {
      _logger.e(
        'Error retrieving cached payment methods count for account $accountId: $e',
      );
      rethrow;
    }
  }

  @override
  Future<int> getCachedPaymentMethodsCountByType(
    String accountId,
    String paymentMethodType,
  ) async {
    try {
      final db = await _databaseService.database;
      final count = await AccountPaymentMethodDao.getCountByType(
        db,
        accountId,
        paymentMethodType,
      );
      _logger.d(
        'Retrieved cached payment methods count with type $paymentMethodType for account $accountId: $count',
      );
      return count;
    } catch (e) {
      _logger.e(
        'Error retrieving cached payment methods count with type $paymentMethodType for account $accountId: $e',
      );
      rethrow;
    }
  }

  @override
  Future<int> getCachedActivePaymentMethodsCount(String accountId) async {
    try {
      final db = await _databaseService.database;
      final count = await AccountPaymentMethodDao.getActiveCountByAccountId(
        db,
        accountId,
      );
      _logger.d(
        'Retrieved cached active payment methods count for account $accountId: $count',
      );
      return count;
    } catch (e) {
      _logger.e(
        'Error retrieving cached active payment methods count for account $accountId: $e',
      );
      rethrow;
    }
  }

  @override
  Future<int> getTotalCachedPaymentMethodsCount() async {
    try {
      final db = await _databaseService.database;
      final count = await AccountPaymentMethodDao.getTotalCount(db);
      _logger.d('Retrieved total cached payment methods count: $count');
      return count;
    } catch (e) {
      _logger.e('Error retrieving total cached payment methods count: $e');
      rethrow;
    }
  }

  @override
  Future<bool> hasCachedPaymentMethods(String accountId) async {
    try {
      final count = await getCachedPaymentMethodsCount(accountId);
      final hasPaymentMethods = count > 0;
      _logger.d(
        'Account $accountId has cached payment methods: $hasPaymentMethods',
      );
      return hasPaymentMethods;
    } catch (e) {
      _logger.e(
        'Error checking if account $accountId has cached payment methods: $e',
      );
      rethrow;
    }
  }

  @override
  Future<bool> hasCachedDefaultPaymentMethod(String accountId) async {
    try {
      final db = await _databaseService.database;
      final hasDefault = await AccountPaymentMethodDao.hasDefaultPaymentMethod(
        db,
        accountId,
      );
      _logger.d(
        'Account $accountId has cached default payment method: $hasDefault',
      );
      return hasDefault;
    } catch (e) {
      _logger.e(
        'Error checking if account $accountId has cached default payment method: $e',
      );
      rethrow;
    }
  }
}
