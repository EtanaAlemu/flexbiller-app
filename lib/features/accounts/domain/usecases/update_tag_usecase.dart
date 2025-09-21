import 'package:injectable/injectable.dart';
import '../entities/account_tag.dart';
import '../repositories/account_tags_repository.dart';

@injectable
class UpdateTagUseCase {
  final AccountTagsRepository _tagsRepository;

  UpdateTagUseCase(this._tagsRepository);

  Future<AccountTag> call({
    required String tagId,
    required String name,
    String? description,
    String? color,
    String? icon,
  }) async {
    final tag = AccountTag(
      id: tagId,
      name: name,
      description: description,
      color: color,
      icon: icon,
      createdAt: DateTime.now(), // This should be preserved from original
      updatedAt: DateTime.now(),
      createdBy: 'System', // This should be preserved from original
      isActive: true,
    );

    return await _tagsRepository.updateTag(tag);
  }
}

