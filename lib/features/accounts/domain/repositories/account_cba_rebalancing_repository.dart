import '../entities/account_cba_rebalancing.dart';

abstract class AccountCbaRebalancingRepository {
  Future<AccountCbaRebalancing> rebalanceCba(String accountId);
}
