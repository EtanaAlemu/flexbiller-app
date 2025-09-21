import 'package:injectable/injectable.dart';
import '../entities/account_tag.dart';
import '../repositories/account_tags_repository.dart';

@injectable
class AssignTagToAccountUseCase {
  final AccountTagsRepository _tagsRepository;

  AssignTagToAccountUseCase(this._tagsRepository);

  Future<AccountTagAssignment> call({
    required String accountId,
    required String tagId,
  }) async {
    return await _tagsRepository.assignTagToAccount(accountId, tagId);
  }
}

