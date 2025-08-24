import 'package:injectable/injectable.dart';
import '../../domain/entities/account_custom_field.dart';
import '../../domain/repositories/account_custom_fields_repository.dart';
import '../datasources/account_custom_fields_remote_data_source.dart';

@Injectable(as: AccountCustomFieldsRepository)
class AccountCustomFieldsRepositoryImpl implements AccountCustomFieldsRepository {
  final AccountCustomFieldsRemoteDataSource _remoteDataSource;

  AccountCustomFieldsRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<AccountCustomField>> getAccountCustomFields(String accountId) async {
    try {
      final customFieldsModels = await _remoteDataSource.getAccountCustomFields(accountId);
      return customFieldsModels.map((field) => field.toEntity()).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<AccountCustomField> getCustomField(String accountId, String customFieldId) async {
    try {
      final customFieldModel = await _remoteDataSource.getCustomField(accountId, customFieldId);
      return customFieldModel.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<AccountCustomField> createCustomField(
    String accountId,
    String name,
    String value,
  ) async {
    try {
      final customFieldModel = await _remoteDataSource.createCustomField(accountId, name, value);
      return customFieldModel.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<AccountCustomField>> createMultipleCustomFields(
    String accountId,
    List<Map<String, String>> customFields,
  ) async {
    try {
      final customFieldsModels = await _remoteDataSource.createMultipleCustomFields(
        accountId,
        customFields,
      );
      return customFieldsModels.map((field) => field.toEntity()).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<AccountCustomField> updateCustomField(
    String accountId,
    String customFieldId,
    String name,
    String value,
  ) async {
    try {
      final customFieldModel = await _remoteDataSource.updateCustomField(
        accountId,
        customFieldId,
        name,
        value,
      );
      return customFieldModel.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteCustomField(String accountId, String customFieldId) async {
    try {
      await _remoteDataSource.deleteCustomField(accountId, customFieldId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<AccountCustomField>> getCustomFieldsByName(
    String accountId,
    String name,
  ) async {
    try {
      // For now, get all custom fields and filter by name
      // In the future, this could be implemented as a separate API endpoint
      final allCustomFields = await getAccountCustomFields(accountId);
      return allCustomFields
          .where((field) => field.name.toLowerCase().contains(name.toLowerCase()))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<AccountCustomField>> getCustomFieldsByValue(
    String accountId,
    String value,
  ) async {
    try {
      // For now, get all custom fields and filter by value
      // In the future, this could be implemented as a separate API endpoint
      final allCustomFields = await getAccountCustomFields(accountId);
      return allCustomFields
          .where((field) => field.value.toLowerCase().contains(value.toLowerCase()))
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}
