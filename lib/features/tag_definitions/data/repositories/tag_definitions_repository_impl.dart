import 'package:injectable/injectable.dart';
import '../../domain/entities/tag_definition.dart';
import '../../domain/entities/tag_definition_audit_log.dart';
import '../../domain/repositories/tag_definitions_repository.dart';
import '../datasources/tag_definitions_remote_data_source.dart';
import '../datasources/tag_definitions_local_data_source.dart';
import '../models/create_tag_definition_request_model.dart';
import '../models/tag_definition_model.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/errors/exceptions.dart';

@Injectable(as: TagDefinitionsRepository)
class TagDefinitionsRepositoryImpl implements TagDefinitionsRepository {
  final TagDefinitionsRemoteDataSource _remoteDataSource;
  final TagDefinitionsLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;

  TagDefinitionsRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
    this._networkInfo,
  );

  @override
  Future<List<TagDefinition>> getTagDefinitions() async {
    try {
      // 1. Try to get data from local cache first
      final cachedTagDefinitions = await _localDataSource
          .getCachedTagDefinitions();

      if (cachedTagDefinitions.isNotEmpty) {
        // Return cached data immediately and sync in background if online
        if (await _networkInfo.isConnected) {
          _syncTagDefinitionsInBackground();
        }
        return cachedTagDefinitions.map((model) => model.toEntity()).toList();
      }

      // 2. If no cached data and online, fetch from remote
      if (await _networkInfo.isConnected) {
        final tagDefinitionModels = await _remoteDataSource.getTagDefinitions();

        // Cache the data locally
        await _localDataSource.cacheTagDefinitions(tagDefinitionModels);

        return tagDefinitionModels.map((model) => model.toEntity()).toList();
      }

      // 3. If offline and no cached data, return empty list
      return [];
    } catch (e) {
      // If remote fails but we have cached data, return cached data
      try {
        final cachedTagDefinitions = await _localDataSource
            .getCachedTagDefinitions();
        return cachedTagDefinitions.map((model) => model.toEntity()).toList();
      } catch (cacheError) {
        rethrow;
      }
    }
  }

  // Background sync method
  Future<void> _syncTagDefinitionsInBackground() async {
    try {
      final tagDefinitionModels = await _remoteDataSource.getTagDefinitions();
      await _localDataSource.cacheTagDefinitions(tagDefinitionModels);
    } catch (e) {
      // Silently fail background sync - don't throw errors
    }
  }

  @override
  Future<TagDefinition> createTagDefinition({
    required String name,
    required String description,
    required bool isControlTag,
    required List<String> applicableObjectTypes,
  }) async {
    try {
      final request = CreateTagDefinitionRequestModel(
        name: name,
        description: description,
        isControlTag: isControlTag,
        applicableObjectTypes: applicableObjectTypes,
      );

      final tagDefinitionModel = await _remoteDataSource.createTagDefinition(
        request,
      );

      return tagDefinitionModel.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<TagDefinition> getTagDefinitionById(String id) async {
    try {
      // 1. Try to get from local cache first
      final cachedTagDefinition = await _localDataSource
          .getCachedTagDefinitionById(id);

      if (cachedTagDefinition != null) {
        // Return cached data and sync in background if online
        if (await _networkInfo.isConnected) {
          _syncTagDefinitionsInBackground();
        }
        return cachedTagDefinition.toEntity();
      }

      // 2. If not in cache and online, fetch from remote
      if (await _networkInfo.isConnected) {
        final tagDefinitionModel = await _remoteDataSource.getTagDefinitionById(
          id,
        );

        // Cache the data locally
        await _localDataSource.cacheTagDefinition(tagDefinitionModel);

        return tagDefinitionModel.toEntity();
      }

      // 3. If offline and not in cache, throw exception
      throw CacheException(
        'Tag definition not found in cache and device is offline',
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<TagDefinitionAuditLog>> getTagDefinitionAuditLogsWithHistory(
    String id,
  ) async {
    try {
      final auditLogModels = await _remoteDataSource
          .getTagDefinitionAuditLogsWithHistory(id);
      return auditLogModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteTagDefinition(String id) async {
    try {
      await _remoteDataSource.deleteTagDefinition(id);

      // Remove from local cache
      await _localDataSource.deleteCachedTagDefinition(id);
    } catch (e) {
      rethrow;
    }
  }
}
