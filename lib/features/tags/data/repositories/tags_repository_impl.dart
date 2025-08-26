import 'package:injectable/injectable.dart';
import '../../domain/entities/tag.dart';
import '../../domain/repositories/tags_repository.dart';
import '../datasources/tags_remote_data_source.dart';

@Injectable(as: TagsRepository)
class TagsRepositoryImpl implements TagsRepository {
  final TagsRemoteDataSource _remoteDataSource;

  TagsRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<Tag>> getAllTags() async {
    try {
      final tagModels = await _remoteDataSource.getAllTags();
      return tagModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Tag>> searchTags(String tagDefinitionName, {int offset = 0, int limit = 100, String audit = 'NONE'}) async {
    try {
      final tagModels = await _remoteDataSource.searchTags(tagDefinitionName, offset: offset, limit: limit, audit: audit);
      return tagModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      rethrow;
    }
  }
}
