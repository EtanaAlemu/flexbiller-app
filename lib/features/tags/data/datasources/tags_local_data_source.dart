import 'dart:async';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import '../../../../core/dao/tags_dao.dart';
import '../../../../core/services/database_service.dart';
import '../models/tag_model.dart';

abstract class TagsLocalDataSource {
  Future<void> cacheTags(List<TagModel> tags);
  Future<List<TagModel>> getCachedTags();
  Future<TagModel?> getCachedTagById(String tagId);
  Future<List<TagModel>> searchCachedTags(String searchQuery);
  Future<void> cacheTag(TagModel tag);
  Future<void> updateCachedTag(TagModel tag);
  Future<void> deleteCachedTag(String tagId);
  Future<void> deleteCachedTags(List<String> tagIds);
  Future<void> clearAllCachedTags();
  Future<bool> hasCachedTags();
  Future<int> getCachedTagsCount();
  Future<List<TagModel>> getCachedTagsBySyncStatus(String syncStatus);
  Future<void> updateSyncStatus(List<String> tagIds, String syncStatus);

  // Reactive stream methods for real-time updates
  Stream<List<TagModel>> watchTags();
  Stream<TagModel?> watchTagById(String tagId);
  Stream<List<TagModel>> watchSearchResults(String searchQuery);
}

@Injectable(as: TagsLocalDataSource)
class TagsLocalDataSourceImpl implements TagsLocalDataSource {
  final DatabaseService _databaseService;
  final Logger _logger = Logger();

  // Stream controllers for reactive updates
  final StreamController<List<TagModel>> _tagsStreamController =
      StreamController<List<TagModel>>.broadcast();
  final StreamController<Map<String, TagModel>> _tagByIdStreamController =
      StreamController<Map<String, TagModel>>.broadcast();
  final StreamController<Map<String, List<TagModel>>> _searchStreamController =
      StreamController<Map<String, List<TagModel>>>.broadcast();

  TagsLocalDataSourceImpl(this._databaseService);

  @override
  Future<void> cacheTags(List<TagModel> tags) async {
    try {
      final db = await _databaseService.database;
      final tagMaps = tags.map((tag) => tag.toJson()).toList();
      await TagsDao.insertTags(db, tagMaps);

      _logger.d('Cached ${tags.length} tags locally');

      // Emit updated tags to stream
      _tagsStreamController.add(tags);
    } catch (e) {
      _logger.e('Error caching tags: $e');
      rethrow;
    }
  }

  @override
  Future<List<TagModel>> getCachedTags() async {
    try {
      final db = await _databaseService.database;
      final tagMaps = await TagsDao.getAllTags(db);
      
      _logger.d('Raw database maps: $tagMaps');
      
      final tags = tagMaps.map((map) {
        _logger.d('Converting map: $map');
        return TagModel.fromJson(map);
      }).toList();

      _logger.d('Retrieved ${tags.length} cached tags');
      return tags;
    } catch (e) {
      _logger.e('Error getting cached tags: $e');
      rethrow;
    }
  }

  @override
  Future<TagModel?> getCachedTagById(String tagId) async {
    try {
      final db = await _databaseService.database;
      final tagMap = await TagsDao.getTagById(db, tagId);

      if (tagMap != null) {
        final tag = TagModel.fromJson(tagMap);
        _logger.d('Retrieved cached tag: $tagId');
        return tag;
      }

      _logger.d('No cached tag found for ID: $tagId');
      return null;
    } catch (e) {
      _logger.e('Error getting cached tag by ID: $e');
      rethrow;
    }
  }

  @override
  Future<List<TagModel>> searchCachedTags(String searchQuery) async {
    try {
      final db = await _databaseService.database;
      final tagMaps = await TagsDao.searchTags(db, searchQuery);
      final tags = tagMaps.map((map) => TagModel.fromJson(map)).toList();

      _logger.d('Found ${tags.length} cached tags for search: $searchQuery');
      return tags;
    } catch (e) {
      _logger.e('Error searching cached tags: $e');
      rethrow;
    }
  }

  @override
  Future<void> cacheTag(TagModel tag) async {
    try {
      final db = await _databaseService.database;
      await TagsDao.insertTag(db, tag.toJson());

      _logger.d('Cached tag: ${tag.tagId}');

      // Emit updated tags to stream
      final allTags = await getCachedTags();
      _tagsStreamController.add(allTags);
    } catch (e) {
      _logger.e('Error caching tag: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateCachedTag(TagModel tag) async {
    try {
      final db = await _databaseService.database;
      await TagsDao.updateTag(db, tag.toJson());

      _logger.d('Updated cached tag: ${tag.tagId}');

      // Emit updated tags to stream
      final allTags = await getCachedTags();
      _tagsStreamController.add(allTags);
    } catch (e) {
      _logger.e('Error updating cached tag: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteCachedTag(String tagId) async {
    try {
      final db = await _databaseService.database;
      await TagsDao.deleteTag(db, tagId);

      _logger.d('Deleted cached tag: $tagId');

      // Emit updated tags to stream
      final allTags = await getCachedTags();
      _tagsStreamController.add(allTags);
    } catch (e) {
      _logger.e('Error deleting cached tag: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteCachedTags(List<String> tagIds) async {
    try {
      final db = await _databaseService.database;
      await TagsDao.deleteTags(db, tagIds);

      _logger.d('Deleted ${tagIds.length} cached tags');

      // Emit updated tags to stream
      final allTags = await getCachedTags();
      _tagsStreamController.add(allTags);
    } catch (e) {
      _logger.e('Error deleting cached tags: $e');
      rethrow;
    }
  }

  @override
  Future<void> clearAllCachedTags() async {
    try {
      final db = await _databaseService.database;
      await TagsDao.clearAllTags(db);

      _logger.d('Cleared all cached tags');

      // Emit empty list to stream
      _tagsStreamController.add([]);
    } catch (e) {
      _logger.e('Error clearing cached tags: $e');
      rethrow;
    }
  }

  @override
  Future<bool> hasCachedTags() async {
    try {
      final count = await getCachedTagsCount();
      return count > 0;
    } catch (e) {
      _logger.e('Error checking cached tags: $e');
      return false;
    }
  }

  @override
  Future<int> getCachedTagsCount() async {
    try {
      final db = await _databaseService.database;
      return await TagsDao.getTagsCount(db);
    } catch (e) {
      _logger.e('Error getting cached tags count: $e');
      return 0;
    }
  }

  @override
  Future<List<TagModel>> getCachedTagsBySyncStatus(String syncStatus) async {
    try {
      final db = await _databaseService.database;
      final tagMaps = await TagsDao.getTagsBySyncStatus(db, syncStatus);
      final tags = tagMaps.map((map) => TagModel.fromJson(map)).toList();

      _logger.d(
        'Retrieved ${tags.length} cached tags with sync status: $syncStatus',
      );
      return tags;
    } catch (e) {
      _logger.e('Error getting cached tags by sync status: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateSyncStatus(List<String> tagIds, String syncStatus) async {
    try {
      final db = await _databaseService.database;
      await TagsDao.updateSyncStatus(db, tagIds, syncStatus);

      _logger.d(
        'Updated sync status for ${tagIds.length} tags to: $syncStatus',
      );

      // Emit updated tags to stream
      final allTags = await getCachedTags();
      _tagsStreamController.add(allTags);
    } catch (e) {
      _logger.e('Error updating sync status: $e');
      rethrow;
    }
  }

  @override
  Stream<List<TagModel>> watchTags() {
    return _tagsStreamController.stream;
  }

  @override
  Stream<TagModel?> watchTagById(String tagId) {
    return _tagByIdStreamController.stream.map((map) => map[tagId]).distinct();
  }

  @override
  Stream<List<TagModel>> watchSearchResults(String searchQuery) {
    return _searchStreamController.stream
        .map((map) => map[searchQuery] ?? [])
        .distinct();
  }

  // Dispose method to close stream controllers
  void dispose() {
    _tagsStreamController.close();
    _tagByIdStreamController.close();
    _searchStreamController.close();
  }
}
