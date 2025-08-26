import 'package:injectable/injectable.dart';
import '../entities/account_cba_rebalancing.dart';
import '../repositories/account_cba_rebalancing_repository.dart';

@injectable
class RebalanceCbaUseCase {
  final AccountCbaRebalancingRepository _cbaRebalancingRepository;

  RebalanceCbaUseCase(this._cbaRebalancingRepository);

  Future<AccountCbaRebalancing> call(String accountId) async {
    return await _cbaRebalancingRepository.rebalanceCba(accountId);
  }
}
