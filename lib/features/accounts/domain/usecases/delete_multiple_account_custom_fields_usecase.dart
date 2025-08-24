import 'package:injectable/injectable.dart';
import '../repositories/account_custom_fields_repository.dart';

@injectable
class DeleteMultipleAccountCustomFieldsUseCase {
  final AccountCustomFieldsRepository _customFieldsRepository;

  DeleteMultipleAccountCustomFieldsUseCase(this._customFieldsRepository);

  Future<void> call(String accountId, List<String> customFieldIds) async {
    return await _customFieldsRepository.deleteMultipleCustomFields(accountId, customFieldIds);
  }
}
