import 'package:injectable/injectable.dart';
import '../../domain/entities/account_custom_field.dart';
import '../../domain/repositories/account_custom_fields_repository.dart';
import '../datasources/account_custom_fields_remote_data_source.dart';

@Injectable(as: AccountCustomFieldsRepository)
class AccountCustomFieldsRepositoryImpl implements AccountCustomFieldsRepository {
  final AccountCustomFieldsRemoteDataSource _remoteDataSource;

  AccountCustomFieldsRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<AccountCustomField>> getAllCustomFields(String accountId) async {
    try {
      final customFieldsModels = await _remoteDataSource.getAllCustomFields(accountId);
      return customFieldsModels.map((field) => field.toEntity()).toList();
    } catch (e) {
      rethrow;
    }
  }
}
