import 'package:injectable/injectable.dart';
import '../entities/tag_definition.dart';
import '../repositories/tag_definitions_repository.dart';

@injectable
class GetTagDefinitionsUseCase {
  final TagDefinitionsRepository _repository;

  GetTagDefinitionsUseCase(this._repository);

  Future<List<TagDefinition>> call() async {
    return await _repository.getTagDefinitions();
  }
}
