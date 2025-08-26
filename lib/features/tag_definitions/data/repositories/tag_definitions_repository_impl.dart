import 'package:injectable/injectable.dart';
import '../../domain/entities/tag_definition.dart';
import '../../domain/repositories/tag_definitions_repository.dart';
import '../datasources/tag_definitions_remote_data_source.dart';
import '../models/create_tag_definition_request_model.dart';

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
      final tagDefinitionModel = await _remoteDataSource.getTagDefinitionById(
        id,
      );
      return tagDefinitionModel.toEntity();
    } catch (e) {
      rethrow;
    }
  }
}
