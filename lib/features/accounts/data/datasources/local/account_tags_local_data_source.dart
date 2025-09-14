import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import '../../../../../core/dao/account_tag_dao.dart';
import '../../../../../core/services/database_service.dart';
import '../../../../../core/services/user_session_service.dart';
import '../../models/account_tag_model.dart';

abstract class AccountTagsLocalDataSource {
  // Tag management
  Future<void> cacheTags(List<AccountTagModel> tags);
  Future<void> cacheTag(AccountTagModel tag);
  Future<List<AccountTagModel>> getCachedTags();
  Future<AccountTagModel?> getCachedTag(String tagId);
  Future<List<AccountTagModel>> getCachedTagsForAccount(String accountId);
  Future<void> updateCachedTag(AccountTagModel tag);
  Future<void> deleteCachedTag(String tagId);
  Future<void> clearAllCachedTags();

  // Utility methods
  Future<bool> hasCachedTags(String accountId);
  Future<int> getCachedTagsCount(String accountId);
  Future<int> getTotalCachedTagsCount();
}

@Injectable(as: AccountTagsLocalDataSource)
class AccountTagsLocalDataSourceImpl implements AccountTagsLocalDataSource {
  final DatabaseService _databaseService;
  final UserSessionService _userSessionService;
  final Logger _logger = Logger();

  AccountTagsLocalDataSourceImpl(
    this._databaseService,
    this._userSessionService,
  );

  // Tag management methods
  @override
  Future<void> cacheTags(List<AccountTagModel> tags) async {
    try {
      // Check for user context and restore if needed
      var currentUserId = _userSessionService.getCurrentUserIdOrNull();
      if (currentUserId == null) {
        _logger.w('No active user context, attempting to restore user context');
        try {
          await _userSessionService.restoreCurrentUserContext();
          currentUserId = _userSessionService.getCurrentUserIdOrNull();
          if (currentUserId == null) {
            _logger.w('Failed to restore user context, skipping tag caching');
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

      // Use a transaction for better performance
      await db.transaction((txn) async {
        for (final tag in tags) {
          final tagData = tag.toJson();
          tagData['syncStatus'] = 'synced';

          await AccountTagDao.insertTag(txn, tagData);
        }
      });

      _logger.d('Cached ${tags.length} tags successfully');
    } catch (e) {
      _logger.e('Error caching tags: $e');
      rethrow;
    }
  }

  @override
  Future<void> cacheTag(AccountTagModel tag) async {
    try {
      final db = await _databaseService.database;

      final tagData = tag.toJson();
      tagData['syncStatus'] = 'synced';

      await AccountTagDao.insertTag(db, tagData);

      _logger.d('Cached tag: ${tag.id} successfully');
    } catch (e) {
      _logger.e('Error caching tag: ${tag.id} - $e');
      rethrow;
    }
  }

  @override
  Future<List<AccountTagModel>> getCachedTags() async {
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
              'Failed to restore user context, returning empty tags list',
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
      final tagsData = await AccountTagDao.getAllTags(db);

      final tags = tagsData
          .map((data) => AccountTagModel.fromJson(data))
          .where((tag) => tag != null)
          .cast<AccountTagModel>()
          .toList();

      _logger.d('Retrieved ${tags.length} cached tags');
      return tags;
    } catch (e) {
      _logger.w('Error retrieving cached tags: $e');
      // Return empty list if there's an error (e.g., table doesn't exist yet)
      return [];
    }
  }

  @override
  Future<AccountTagModel?> getCachedTag(String tagId) async {
    try {
      final db = await _databaseService.database;
      final tagData = await AccountTagDao.getTagById(db, tagId);

      if (tagData != null) {
        final tag = AccountTagModel.fromJson(tagData);
        _logger.d('Retrieved cached tag: $tagId');
        return tag;
      }

      _logger.d('No cached tag found for: $tagId');
      return null;
    } catch (e) {
      _logger.w('Error retrieving cached tag: $tagId - $e');
      return null;
    }
  }

  @override
  Future<List<AccountTagModel>> getCachedTagsForAccount(
    String accountId,
  ) async {
    try {
      final db = await _databaseService.database;
      final tagsData = await AccountTagDao.getTagsByAccount(db, accountId);

      final tags = tagsData
          .map((data) => AccountTagModel.fromJson(data))
          .where((tag) => tag != null)
          .cast<AccountTagModel>()
          .toList();

      _logger.d('Retrieved ${tags.length} cached tags for account: $accountId');
      return tags;
    } catch (e) {
      _logger.w('Error retrieving cached tags for account: $accountId - $e');
      // Return empty list if there's an error
      return [];
    }
  }

  @override
  Future<void> updateCachedTag(AccountTagModel tag) async {
    try {
      final db = await _databaseService.database;

      final tagData = tag.toJson();
      tagData['syncStatus'] = 'synced';

      await AccountTagDao.updateTag(db, tagData);

      _logger.d('Updated cached tag: ${tag.id} successfully');
    } catch (e) {
      _logger.e('Error updating cached tag: ${tag.id} - $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteCachedTag(String tagId) async {
    try {
      final db = await _databaseService.database;
      await AccountTagDao.deleteTag(db, tagId);

      _logger.d('Deleted cached tag: $tagId successfully');
    } catch (e) {
      _logger.e('Error deleting cached tag: $tagId - $e');
      rethrow;
    }
  }

  @override
  Future<void> clearAllCachedTags() async {
    try {
      final db = await _databaseService.database;
      await db.delete(AccountTagDao.tableName);

      _logger.d('Cleared all cached tags successfully');
    } catch (e) {
      _logger.e('Error clearing cached tags: $e');
      rethrow;
    }
  }

  // Utility methods
  @override
  Future<bool> hasCachedTags(String accountId) async {
    try {
      final count = await getCachedTagsCount(accountId);
      final hasTags = count > 0;
      _logger.d('Account $accountId has cached tags: $hasTags');
      return hasTags;
    } catch (e) {
      _logger.e('Error checking if account $accountId has cached tags: $e');
      return false;
    }
  }

  @override
  Future<int> getCachedTagsCount(String accountId) async {
    try {
      final db = await _databaseService.database;
      // For now, return total count since we don't have account-specific tag counting
      final allTags = await AccountTagDao.getAllTags(db);
      final count = allTags.length;
      _logger.d('Retrieved cached tags count for account $accountId: $count');
      return count;
    } catch (e) {
      _logger.e(
        'Error retrieving cached tags count for account $accountId: $e',
      );
      return 0;
    }
  }

  @override
  Future<int> getTotalCachedTagsCount() async {
    try {
      final db = await _databaseService.database;
      final allTags = await AccountTagDao.getAllTags(db);
      final count = allTags.length;
      _logger.d('Retrieved total cached tags count: $count');
      return count;
    } catch (e) {
      _logger.e('Error retrieving total cached tags count: $e');
      return 0;
    }
  }
}
