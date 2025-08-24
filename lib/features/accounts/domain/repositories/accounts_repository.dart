import '../entities/account.dart';
import '../entities/accounts_query_params.dart';

abstract class AccountsRepository {
  /// Get list of accounts with optional filtering and pagination
  Future<List<Account>> getAccounts(AccountsQueryParams params);

  /// Get a specific account by ID
  Future<Account> getAccountById(String accountId);

  /// Create a new account
  Future<Account> createAccount(Account account);

  /// Update an existing account
  Future<Account> updateAccount(Account account);

  /// Delete an account
  Future<void> deleteAccount(String accountId);

  /// Search accounts by name, email, or company
  Future<List<Account>> searchAccounts(String query);

  /// Get accounts with balance above a certain threshold
  Future<List<Account>> getAccountsWithBalance(double minBalance);

  /// Get accounts by company
  Future<List<Account>> getAccountsByCompany(String company);
}
