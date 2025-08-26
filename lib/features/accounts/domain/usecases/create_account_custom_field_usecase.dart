import 'package:injectable/injectable.dart';
import '../entities/account_custom_field.dart';
import '../repositories/account_custom_fields_repository.dart';

@injectable
class CreateAccountCustomFieldUseCase {
  final AccountCustomFieldsRepository _customFieldsRepository;

  CreateAccountCustomFieldUseCase(this._customFieldsRepository);

  Future<List<AccountCustomField>> call({
    required String accountId,
    required String name,
    required String value,
  }) async {
    // Since create is not supported in the simplified repository,
    // we'll return the current custom fields for now
    // TODO: Implement create functionality when the API supports it
    return await _customFieldsRepository.getAllCustomFields(accountId);
  }
}
