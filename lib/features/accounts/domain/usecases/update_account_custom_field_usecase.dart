import 'package:injectable/injectable.dart';
import '../entities/account_custom_field.dart';
import '../repositories/account_custom_fields_repository.dart';

@injectable
class UpdateAccountCustomFieldUseCase {
  final AccountCustomFieldsRepository _customFieldsRepository;

  UpdateAccountCustomFieldUseCase(this._customFieldsRepository);

  Future<List<AccountCustomField>> call({
    required String accountId,
    required String customFieldId,
    required String name,
    required String value,
  }) async {
    // Since update is not supported in the simplified repository,
    // we'll return the current custom fields for now
    // TODO: Implement update functionality when the API supports it
    return await _customFieldsRepository.getAllCustomFields(accountId);
  }
}
