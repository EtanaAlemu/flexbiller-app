import 'package:injectable/injectable.dart';
import '../repositories/account_custom_fields_repository.dart';

@injectable
class DeleteAccountCustomFieldUseCase {
  final AccountCustomFieldsRepository _customFieldsRepository;

  DeleteAccountCustomFieldUseCase(this._customFieldsRepository);

  Future<void> call(String accountId, String customFieldId) async {
    return await _customFieldsRepository.deleteCustomField(
      accountId,
      customFieldId,
    );
  }
}
