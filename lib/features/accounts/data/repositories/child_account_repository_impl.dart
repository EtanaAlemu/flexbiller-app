import 'package:injectable/injectable.dart';
import '../../domain/entities/child_account.dart';
import '../../domain/repositories/child_account_repository.dart';
import '../datasources/child_account_remote_data_source.dart';
import '../models/child_account_model.dart';

@Injectable(as: ChildAccountRepository)
class ChildAccountRepositoryImpl implements ChildAccountRepository {
  final ChildAccountRemoteDataSource _remoteDataSource;

  ChildAccountRepositoryImpl(this._remoteDataSource);

  @override
  Future<ChildAccount> createChildAccount(ChildAccount childAccount) async {
    try {
      final childAccountModel = ChildAccountModel.fromEntity(childAccount);
      final createdModel = await _remoteDataSource.createChildAccount(childAccountModel);
      return createdModel.toEntity();
    } catch (e) {
      rethrow;
    }
  }
}
