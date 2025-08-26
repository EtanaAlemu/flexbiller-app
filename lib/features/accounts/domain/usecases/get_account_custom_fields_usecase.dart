import 'package:injectable/injectable.dart';
import '../entities/account_custom_field.dart';
import '../repositories/account_custom_fields_repository.dart';

@injectable
class GetAccountCustomFieldsUseCase {
  final AccountCustomFieldsRepository _customFieldsRepository;

  GetAccountCustomFieldsUseCase(this._customFieldsRepository);

  Future<List<AccountCustomField>> call(String accountId) async {
    return await _customFieldsRepository.getAccountCustomFields(accountId);
  }
}
