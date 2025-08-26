import 'package:injectable/injectable.dart';
import '../entities/tag.dart';
import '../repositories/tags_repository.dart';

@injectable
class SearchTagsUseCase {
  final TagsRepository _repository;

  SearchTagsUseCase(this._repository);

  Future<List<Tag>> call(String tagDefinitionName, {int offset = 0, int limit = 100, String audit = 'NONE'}) async {
    return await _repository.searchTags(tagDefinitionName, offset: offset, limit: limit, audit: audit);
  }
}
