import 'package:injectable/injectable.dart';
import '../entities/account_custom_field.dart';
import '../repositories/account_custom_fields_repository.dart';

@injectable
class CreateMultipleAccountCustomFieldsUseCase {
  final AccountCustomFieldsRepository _customFieldsRepository;

  CreateMultipleAccountCustomFieldsUseCase(this._customFieldsRepository);

  Future<List<AccountCustomField>> call(
    String accountId,
    List<Map<String, String>> customFields,
  ) async {
    return await _customFieldsRepository.createMultipleCustomFields(
      accountId,
      customFields,
    );
  }
}
