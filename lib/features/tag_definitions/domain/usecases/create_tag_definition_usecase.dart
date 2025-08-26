import 'package:injectable/injectable.dart';
import '../entities/tag_definition.dart';
import '../repositories/tag_definitions_repository.dart';

@injectable
class CreateTagDefinitionUseCase {
  final TagDefinitionsRepository _repository;

  CreateTagDefinitionUseCase(this._repository);

  Future<TagDefinition> call({
    required String name,
    required String description,
    required bool isControlTag,
    required List<String> applicableObjectTypes,
  }) async {
    return await _repository.createTagDefinition(
      name: name,
      description: description,
      isControlTag: isControlTag,
      applicableObjectTypes: applicableObjectTypes,
    );
  }
}
