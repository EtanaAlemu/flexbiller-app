import 'package:injectable/injectable.dart';
import '../../domain/entities/account_cba_rebalancing.dart';
import '../../domain/repositories/account_cba_rebalancing_repository.dart';
import '../datasources/remote/account_cba_rebalancing_remote_data_source.dart';

@Injectable(as: AccountCbaRebalancingRepository)
class AccountCbaRebalancingRepositoryImpl implements AccountCbaRebalancingRepository {
  final AccountCbaRebalancingRemoteDataSource _remoteDataSource;

  AccountCbaRebalancingRepositoryImpl(this._remoteDataSource);

  @override
  Future<AccountCbaRebalancing> rebalanceCba(String accountId) async {
    try {
      final cbaRebalancingModel = await _remoteDataSource.rebalanceCba(accountId);
      return cbaRebalancingModel.toEntity();
    } catch (e) {
      rethrow;
    }
  }
}
