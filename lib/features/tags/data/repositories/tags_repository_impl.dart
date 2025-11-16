import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import '../../domain/entities/tag.dart';
import '../../domain/repositories/tags_repository.dart';
import '../datasources/tags_remote_data_source.dart';
import '../datasources/tags_local_data_source.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/errors/exceptions.dart';

@Injectable(as: TagsRepository)
class TagsRepositoryImpl implements TagsRepository {
  final TagsRemoteDataSource _remoteDataSource;
  final TagsLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;
  final Logger _logger = Logger();

  TagsRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
    this._networkInfo,
  );

  @override
  Future<List<Tag>> getAllTags() async {
    try {
      // First, try to get data from local cache
      final cachedTags = await _localDataSource.getCachedTags();

      // If we have cached data, return it immediately (local-first)
      if (cachedTags.isNotEmpty) {
        // Trigger background sync if online
        if (await _networkInfo.isConnected) {
          _syncTagsInBackground();
        }
        return cachedTags.map((model) => model.toEntity()).toList();
      }

      // If no cached data and online, fetch from remote
      if (await _networkInfo.isConnected) {
        final remoteTagModels = await _remoteDataSource.getAllTags();
        final tags = remoteTagModels.map((model) => model.toEntity()).toList();

        // Cache the remote data locally
        await _localDataSource.cacheTags(remoteTagModels);

        return tags;
      }

      // If offline and no cached data, return empty list
      return [];
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<Tag>> searchTags(
    String tagDefinitionName, {
    int offset = 0,
    int limit = 100,
    String audit = 'NONE',
  }) async {
    try {
      // First, try to search in local cache
      final cachedTags = await _localDataSource.searchCachedTags(
        tagDefinitionName,
      );

      // If we have cached results, return them (local-first)
      if (cachedTags.isNotEmpty) {
        // Trigger background sync if online
        if (await _networkInfo.isConnected) {
          _syncTagsInBackground();
        }
        return cachedTags.map((model) => model.toEntity()).toList();
      }

      // If no cached results and online, search remotely
      if (await _networkInfo.isConnected) {
        final remoteTagModels = await _remoteDataSource.searchTags(
          tagDefinitionName,
          offset: offset,
          limit: limit,
          audit: audit,
        );
        final tags = remoteTagModels.map((model) => model.toEntity()).toList();

        // Cache the remote data locally
        await _localDataSource.cacheTags(remoteTagModels);

        return tags;
      }

      // If offline and no cached data, return empty list
      return [];
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  // Background sync method
  Future<void> _syncTagsInBackground() async {
    try {
      if (await _networkInfo.isConnected) {
        final remoteTagModels = await _remoteDataSource.getAllTags();
        await _localDataSource.cacheTags(remoteTagModels);
      }
    } catch (e) {
      // Log error but don't throw - this is background sync
      _logger.w('Background sync failed: $e');
    }
  }
}
