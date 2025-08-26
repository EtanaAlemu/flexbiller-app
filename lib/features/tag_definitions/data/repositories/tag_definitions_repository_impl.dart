import 'package:injectable/injectable.dart';
import '../../domain/entities/tag_definition.dart';
import '../../domain/repositories/tag_definitions_repository.dart';
import '../datasources/tag_definitions_remote_data_source.dart';

@Injectable(as: TagDefinitionsRepository)
class TagDefinitionsRepositoryImpl implements TagDefinitionsRepository {
  final TagDefinitionsRemoteDataSource _remoteDataSource;

  TagDefinitionsRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<TagDefinition>> getTagDefinitions() async {
    try {
      final tagDefinitionModels = await _remoteDataSource.getTagDefinitions();
      return tagDefinitionModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      rethrow;
    }
  }
}
