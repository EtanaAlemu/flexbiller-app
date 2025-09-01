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
      // For now, we'll use a simplified approach since we don't have full tag assignment caching
      // This method will primarily rely on remote data with basic local caching

      // Check if device is online for data synchronization
      if (await _networkInfo.isConnected) {
        try {
          // Fetch fresh data from remote source
          final remoteTagModels = await _remoteDataSource.getAccountTags(
            accountId,
          );

          // Convert models to entities
          final remoteTags = remoteTagModels
              .map((model) => model.toEntity())
              .toList();

          // Cache the tag definitions locally (not the assignments yet)
          // This is a simplified approach - in a full implementation, we'd cache assignments
          // For now, we'll extract the tag information from assignments and cache them
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

          // Emit updated data
          _accountTagsController.add(remoteTags);

          _logger.d('Synchronized account tags for account: $accountId');
          return remoteTags;
        } catch (e) {
          _logger.w('Remote sync failed for account $accountId: $e');
          rethrow;
        }
      } else {
        _logger.d(
          'Device offline, attempting to use cached tags for account: $accountId',
        );
        // Try to get cached tags as fallback
        final cachedTags = await _localDataSource.getCachedTagsForAccount(
          accountId,
        );
        if (cachedTags.isNotEmpty) {
          // Convert cached tags to assignments (simplified)
          final assignments = cachedTags
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
          return assignments;
        }
        throw Exception('No cached data available and device is offline');
      }
    } catch (e) {
      _logger.e('Error getting account tags for account $accountId: $e');
      rethrow;
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
      // If online, assign on remote first
      if (await _networkInfo.isConnected) {
        try {
          final assignmentModel = await _remoteDataSource.assignTagToAccount(
            accountId,
            tagId,
          );

          // Convert model to entity
          final assignment = assignmentModel.toEntity();

          // Note: We don't have local caching for assignments yet
          // In a full implementation, we'd cache the assignment

          // Emit updated data
          final currentTags = await getAccountTags(accountId);
          _accountTagsController.add(currentTags);

          _logger.d('Assigned tag $tagId to account: $accountId');
          return assignment;
        } catch (e) {
          _logger.w('Remote assignment failed: $e');
          rethrow;
        }
      } else {
        throw Exception('Cannot assign tag while offline');
      }
    } catch (e) {
      _logger.e('Error assigning tag $tagId to account $accountId: $e');
      rethrow;
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
      // If online, remove on remote first
      if (await _networkInfo.isConnected) {
        try {
          await _remoteDataSource.removeTagFromAccount(accountId, tagId);

          // Note: We don't have local caching for assignments yet
          // In a full implementation, we'd remove the assignment from cache

          // Emit updated data
          final currentTags = await getAccountTags(accountId);
          _accountTagsController.add(currentTags);

          _logger.d('Removed tag $tagId from account: $accountId');
        } catch (e) {
          _logger.w('Remote removal failed: $e');
          rethrow;
        }
      } else {
        throw Exception('Cannot remove tag while offline');
      }
    } catch (e) {
      _logger.e('Error removing tag $tagId from account $accountId: $e');
      rethrow;
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
    _accountTagsController.close();
  }
}
