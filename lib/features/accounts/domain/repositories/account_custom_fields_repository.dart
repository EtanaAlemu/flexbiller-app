import '../entities/account_custom_field.dart';

abstract class AccountCustomFieldsRepository {
  /// Get all custom fields for a specific account
  Future<List<AccountCustomField>> getAllCustomFields(String accountId);
}
