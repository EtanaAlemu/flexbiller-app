import '../entities/child_account.dart';

abstract class ChildAccountRepository {
  Future<ChildAccount> createChildAccount(ChildAccount childAccount);
  Future<List<ChildAccount>> getChildAccounts(String parentAccountId);
}
