import 'dart:async';
import '../../../../core/dao/tag_definitions_dao.dart';
import '../../../../core/services/database_service.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/tag_definition_model.dart';

abstract class TagDefinitionsLocalDataSource {
  Future<void> cacheTagDefinitions(List<TagDefinitionModel> tagDefinitions);
  Future<List<TagDefinitionModel>> getCachedTagDefinitions();
  Future<TagDefinitionModel?> getCachedTagDefinitionById(String id);
  Future<List<TagDefinitionModel>> searchCachedTagDefinitions(String query);
  Future<void> cacheTagDefinition(TagDefinitionModel tagDefinition);
  Future<void> updateCachedTagDefinition(TagDefinitionModel tagDefinition);
  Future<void> deleteCachedTagDefinition(String id);
  Future<void> deleteCachedTagDefinitions(List<String> ids);
  Future<void> clearAllCachedTagDefinitions();
  Future<bool> hasCachedTagDefinitions();
  Future<int> getCachedTagDefinitionsCount();
  Future<List<TagDefinitionModel>> getTagDefinitionsBySyncStatus(
    String syncStatus,
  );
  Future<void> updateSyncStatus(String id, String syncStatus);

  // Stream methods for reactive updates
  Stream<List<TagDefinitionModel>> watchTagDefinitions();
  Stream<TagDefinitionModel?> watchTagDefinitionById(String id);
  Stream<List<TagDefinitionModel>> watchSearchResults(String query);
}

class TagDefinitionsLocalDataSourceImpl
    implements TagDefinitionsLocalDataSource {
  final DatabaseService _databaseService;
  final Map<String, StreamController<List<TagDefinitionModel>>>
  _streamControllers = {};
  final Map<String, StreamController<TagDefinitionModel?>>
  _singleStreamControllers = {};

  TagDefinitionsLocalDataSourceImpl(this._databaseService);

  @override
  Future<void> cacheTagDefinitions(
    List<TagDefinitionModel> tagDefinitions,
  ) async {
    try {
      final db = await _databaseService.database;
      await TagDefinitionsDao.insertTagDefinitions(db, tagDefinitions);
    } catch (e) {
      throw CacheException('Error caching tag definitions: $e');
    }
  }

  @override
  Future<List<TagDefinitionModel>> getCachedTagDefinitions() async {
    try {
      final db = await _databaseService.database;
      return await TagDefinitionsDao.getAllTagDefinitions(db);
    } catch (e) {
      throw CacheException('Error getting cached tag definitions: $e');
    }
  }

  @override
  Future<TagDefinitionModel?> getCachedTagDefinitionById(String id) async {
    try {
      final db = await _databaseService.database;
      return await TagDefinitionsDao.getTagDefinitionById(db, id);
    } catch (e) {
      throw CacheException('Error getting cached tag definition by id: $e');
    }
  }

  @override
  Future<List<TagDefinitionModel>> searchCachedTagDefinitions(
    String query,
  ) async {
    try {
      final db = await _databaseService.database;
      return await TagDefinitionsDao.searchTagDefinitions(db, query);
    } catch (e) {
      throw CacheException('Error searching cached tag definitions: $e');
    }
  }

  @override
  Future<void> cacheTagDefinition(TagDefinitionModel tagDefinition) async {
    try {
      final db = await _databaseService.database;
      await TagDefinitionsDao.insertTagDefinition(db, tagDefinition);
    } catch (e) {
      throw CacheException('Error caching tag definition: $e');
    }
  }

  @override
  Future<void> updateCachedTagDefinition(
    TagDefinitionModel tagDefinition,
  ) async {
    try {
      final db = await _databaseService.database;
      await TagDefinitionsDao.updateTagDefinition(db, tagDefinition);
    } catch (e) {
      throw CacheException('Error updating cached tag definition: $e');
    }
  }

  @override
  Future<void> deleteCachedTagDefinition(String id) async {
    try {
      final db = await _databaseService.database;
      await TagDefinitionsDao.deleteTagDefinition(db, id);
    } catch (e) {
      throw CacheException('Error deleting cached tag definition: $e');
    }
  }

  @override
  Future<void> deleteCachedTagDefinitions(List<String> ids) async {
    try {
      final db = await _databaseService.database;
      await TagDefinitionsDao.deleteTagDefinitions(db, ids);
    } catch (e) {
      throw CacheException('Error deleting cached tag definitions: $e');
    }
  }

  @override
  Future<void> clearAllCachedTagDefinitions() async {
    try {
      final db = await _databaseService.database;
      await TagDefinitionsDao.clearAllTagDefinitions(db);
    } catch (e) {
      throw CacheException('Error clearing all cached tag definitions: $e');
    }
  }

  @override
  Future<bool> hasCachedTagDefinitions() async {
    try {
      final count = await getCachedTagDefinitionsCount();
      return count > 0;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<int> getCachedTagDefinitionsCount() async {
    try {
      final db = await _databaseService.database;
      return await TagDefinitionsDao.getTagDefinitionsCount(db);
    } catch (e) {
      throw CacheException('Error getting cached tag definitions count: $e');
    }
  }

  @override
  Future<List<TagDefinitionModel>> getTagDefinitionsBySyncStatus(
    String syncStatus,
  ) async {
    try {
      final db = await _databaseService.database;
      return await TagDefinitionsDao.getTagDefinitionsBySyncStatus(
        db,
        syncStatus,
      );
    } catch (e) {
      throw CacheException('Error getting tag definitions by sync status: $e');
    }
  }

  @override
  Future<void> updateSyncStatus(String id, String syncStatus) async {
    try {
      final db = await _databaseService.database;
      await TagDefinitionsDao.updateSyncStatus(db, id, syncStatus);
    } catch (e) {
      throw CacheException('Error updating sync status: $e');
    }
  }

  @override
  Stream<List<TagDefinitionModel>> watchTagDefinitions() {
    const key = 'all';
    if (!_streamControllers.containsKey(key)) {
      _streamControllers[key] =
          StreamController<List<TagDefinitionModel>>.broadcast();
      _startWatchingTagDefinitions(key);
    }
    return _streamControllers[key]!.stream;
  }

  @override
  Stream<TagDefinitionModel?> watchTagDefinitionById(String id) {
    if (!_singleStreamControllers.containsKey(id)) {
      _singleStreamControllers[id] =
          StreamController<TagDefinitionModel?>.broadcast();
      _startWatchingTagDefinitionById(id);
    }
    return _singleStreamControllers[id]!.stream;
  }

  @override
  Stream<List<TagDefinitionModel>> watchSearchResults(String query) {
    final key = 'search_$query';
    if (!_streamControllers.containsKey(key)) {
      _streamControllers[key] =
          StreamController<List<TagDefinitionModel>>.broadcast();
      _startWatchingSearchResults(key, query);
    }
    return _streamControllers[key]!.stream;
  }

  void _startWatchingTagDefinitions(String key) async {
    try {
      final db = await _databaseService.database;
      await for (final tagDefinitions in TagDefinitionsDao.watchTagDefinitions(
        db,
      )) {
        if (!_streamControllers[key]!.isClosed) {
          _streamControllers[key]!.add(tagDefinitions);
        }
      }
    } catch (e) {
      if (!_streamControllers[key]!.isClosed) {
        _streamControllers[key]!.addError(e);
      }
    }
  }

  void _startWatchingTagDefinitionById(String id) async {
    try {
      final db = await _databaseService.database;
      await for (final tagDefinitions in TagDefinitionsDao.watchTagDefinitions(
        db,
      )) {
        final tagDefinition = tagDefinitions.firstWhere(
          (td) => td.id == id,
          orElse: () => throw StateError('Tag definition not found'),
        );
        if (!_singleStreamControllers[id]!.isClosed) {
          _singleStreamControllers[id]!.add(tagDefinition);
        }
      }
    } catch (e) {
      if (!_singleStreamControllers[id]!.isClosed) {
        _singleStreamControllers[id]!.add(null);
      }
    }
  }

  void _startWatchingSearchResults(String key, String query) async {
    try {
      final db = await _databaseService.database;
      await for (final tagDefinitions
          in TagDefinitionsDao.watchTagDefinitionsBySearchQuery(db, query)) {
        if (!_streamControllers[key]!.isClosed) {
          _streamControllers[key]!.add(tagDefinitions);
        }
      }
    } catch (e) {
      if (!_streamControllers[key]!.isClosed) {
        _streamControllers[key]!.addError(e);
      }
    }
  }

  void dispose() {
    for (final controller in _streamControllers.values) {
      controller.close();
    }
    for (final controller in _singleStreamControllers.values) {
      controller.close();
    }
    _streamControllers.clear();
    _singleStreamControllers.clear();
  }
}
