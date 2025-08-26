import 'package:injectable/injectable.dart';
import '../entities/account_custom_field.dart';
import '../repositories/account_custom_fields_repository.dart';

@injectable
class CreateAccountCustomFieldUseCase {
  final AccountCustomFieldsRepository _customFieldsRepository;

  CreateAccountCustomFieldUseCase(this._customFieldsRepository);

  Future<AccountCustomField> call(
    String accountId,
    String name,
    String value,
  ) async {
    return await _customFieldsRepository.createCustomField(
      accountId,
      name,
      value,
    );
  }
}
