import 'dart:async';
import '../entities/child_account.dart';

abstract class ChildAccountRepository {
  Future<ChildAccount> createChildAccount(ChildAccount childAccount);
  Future<List<ChildAccount>> getChildAccounts(String parentAccountId);

  /// Stream for reactive updates when child accounts data changes
  Stream<List<ChildAccount>> get childAccountsStream;

  /// Stream for reactive updates when individual child account data changes
  Stream<ChildAccount> get childAccountStream;
}
