import 'package:injectable/injectable.dart';
import '../../domain/entities/account_overdue_state.dart';
import '../../domain/repositories/account_overdue_state_repository.dart';
import '../datasources/account_overdue_state_remote_data_source.dart';

@Injectable(as: AccountOverdueStateRepository)
class AccountOverdueStateRepositoryImpl implements AccountOverdueStateRepository {
  final AccountOverdueStateRemoteDataSource _remoteDataSource;

  AccountOverdueStateRepositoryImpl(this._remoteDataSource);

  @override
  Future<AccountOverdueState> getOverdueState(String accountId) async {
    try {
      final overdueStateModel = await _remoteDataSource.getOverdueState(accountId);
      return overdueStateModel.toEntity();
    } catch (e) {
      rethrow;
    }
  }
}
