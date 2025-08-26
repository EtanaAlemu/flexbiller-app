import 'package:injectable/injectable.dart';
import '../entities/tag.dart';
import '../repositories/tags_repository.dart';

@injectable
class GetAllTagsUseCase {
  final TagsRepository _repository;

  GetAllTagsUseCase(this._repository);

  Future<List<Tag>> call() async {
    return await _repository.getAllTags();
  }
}
