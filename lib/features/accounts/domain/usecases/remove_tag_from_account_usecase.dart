import 'package:injectable/injectable.dart';
import '../repositories/account_tags_repository.dart';

@injectable
class RemoveTagFromAccountUseCase {
  final AccountTagsRepository _tagsRepository;

  RemoveTagFromAccountUseCase(this._tagsRepository);

  Future<void> call({required String accountId, required String tagId}) async {
    return await _tagsRepository.removeTagFromAccount(accountId, tagId);
  }
}

