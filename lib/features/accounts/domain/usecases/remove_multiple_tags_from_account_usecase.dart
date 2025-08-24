import 'package:injectable/injectable.dart';
import '../repositories/account_tags_repository.dart';

@injectable
class RemoveMultipleTagsFromAccountUseCase {
  final AccountTagsRepository _tagsRepository;

  RemoveMultipleTagsFromAccountUseCase(this._tagsRepository);

  Future<void> call(String accountId, List<String> tagIds) async {
    return await _tagsRepository.removeMultipleTagsFromAccount(accountId, tagIds);
  }
}
