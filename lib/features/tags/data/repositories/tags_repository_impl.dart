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
}
