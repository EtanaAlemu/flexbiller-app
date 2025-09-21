import 'package:injectable/injectable.dart';
import '../repositories/account_tags_repository.dart';

@injectable
class DeleteTagUseCase {
  final AccountTagsRepository _tagsRepository;

  DeleteTagUseCase(this._tagsRepository);

  Future<void> call(String tagId) async {
    return await _tagsRepository.deleteTag(tagId);
  }
}

