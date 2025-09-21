import 'package:injectable/injectable.dart';
import '../entities/account_tag.dart';
import '../repositories/account_tags_repository.dart';

@injectable
class RefreshAccountTagsUseCase {
  final AccountTagsRepository _tagsRepository;

  RefreshAccountTagsUseCase(this._tagsRepository);

  Future<List<AccountTagAssignment>> call(String accountId) async {
    return await _tagsRepository.getAccountTags(accountId);
  }
}

