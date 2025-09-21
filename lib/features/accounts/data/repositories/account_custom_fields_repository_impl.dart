import 'dart:async';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import '../../domain/entities/account_custom_field.dart';
import '../../domain/repositories/account_custom_fields_repository.dart';
import '../datasources/local/account_custom_fields_local_data_source.dart';
import '../datasources/remote/account_custom_fields_remote_data_source.dart';
import '../../../../core/network/network_info.dart';

@LazySingleton(as: AccountCustomFieldsRepository)
class AccountCustomFieldsRepositoryImpl
    implements AccountCustomFieldsRepository {
  final AccountCustomFieldsLocalDataSource _localDataSource;
  final AccountCustomFieldsRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;
  final Logger _logger = Logger();

  // Stream controller for reactive UI updates
  final StreamController<List<AccountCustomField>>
  _customFieldsStreamController =
      StreamController<List<AccountCustomField>>.broadcast();

  AccountCustomFieldsRepositoryImpl({
    required AccountCustomFieldsLocalDataSource localDataSource,
    required AccountCustomFieldsRemoteDataSource remoteDataSource,
    required NetworkInfo networkInfo,
  }) : _localDataSource = localDataSource,
       _remoteDataSource = remoteDataSource,
       _networkInfo = networkInfo;

  // Stream getter for reactive UI updates
  @override
  Stream<List<AccountCustomField>> get customFieldsStream =>
      _customFieldsStreamController.stream;

  @override
  Future<List<AccountCustomField>> getAccountCustomFields(
    String accountId,
  ) async {
    try {
      _logger.d('Getting cached custom fields from local data source');
      // LOCAL-FIRST: Always try to get data from local cache first
      final cachedCustomFields = await _localDataSource.getCachedCustomFields(
        accountId,
      );

      _logger.d('Found ${cachedCustomFields.length} cached custom fields');
      
      // Convert models to entities
      final entities = cachedCustomFields
          .map((model) => model.toEntity())
          .toList();

      // Emit cached data to stream immediately for reactive UI updates
      _logger.d('Emitting cached data to stream immediately');
      _customFieldsStreamController.add(entities);

      // Return cached data immediately for fast UI response
      _logger.d('Returning ${entities.length} custom fields from local cache');

      // Start background sync if online (non-blocking)
      _performBackgroundSync(accountId);

      return entities;
    } catch (e) {
      _logger.e('Error getting account custom fields: $e');
      rethrow;
    }
  }

  @override
  Future<AccountCustomField> getCustomField(
    String accountId,
    String customFieldId,
  ) async {
    try {
      // First, try to get from local cache
      final cachedCustomField = await _localDataSource.getCachedCustomField(
        customFieldId,
      );

      if (cachedCustomField != null) {
        return cachedCustomField.toEntity();
      }

      // If not in cache and online, fetch from remote
      if (await _networkInfo.isConnected) {
        final remoteCustomField = await _remoteDataSource.getCustomField(
          accountId,
          customFieldId,
        );

        // Cache the remote data
        await _localDataSource.cacheCustomField(remoteCustomField);

        return remoteCustomField.toEntity();
      } else {
        throw Exception('No data available offline');
      }
    } catch (e) {
      _logger.e('Error getting custom field: $e');
      rethrow;
    }
  }

  @override
  Future<AccountCustomField> createCustomField(
    String accountId,
    String name,
    String value,
  ) async {
    try {
      // Create remotely first
      final customFieldModel = await _remoteDataSource.createCustomField(
        accountId,
        name,
        value,
      );

      // Cache the created custom field
      await _localDataSource.cacheCustomField(customFieldModel);

      // Add to stream for reactive UI update
      final entity = customFieldModel.toEntity();
      _customFieldsStreamController.add([entity]);

      return entity;
    } catch (e) {
      _logger.e('Error creating custom field: $e');
      rethrow;
    }
  }

  @override
  Future<List<AccountCustomField>> createMultipleCustomFields(
    String accountId,
    List<Map<String, String>> customFields,
  ) async {
    try {
      // Create remotely first
      final customFieldModels = await _remoteDataSource
          .createMultipleCustomFields(accountId, customFields);

      // Cache the created custom fields
      await _localDataSource.cacheCustomFields(customFieldModels);

      // Convert to entities and add to stream for reactive UI update
      final entities = customFieldModels
          .map((model) => model.toEntity())
          .toList();
      _customFieldsStreamController.add(entities);

      return entities;
    } catch (e) {
      _logger.e('Error creating multiple custom fields: $e');
      rethrow;
    }
  }

  @override
  Future<AccountCustomField> updateCustomField(
    String accountId,
    String customFieldId,
    String name,
    String value,
  ) async {
    try {
      // Update remotely
      final updatedCustomFieldModel = await _remoteDataSource.updateCustomField(
        accountId,
        customFieldId,
        name,
        value,
      );

      // Update local cache
      await _localDataSource.updateCachedCustomField(updatedCustomFieldModel);

      // Add to stream for reactive UI update
      final entity = updatedCustomFieldModel.toEntity();
      _customFieldsStreamController.add([entity]);

      return entity;
    } catch (e) {
      _logger.e('Error updating custom field: $e');
      rethrow;
    }
  }

  @override
  Future<List<AccountCustomField>> updateMultipleCustomFields(
    String accountId,
    List<Map<String, dynamic>> customFields,
  ) async {
    try {
      // Update remotely
      final updatedCustomFieldModels = await _remoteDataSource
          .updateMultipleCustomFields(accountId, customFields);

      // Update local cache
      for (final customField in updatedCustomFieldModels) {
        await _localDataSource.updateCachedCustomField(customField);
      }

      // Convert to entities and add to stream for reactive UI update
      final entities = updatedCustomFieldModels
          .map((model) => model.toEntity())
          .toList();
      _customFieldsStreamController.add(entities);

      return entities;
    } catch (e) {
      _logger.e('Error updating multiple custom fields: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteCustomField(String accountId, String customFieldId) async {
    try {
      // Delete remotely
      await _remoteDataSource.deleteCustomField(accountId, customFieldId);

      // Remove from local cache
      await _localDataSource.deleteCachedCustomField(customFieldId);

      // Refresh stream to reflect deletion
      final remainingCustomFields = await _localDataSource
          .getCachedCustomFields(accountId);
      final entities = remainingCustomFields
          .map((model) => model.toEntity())
          .toList();
      _customFieldsStreamController.add(entities);
    } catch (e) {
      _logger.e('Error deleting custom field: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteMultipleCustomFields(
    String accountId,
    List<String> customFieldIds,
  ) async {
    try {
      // Delete remotely
      await _remoteDataSource.deleteMultipleCustomFields(
        accountId,
        customFieldIds,
      );

      // Remove from local cache
      for (final customFieldId in customFieldIds) {
        await _localDataSource.deleteCachedCustomField(customFieldId);
      }

      // Refresh stream to reflect deletion
      final remainingCustomFields = await _localDataSource
          .getCachedCustomFields(accountId);
      final entities = remainingCustomFields
          .map((model) => model.toEntity())
          .toList();
      _customFieldsStreamController.add(entities);
    } catch (e) {
      _logger.e('Error deleting multiple custom fields: $e');
      rethrow;
    }
  }

  @override
  Future<List<AccountCustomField>> getCustomFieldsByName(
    String accountId,
    String name,
  ) async {
    try {
      // First, try to get from local cache
      final cachedCustomFields = await _localDataSource
          .getCachedCustomFieldsByName(accountId, name);

      if (cachedCustomFields.isNotEmpty) {
        final entities = cachedCustomFields
            .map((model) => model.toEntity())
            .toList();

        // Start background sync if online
        _performBackgroundSync(accountId);

        return entities;
      }

      // If no cached data and online, fetch from remote
      if (await _networkInfo.isConnected) {
        // For now, get all custom fields and filter by name
        // In the future, this could be implemented as a separate API endpoint
        final allCustomFields = await getAccountCustomFields(accountId);
        return allCustomFields
            .where(
              (field) => field.name.toLowerCase().contains(name.toLowerCase()),
            )
            .toList();
      } else {
        throw Exception('No data available offline');
      }
    } catch (e) {
      _logger.e('Error getting custom fields by name: $e');
      rethrow;
    }
  }

  @override
  Future<List<AccountCustomField>> getCustomFieldsByValue(
    String accountId,
    String value,
  ) async {
    try {
      // First, try to get from local cache
      final cachedCustomFields = await _localDataSource
          .getCachedCustomFieldsByValue(accountId, value);

      if (cachedCustomFields.isNotEmpty) {
        final entities = cachedCustomFields
            .map((model) => model.toEntity())
            .toList();

        // Start background sync if online
        _performBackgroundSync(accountId);

        return entities;
      }

      // If no cached data and online, fetch from remote
      if (await _networkInfo.isConnected) {
        // For now, get all custom fields and filter by value
        // In the future, this could be implemented as a separate API endpoint
        final allCustomFields = await getAccountCustomFields(accountId);
        return allCustomFields
            .where(
              (field) =>
                  field.value.toLowerCase().contains(value.toLowerCase()),
            )
            .toList();
      } else {
        throw Exception('No data available offline');
      }
    } catch (e) {
      _logger.e('Error getting custom fields by value: $e');
      rethrow;
    }
  }

  /// Background synchronization method for custom fields
  Future<void> _performBackgroundSync(String accountId) async {
    try {
      _logger.d('Checking network connectivity');
      if (await _networkInfo.isConnected) {
        _logger.d('Device is online, starting background sync');
        _logger.d('Starting background sync');
        
        final remoteCustomFields = await _remoteDataSource
            .getAccountCustomFields(accountId);

        _logger.d('Remote data source returned ${remoteCustomFields.length} custom fields');
        _logger.d('Caching remote data locally');
        
        // Update local cache
        await _localDataSource.cacheCustomFields(remoteCustomFields);

        // Convert to entities and add to stream for reactive UI update
        final entities = remoteCustomFields
            .map((model) => model.toEntity())
            .toList();
        
        _logger.d('Emitting updated data to stream');
        _customFieldsStreamController.add(entities);

        _logger.d('Background sync completed for account: $accountId');
      } else {
        _logger.d('Device is offline, skipping background sync');
      }
    } catch (e) {
      _logger.w('Background sync failed for account custom fields: $e');
    }
  }

  /// Dispose method to clean up stream controllers
  void dispose() {
    _customFieldsStreamController.close();
  }
}
