import 'dart:async';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import '../../../../../core/network/network_info.dart';
import '../../domain/entities/account_tag.dart';
import '../../domain/repositories/account_tags_repository.dart';
import '../datasources/remote/account_tags_remote_data_source.dart';
import '../datasources/local/account_tags_local_data_source.dart';
import '../models/account_tag_model.dart';

@Injectable(as: AccountTagsRepository)
class AccountTagsRepositoryImpl implements AccountTagsRepository {
  final AccountTagsRemoteDataSource _remoteDataSource;
  final AccountTagsLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;
  final Logger _logger;

  final StreamController<List<AccountTagAssignment>> _accountTagsController =
      StreamController<List<AccountTagAssignment>>.broadcast();

  AccountTagsRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
    this._networkInfo,
    this._logger,
  );

  @override
  Stream<List<AccountTagAssignment>> get accountTagsStream =>
      _accountTagsController.stream;

  @override
  Future<List<AccountTagAssignment>> getAccountTags(String accountId) async {
    try {
      _logger.d(
        '🔍 AccountTagsRepositoryImpl: getAccountTags called for accountId: $accountId',
      );

      // LOCAL-FIRST: Try to get cached data first for immediate UI response
      _logger.d(
        '🔍 AccountTagsRepositoryImpl: Getting cached tags from local data source',
      );
      final cachedTags = await _localDataSource.getCachedTagsForAccount(
        accountId,
      );
      _logger.d(
        '🔍 AccountTagsRepositoryImpl: Found ${cachedTags.length} cached tags',
      );

      // Convert to entities and emit immediately for instant UI response
      final entities = cachedTags.map((model) => model.toEntity()).toList();

      // Convert AccountTag entities to AccountTagAssignment entities
      final assignments = entities
          .map(
            (tag) => AccountTagAssignment(
              id: tag.id,
              accountId: accountId,
              tagId: tag.id,
              tagName: tag.name,
              tagColor: tag.color,
              tagIcon: tag.icon,
              assignedAt: tag.createdAt,
              assignedBy: tag.createdBy,
            ),
          )
          .toList();

      _logger.d(
        '🔍 AccountTagsRepositoryImpl: Emitting cached data to stream immediately',
      );
      _accountTagsController.add(assignments);

      _logger.d(
        '🔍 AccountTagsRepositoryImpl: Returning ${assignments.length} tag assignments from local cache',
      );

      // BACKGROUND SYNC: Check if device is online for background synchronization
      _logger.d('🔍 AccountTagsRepositoryImpl: Checking network connectivity');
      if (await _networkInfo.isConnected) {
        _logger.d(
          '🔍 AccountTagsRepositoryImpl: Device is online, starting background sync',
        );

        // Perform background sync without blocking the UI
        _performBackgroundSync(accountId);
      } else {
        _logger.d(
          '🔍 AccountTagsRepositoryImpl: Device is offline, using cached data only',
        );
      }

      return assignments;
    } catch (e) {
      _logger.e('🔍 AccountTagsRepositoryImpl: Error in getAccountTags: $e');
      _logger.e('Error getting account tags for account $accountId: $e');
      rethrow;
    }
  }

  /// Perform background synchronization with remote data source
  Future<void> _performBackgroundSync(String accountId) async {
    try {
      _logger.d('🔍 AccountTagsRepositoryImpl: Starting background sync');

      // Fetch fresh data from remote source
      final remoteTagModels = await _remoteDataSource.getAccountTags(accountId);
      _logger.d(
        '🔍 AccountTagsRepositoryImpl: Remote data source returned ${remoteTagModels.length} tag assignments',
      );

      // Cache the fresh data locally (this becomes the new source of truth)
      _logger.d('🔍 AccountTagsRepositoryImpl: Caching remote data locally');

      // Convert assignments to tag models and cache them
      final tagModels = <AccountTagModel>[];
      for (final assignment in remoteTagModels) {
        // Create a tag model from the assignment data
        final tagModel = AccountTagModel(
          id: assignment.tagDefinitionId,
          name: assignment.tagDefinitionName,
          description: null,
          color: null,
          icon: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          createdBy: 'System',
          isActive: true,
        );
        tagModels.add(tagModel);
      }
      await _localDataSource.cacheTags(tagModels);

      // Emit updated data to stream (UI will reactively update)
      final entities = remoteTagModels
          .map((model) => model.toEntity())
          .toList();
      _logger.d(
        '🔍 AccountTagsRepositoryImpl: Emitting updated data to stream',
      );
      _accountTagsController.add(entities);

      _logger.i(
        '🔍 AccountTagsRepositoryImpl: Background sync completed for account: $accountId',
      );
    } catch (e) {
      _logger.w(
        '🔍 AccountTagsRepositoryImpl: Background sync failed for account $accountId: $e',
      );
      _logger.w('Background sync failed for account $accountId: $e');
    }
  }

  @override
  Future<List<AccountTag>> getAllTags() async {
    try {
      // First, get data from local cache for immediate response
      final cachedTags = await _localDataSource.getCachedTags();

      // Emit cached data immediately for UI responsiveness
      if (cachedTags.isNotEmpty) {
        // Note: We can't emit to the stream here since it expects AccountTagAssignment
        // This is a limitation of the current stream design
      }

      // Check if device is online for background synchronization
      if (await _networkInfo.isConnected) {
        try {
          // Fetch fresh data from remote source
          final remoteTagModels = await _remoteDataSource.getAllTags();

          // Convert models to entities
          final remoteTags = remoteTagModels
              .map((model) => model.toEntity())
              .toList();

          // Cache the fresh data locally
          final tagModels = remoteTags
              .map((tag) => AccountTagModel.fromEntity(tag))
              .toList();
          await _localDataSource.cacheTags(tagModels);

          _logger.d('Synchronized all tags');
          return remoteTags;
        } catch (e) {
          _logger.w('Remote sync failed for all tags: $e');
          // Return cached data if remote sync fails
          if (cachedTags.isNotEmpty) {
            return cachedTags.map((model) => model.toEntity()).toList();
          }
          rethrow;
        }
      } else {
        _logger.d('Device offline, using cached tags');
        // Return cached data if offline
        if (cachedTags.isNotEmpty) {
          return cachedTags.map((model) => model.toEntity()).toList();
        }
        throw Exception('No cached data available and device is offline');
      }
    } catch (e) {
      _logger.e('Error getting all tags: $e');
      rethrow;
    }
  }

  @override
  Future<List<AccountTag>> getAllTagsForAccount(String accountId) async {
    try {
      // First, get data from local cache for immediate response
      final cachedTags = await _localDataSource.getCachedTagsForAccount(
        accountId,
      );

      // Check if device is online for background synchronization
      if (await _networkInfo.isConnected) {
        try {
          // Fetch fresh data from remote source
          final remoteTagModels = await _remoteDataSource.getAllTagsForAccount(
            accountId,
          );

          // Convert models to entities
          final remoteTags = remoteTagModels
              .map((model) => model.toEntity())
              .toList();

          // Cache the fresh data locally
          final tagModels = remoteTags
              .map((tag) => AccountTagModel.fromEntity(tag))
              .toList();
          await _localDataSource.cacheTags(tagModels);

          _logger.d('Synchronized tags for account: $accountId');
          return remoteTags;
        } catch (e) {
          _logger.w('Remote sync failed for tags for account $accountId: $e');
          // Return cached data if remote sync fails
          if (cachedTags.isNotEmpty) {
            return cachedTags.map((model) => model.toEntity()).toList();
          }
          rethrow;
        }
      } else {
        _logger.d('Device offline, using cached tags for account: $accountId');
        // Return cached data if offline
        if (cachedTags.isNotEmpty) {
          return cachedTags.map((model) => model.toEntity()).toList();
        }
        throw Exception('No cached data available and device is offline');
      }
    } catch (e) {
      _logger.e('Error getting tags for account $accountId: $e');
      rethrow;
    }
  }

  @override
  Future<AccountTag> createTag(AccountTag tag) async {
    try {
      // If online, create on remote first
      if (await _networkInfo.isConnected) {
        try {
          final remoteTagModel = await _remoteDataSource.createTag(
            AccountTagModel.fromEntity(tag),
          );

          // Cache the created tag locally
          await _localDataSource.cacheTag(remoteTagModel);

          _logger.d('Created tag ${remoteTagModel.id}');
          return remoteTagModel.toEntity();
        } catch (e) {
          _logger.w('Remote creation failed: $e');
          rethrow;
        }
      } else {
        throw Exception('Cannot create tag while offline');
      }
    } catch (e) {
      _logger.e('Error creating tag: $e');
      rethrow;
    }
  }

  @override
  Future<AccountTag> updateTag(AccountTag tag) async {
    try {
      // If online, update on remote first
      if (await _networkInfo.isConnected) {
        try {
          final remoteTagModel = await _remoteDataSource.updateTag(
            AccountTagModel.fromEntity(tag),
          );

          // Update local cache
          await _localDataSource.updateCachedTag(remoteTagModel);

          _logger.d('Updated tag ${remoteTagModel.id}');
          return remoteTagModel.toEntity();
        } catch (e) {
          _logger.w('Remote update failed: $e');
          rethrow;
        }
      } else {
        throw Exception('Cannot update tag while offline');
      }
    } catch (e) {
      _logger.e('Error updating tag: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteTag(String tagId) async {
    try {
      // If online, delete on remote first
      if (await _networkInfo.isConnected) {
        try {
          await _remoteDataSource.deleteTag(tagId);

          // Remove from local cache
          await _localDataSource.deleteCachedTag(tagId);

          _logger.d('Deleted tag $tagId');
        } catch (e) {
          _logger.w('Remote deletion failed: $e');
          rethrow;
        }
      } else {
        throw Exception('Cannot delete tag while offline');
      }
    } catch (e) {
      _logger.e('Error deleting tag $tagId: $e');
      rethrow;
    }
  }

  @override
  Future<AccountTagAssignment> assignTagToAccount(
    String accountId,
    String tagId,
  ) async {
    try {
      _logger.d(
        '🔍 AccountTagsRepositoryImpl: assignTagToAccount called for accountId: $accountId, tagId: $tagId',
      );

      // LOCAL-FIRST: Create optimistic assignment locally first
      _logger.d(
        '🔍 AccountTagsRepositoryImpl: Creating optimistic assignment locally',
      );
      final optimisticAssignment = AccountTagAssignment(
        id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
        accountId: accountId,
        tagId: tagId,
        tagName: 'Loading...', // Will be updated after sync
        tagColor: null,
        tagIcon: null,
        assignedAt: DateTime.now(),
        assignedBy: 'System',
      );

      // Create a temporary tag model for local caching
      final tempTagModel = AccountTagModel(
        id: tagId,
        name: 'Loading...',
        description: null,
        color: null,
        icon: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        createdBy: 'System',
        isActive: true,
      );

      // Cache the optimistic assignment locally
      await _localDataSource.cacheTag(tempTagModel);

      // Emit updated data immediately for instant UI response
      final currentTags = await _localDataSource.getCachedTagsForAccount(
        accountId,
      );
      final entities = currentTags.map((model) => model.toEntity()).toList();
      final assignments = entities
          .map(
            (tag) => AccountTagAssignment(
              id: tag.id,
              accountId: accountId,
              tagId: tag.id,
              tagName: tag.name,
              tagColor: tag.color,
              tagIcon: tag.icon,
              assignedAt: tag.createdAt,
              assignedBy: tag.createdBy,
            ),
          )
          .toList();
      _accountTagsController.add(assignments);

      _logger.d(
        '🔍 AccountTagsRepositoryImpl: Optimistic assignment created and cached',
      );

      // BACKGROUND SYNC: Sync with remote server
      if (await _networkInfo.isConnected) {
        _logger.d(
          '🔍 AccountTagsRepositoryImpl: Device is online, starting background sync',
        );
        _performBackgroundAssignTag(accountId, tagId);
      } else {
        _logger.d(
          '🔍 AccountTagsRepositoryImpl: Device is offline, assignment will sync when online',
        );
      }

      return optimisticAssignment;
    } catch (e) {
      _logger.e(
        '🔍 AccountTagsRepositoryImpl: Error in assignTagToAccount: $e',
      );
      _logger.e('Error assigning tag $tagId to account $accountId: $e');
      rethrow;
    }
  }

  /// Perform background tag assignment synchronization
  Future<void> _performBackgroundAssignTag(
    String accountId,
    String tagId,
  ) async {
    try {
      _logger.d(
        '🔍 AccountTagsRepositoryImpl: Starting background tag assignment sync',
      );

      // Assign on remote server
      final assignmentModel = await _remoteDataSource.assignTagToAccount(
        accountId,
        tagId,
      );

      // Update local cache with real assignment data
      final realTagModel = AccountTagModel(
        id: assignmentModel.tagDefinitionId,
        name: assignmentModel.tagDefinitionName,
        description: null,
        color: null,
        icon: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        createdBy: 'System',
        isActive: true,
      );
      await _localDataSource.updateCachedTag(realTagModel);

      // Emit updated data
      final currentTags = await _localDataSource.getCachedTagsForAccount(
        accountId,
      );
      final entities = currentTags.map((model) => model.toEntity()).toList();
      final assignments = entities
          .map(
            (tag) => AccountTagAssignment(
              id: tag.id,
              accountId: accountId,
              tagId: tag.id,
              tagName: tag.name,
              tagColor: tag.color,
              tagIcon: tag.icon,
              assignedAt: tag.createdAt,
              assignedBy: tag.createdBy,
            ),
          )
          .toList();
      _accountTagsController.add(assignments);

      _logger.i(
        '🔍 AccountTagsRepositoryImpl: Background tag assignment sync completed',
      );
    } catch (e) {
      _logger.w(
        '🔍 AccountTagsRepositoryImpl: Background tag assignment sync failed: $e',
      );
      _logger.w('Background tag assignment sync failed: $e');
    }
  }

  @override
  Future<List<AccountTagAssignment>> assignMultipleTagsToAccount(
    String accountId,
    List<String> tagIds,
  ) async {
    try {
      // If online, assign on remote first
      if (await _networkInfo.isConnected) {
        try {
          final assignmentModels = await _remoteDataSource
              .assignMultipleTagsToAccount(accountId, tagIds);

          // Convert models to entities
          final assignments = assignmentModels
              .map((model) => model.toEntity())
              .toList();

          // Note: We don't have local caching for assignments yet
          // In a full implementation, we'd cache the assignments

          // Emit updated data
          final currentTags = await getAccountTags(accountId);
          _accountTagsController.add(currentTags);

          _logger.d('Assigned ${tagIds.length} tags to account: $accountId');
          return assignments;
        } catch (e) {
          _logger.w('Remote multiple assignment failed: $e');
          rethrow;
        }
      } else {
        throw Exception('Cannot assign tags while offline');
      }
    } catch (e) {
      _logger.e('Error assigning tags to account $accountId: $e');
      rethrow;
    }
  }

  @override
  Future<void> removeTagFromAccount(String accountId, String tagId) async {
    try {
      _logger.d(
        '🔍 AccountTagsRepositoryImpl: removeTagFromAccount called for accountId: $accountId, tagId: $tagId',
      );

      // LOCAL-FIRST: Remove from local cache immediately
      _logger.d('🔍 AccountTagsRepositoryImpl: Removing tag from local cache');
      await _localDataSource.deleteCachedTag(tagId);

      // Emit updated data immediately for instant UI response
      final currentTags = await _localDataSource.getCachedTagsForAccount(
        accountId,
      );
      final entities = currentTags.map((model) => model.toEntity()).toList();
      final assignments = entities
          .map(
            (tag) => AccountTagAssignment(
              id: tag.id,
              accountId: accountId,
              tagId: tag.id,
              tagName: tag.name,
              tagColor: tag.color,
              tagIcon: tag.icon,
              assignedAt: tag.createdAt,
              assignedBy: tag.createdBy,
            ),
          )
          .toList();
      _accountTagsController.add(assignments);

      _logger.d('🔍 AccountTagsRepositoryImpl: Tag removed from local cache');

      // BACKGROUND SYNC: Sync with remote server
      if (await _networkInfo.isConnected) {
        _logger.d(
          '🔍 AccountTagsRepositoryImpl: Device is online, starting background sync',
        );
        _performBackgroundRemoveTag(accountId, tagId);
      } else {
        _logger.d(
          '🔍 AccountTagsRepositoryImpl: Device is offline, removal will sync when online',
        );
      }
    } catch (e) {
      _logger.e(
        '🔍 AccountTagsRepositoryImpl: Error in removeTagFromAccount: $e',
      );
      _logger.e('Error removing tag $tagId from account $accountId: $e');
      rethrow;
    }
  }

  /// Perform background tag removal synchronization
  Future<void> _performBackgroundRemoveTag(
    String accountId,
    String tagId,
  ) async {
    try {
      _logger.d(
        '🔍 AccountTagsRepositoryImpl: Starting background tag removal sync',
      );

      // Remove from remote server
      await _remoteDataSource.removeTagFromAccount(accountId, tagId);

      _logger.i(
        '🔍 AccountTagsRepositoryImpl: Background tag removal sync completed',
      );
    } catch (e) {
      _logger.w(
        '🔍 AccountTagsRepositoryImpl: Background tag removal sync failed: $e',
      );
      _logger.w('Background tag removal sync failed: $e');
    }
  }

  @override
  Future<void> removeMultipleTagsFromAccount(
    String accountId,
    List<String> tagIds,
  ) async {
    try {
      // If online, remove on remote first
      if (await _networkInfo.isConnected) {
        try {
          await _remoteDataSource.removeMultipleTagsFromAccount(
            accountId,
            tagIds,
          );

          // Note: We don't have local caching for assignments yet
          // In a full implementation, we'd remove the assignments from cache

          // Emit updated data
          final currentTags = await getAccountTags(accountId);
          _accountTagsController.add(currentTags);

          _logger.d('Removed ${tagIds.length} tags from account: $accountId');
        } catch (e) {
          _logger.w('Remote multiple removal failed: $e');
          rethrow;
        }
      } else {
        throw Exception('Cannot remove tags while offline');
      }
    } catch (e) {
      _logger.e('Error removing tags from account $accountId: $e');
      rethrow;
    }
  }

  @override
  Future<List<String>> getAccountsByTag(String tagId) async {
    try {
      // This method requires remote data and doesn't have local caching
      if (!await _networkInfo.isConnected) {
        throw Exception('Cannot get accounts by tag while offline');
      }

      try {
        // This would require a separate API endpoint
        // For now, return empty list as per original implementation
        _logger.d('getAccountsByTag not yet implemented');
        return [];
      } catch (e) {
        _logger.w('Remote fetch failed for accounts by tag: $e');
        rethrow;
      }
    } catch (e) {
      _logger.e('Error getting accounts by tag $tagId: $e');
      rethrow;
    }
  }

  /// Dispose of the stream controller
  void dispose() {
    _logger.d('🛑 [Account Tags Repository] Disposing resources...');
    if (!_accountTagsController.isClosed) {
      _accountTagsController.close();
      _logger.i('✅ [Account Tags Repository] StreamController closed');
    }
  }
}
