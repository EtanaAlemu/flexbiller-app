import 'package:injectable/injectable.dart';
import '../entities/account_custom_field.dart';
import '../repositories/account_custom_fields_repository.dart';

@injectable
class UpdateAccountCustomFieldUseCase {
  final AccountCustomFieldsRepository _customFieldsRepository;

  UpdateAccountCustomFieldUseCase(this._customFieldsRepository);

  Future<AccountCustomField> call(
    String accountId,
    String customFieldId,
    String name,
    String value,
  ) async {
    return await _customFieldsRepository.updateCustomField(
      accountId,
      customFieldId,
      name,
      value,
    );
  }
}
