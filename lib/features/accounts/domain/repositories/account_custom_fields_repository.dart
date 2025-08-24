import '../entities/account_custom_field.dart';

abstract class AccountCustomFieldsRepository {
  /// Get all custom fields for a specific account
  Future<List<AccountCustomField>> getAccountCustomFields(String accountId);

  /// Get a specific custom field by ID
  Future<AccountCustomField> getCustomField(String accountId, String customFieldId);

  /// Create a new custom field for an account
  Future<AccountCustomField> createCustomField(
    String accountId,
    String name,
    String value,
  );

  /// Update an existing custom field
  Future<AccountCustomField> updateCustomField(
    String accountId,
    String customFieldId,
    String name,
    String value,
  );

  /// Delete a custom field
  Future<void> deleteCustomField(String accountId, String customFieldId);

  /// Get custom fields by name (search)
  Future<List<AccountCustomField>> getCustomFieldsByName(
    String accountId,
    String name,
  );

  /// Get custom fields with specific values
  Future<List<AccountCustomField>> getCustomFieldsByValue(
    String accountId,
    String value,
  );
}
