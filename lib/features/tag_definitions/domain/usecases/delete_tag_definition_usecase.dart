import 'package:injectable/injectable.dart';
import '../repositories/tag_definitions_repository.dart';

@injectable
class DeleteTagDefinitionUseCase {
  final TagDefinitionsRepository _repository;

  DeleteTagDefinitionUseCase(this._repository);

  Future<void> call(String id) async {
    return await _repository.deleteTagDefinition(id);
  }
}
