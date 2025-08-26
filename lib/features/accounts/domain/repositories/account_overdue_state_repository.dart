import '../entities/account_overdue_state.dart';

abstract class AccountOverdueStateRepository {
  Future<AccountOverdueState> getOverdueState(String accountId);
}
