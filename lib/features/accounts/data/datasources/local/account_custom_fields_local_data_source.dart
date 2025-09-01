import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import '../../../../../core/dao/account_custom_field_dao.dart';
import '../../../../../core/services/database_service.dart';
import '../../models/account_custom_field_model.dart';

abstract class AccountCustomFieldsLocalDataSource {
  Future<void> cacheCustomFields(List<AccountCustomFieldModel> customFields);
  Future<void> cacheCustomField(AccountCustomFieldModel customField);
  Future<List<AccountCustomFieldModel>> getCachedCustomFields(String accountId);
  Future<AccountCustomFieldModel?> getCachedCustomField(String customFieldId);
  Future<List<AccountCustomFieldModel>> getCachedCustomFieldsByName(
    String accountId,
    String name,
  );
  Future<List<AccountCustomFieldModel>> getCachedCustomFieldsByValue(
    String accountId,
    String value,
  );
  Future<List<AccountCustomFieldModel>> getCachedCustomFieldsByType(
    String accountId,
    String type,
  );
  Future<List<AccountCustomFieldModel>> getCachedCustomFieldsWithPagination(
    String accountId,
    int page,
    int pageSize,
  );
  Future<List<AccountCustomFieldModel>> searchCachedCustomFields(
    String accountId,
    String searchTerm,
  );
  Future<int> getCachedCustomFieldsCount(String accountId);
  Future<void> updateCachedCustomField(AccountCustomFieldModel customField);
  Future<void> deleteCachedCustomField(String customFieldId);
  Future<void> deleteCachedCustomFieldsByAccount(String accountId);
  Future<void> clearAllCachedCustomFields();
  Future<bool> hasCachedCustomFields(String accountId);
}

@Injectable(as: AccountCustomFieldsLocalDataSource)
class AccountCustomFieldsLocalDataSourceImpl
    implements AccountCustomFieldsLocalDataSource {
  final DatabaseService _databaseService;
  final Logger _logger = Logger();

  AccountCustomFieldsLocalDataSourceImpl(this._databaseService);

  @override
  Future<void> cacheCustomFields(
    List<AccountCustomFieldModel> customFields,
  ) async {
    try {
      final db = await _databaseService.database;
      await AccountCustomFieldDao.insertMultipleCustomFields(db, customFields);
      _logger.d('Cached ${customFields.length} custom fields successfully');
    } catch (e) {
      _logger.e('Error caching custom fields: $e');
      rethrow;
    }
  }

  @override
  Future<void> cacheCustomField(AccountCustomFieldModel customField) async {
    try {
      final db = await _databaseService.database;
      await AccountCustomFieldDao.insertCustomField(db, customField);
      _logger.d(
        'Cached custom field: ${customField.name} for account: ${customField.objectId} successfully',
      );
    } catch (e) {
      _logger.e('Error caching custom field: ${customField.name} - $e');
      rethrow;
    }
  }

  @override
  Future<List<AccountCustomFieldModel>> getCachedCustomFields(
    String accountId,
  ) async {
    try {
      final db = await _databaseService.database;
      final customFields = await AccountCustomFieldDao.getCustomFieldsByAccount(
        db,
        accountId,
      );
      _logger.d(
        'Retrieved ${customFields.length} cached custom fields for account: $accountId',
      );
      return customFields;
    } catch (e) {
      _logger.w(
        'Error retrieving cached custom fields for account: $accountId - $e',
      );
      // Return empty list if there's an error (e.g., table doesn't exist yet)
      return [];
    }
  }

  @override
  Future<AccountCustomFieldModel?> getCachedCustomField(
    String customFieldId,
  ) async {
    try {
      final db = await _databaseService.database;
      final customField = await AccountCustomFieldDao.getCustomFieldById(
        db,
        customFieldId,
      );

      if (customField != null) {
        _logger.d('Retrieved cached custom field: $customFieldId');
        return customField;
      }

      _logger.d('No cached custom field found for: $customFieldId');
      return null;
    } catch (e) {
      _logger.w('Error retrieving cached custom field: $customFieldId - $e');
      return null;
    }
  }

  @override
  Future<List<AccountCustomFieldModel>> getCachedCustomFieldsByName(
    String accountId,
    String name,
  ) async {
    try {
      final db = await _databaseService.database;
      final customFields = await AccountCustomFieldDao.getCustomFieldsByName(
        db,
        accountId,
        name,
      );
      _logger.d(
        'Retrieved ${customFields.length} cached custom fields by name: $name for account: $accountId',
      );
      return customFields;
    } catch (e) {
      _logger.w(
        'Error retrieving cached custom fields by name for account: $accountId, name: $name - $e',
      );
      return [];
    }
  }

  @override
  Future<List<AccountCustomFieldModel>> getCachedCustomFieldsByValue(
    String accountId,
    String value,
  ) async {
    try {
      final db = await _databaseService.database;
      final customFields = await AccountCustomFieldDao.getCustomFieldsByValue(
        db,
        accountId,
        value,
      );
      _logger.d(
        'Retrieved ${customFields.length} cached custom fields by value: $value for account: $accountId',
      );
      return customFields;
    } catch (e) {
      _logger.w(
        'Error retrieving cached custom fields by value for account: $accountId, value: $value - $e',
      );
      return [];
    }
  }

  @override
  Future<List<AccountCustomFieldModel>> getCachedCustomFieldsByType(
    String accountId,
    String type,
  ) async {
    try {
      final db = await _databaseService.database;
      final customFields = await AccountCustomFieldDao.getCustomFieldsByType(
        db,
        accountId,
        type,
      );
      _logger.d(
        'Retrieved ${customFields.length} cached custom fields by type: $type for account: $accountId',
      );
      return customFields;
    } catch (e) {
      _logger.w(
        'Error retrieving cached custom fields by type for account: $accountId, type: $type - $e',
      );
      return [];
    }
  }

  @override
  Future<List<AccountCustomFieldModel>> getCachedCustomFieldsWithPagination(
    String accountId,
    int page,
    int pageSize,
  ) async {
    try {
      final db = await _databaseService.database;
      final offset = page * pageSize;
      final customFields =
          await AccountCustomFieldDao.getCustomFieldsWithPagination(
            db,
            accountId,
            offset,
            pageSize,
          );
      _logger.d(
        'Retrieved ${customFields.length} cached custom fields with pagination for account: $accountId (page: $page, size: $pageSize)',
      );
      return customFields;
    } catch (e) {
      _logger.w(
        'Error retrieving cached custom fields with pagination for account: $accountId - $e',
      );
      return [];
    }
  }

  @override
  Future<List<AccountCustomFieldModel>> searchCachedCustomFields(
    String accountId,
    String searchTerm,
  ) async {
    try {
      final db = await _databaseService.database;
      final customFields = await AccountCustomFieldDao.searchCustomFields(
        db,
        accountId,
        searchTerm,
      );
      _logger.d(
        'Retrieved ${customFields.length} cached custom fields by search term: $searchTerm for account: $accountId',
      );
      return customFields;
    } catch (e) {
      _logger.w(
        'Error searching cached custom fields for account: $accountId, searchTerm: $searchTerm - $e',
      );
      return [];
    }
  }

  @override
  Future<int> getCachedCustomFieldsCount(String accountId) async {
    try {
      final db = await _databaseService.database;
      final count = await AccountCustomFieldDao.getCustomFieldsCount(
        db,
        accountId,
      );
      _logger.d(
        'Retrieved cached custom fields count: $count for account: $accountId',
      );
      return count;
    } catch (e) {
      _logger.w(
        'Error retrieving cached custom fields count for account: $accountId - $e',
      );
      return 0;
    }
  }

  @override
  Future<void> updateCachedCustomField(
    AccountCustomFieldModel customField,
  ) async {
    try {
      final db = await _databaseService.database;
      await AccountCustomFieldDao.updateCustomField(db, customField);
      _logger.d(
        'Updated cached custom field: ${customField.name} for account: ${customField.objectId} successfully',
      );
    } catch (e) {
      _logger.e('Error updating cached custom field: ${customField.name} - $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteCachedCustomField(String customFieldId) async {
    try {
      final db = await _databaseService.database;
      await AccountCustomFieldDao.deleteCustomField(db, customFieldId);
      _logger.d('Deleted cached custom field: $customFieldId successfully');
    } catch (e) {
      _logger.e('Error deleting cached custom field: $customFieldId - $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteCachedCustomFieldsByAccount(String accountId) async {
    try {
      final db = await _databaseService.database;
      await AccountCustomFieldDao.deleteCustomFieldsByAccount(db, accountId);
      _logger.d(
        'Deleted cached custom fields for account: $accountId successfully',
      );
    } catch (e) {
      _logger.e(
        'Error deleting cached custom fields for account: $accountId - $e',
      );
      rethrow;
    }
  }

  @override
  Future<void> clearAllCachedCustomFields() async {
    try {
      final db = await _databaseService.database;
      await AccountCustomFieldDao.clearAllCustomFields(db);
      _logger.d('Cleared all cached custom fields successfully');
    } catch (e) {
      _logger.e('Error clearing cached custom fields: $e');
      rethrow;
    }
  }

  @override
  Future<bool> hasCachedCustomFields(String accountId) async {
    try {
      final db = await _databaseService.database;
      final count = await AccountCustomFieldDao.getCustomFieldsCount(
        db,
        accountId,
      );
      return count > 0;
    } catch (e) {
      _logger.e(
        'Error checking if cached custom fields exist for account: $accountId - $e',
      );
      // If table doesn't exist, return false instead of throwing
      if (e.toString().contains('no such table: account_custom_fields')) {
        _logger.w(
          'Account custom fields table does not exist yet, returning false',
        );
        return false;
      }
      rethrow;
    }
  }
}
