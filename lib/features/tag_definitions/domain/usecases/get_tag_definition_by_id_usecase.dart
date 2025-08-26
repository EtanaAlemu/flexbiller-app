import 'package:injectable/injectable.dart';
import '../entities/tag_definition.dart';
import '../repositories/tag_definitions_repository.dart';

@injectable
class GetTagDefinitionByIdUseCase {
  final TagDefinitionsRepository _repository;

  GetTagDefinitionByIdUseCase(this._repository);

  Future<TagDefinition> call(String id) async {
    return await _repository.getTagDefinitionById(id);
  }
}
