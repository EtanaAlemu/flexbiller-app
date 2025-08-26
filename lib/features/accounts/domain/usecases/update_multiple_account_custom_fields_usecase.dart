import 'package:injectable/injectable.dart';
import '../entities/account_custom_field.dart';
import '../repositories/account_custom_fields_repository.dart';

@injectable
class UpdateMultipleAccountCustomFieldsUseCase {
  final AccountCustomFieldsRepository _customFieldsRepository;

  UpdateMultipleAccountCustomFieldsUseCase(this._customFieldsRepository);

  Future<List<AccountCustomField>> call(
    String accountId,
    List<Map<String, dynamic>> customFields,
  ) async {
    return await _customFieldsRepository.updateMultipleCustomFields(
      accountId,
      customFields,
    );
  }
}
