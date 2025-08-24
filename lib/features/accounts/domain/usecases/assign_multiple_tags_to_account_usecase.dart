import 'package:injectable/injectable.dart';
import '../entities/account_tag.dart';
import '../repositories/account_tags_repository.dart';

@injectable
class AssignMultipleTagsToAccountUseCase {
  final AccountTagsRepository _tagsRepository;

  AssignMultipleTagsToAccountUseCase(this._tagsRepository);

  Future<List<AccountTagAssignment>> call(
    String accountId,
    List<String> tagIds,
  ) async {
    return await _tagsRepository.assignMultipleTagsToAccount(accountId, tagIds);
  }
}
