import 'package:injectable/injectable.dart';
import '../entities/account_tag.dart';
import '../repositories/account_tags_repository.dart';

@injectable
class GetAllTagsForAccountUseCase {
  final AccountTagsRepository _tagsRepository;

  GetAllTagsForAccountUseCase(this._tagsRepository);

  Future<List<AccountTag>> call(String accountId) async {
    return await _tagsRepository.getAllTagsForAccount(accountId);
  }
}
