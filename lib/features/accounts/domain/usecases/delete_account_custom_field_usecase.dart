import 'package:injectable/injectable.dart';
import '../entities/account_custom_field.dart';
import '../repositories/account_custom_fields_repository.dart';

@injectable
class DeleteAccountCustomFieldUseCase {
  final AccountCustomFieldsRepository _customFieldsRepository;

  DeleteAccountCustomFieldUseCase(this._customFieldsRepository);

  Future<List<AccountCustomField>> call({
    required String accountId,
    required String customFieldId,
  }) async {
    // Since delete is not supported in the simplified repository,
    // we'll return the current custom fields for now
    // TODO: Implement delete functionality when the API supports it
    return await _customFieldsRepository.getAllCustomFields(accountId);
  }
}
