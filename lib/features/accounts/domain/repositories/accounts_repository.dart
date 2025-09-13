import 'dart:async';
import '../../../../core/models/repository_response.dart';
import '../entities/account.dart';
import '../entities/accounts_query_params.dart';

abstract class AccountsRepository {
  /// Get list of accounts with optional filtering and pagination
  Future<List<Account>> getAccounts(AccountsQueryParams params);

  /// Get a single account by ID
  Future<Account> getAccountById(String id);

  /// Search accounts by search key
  Future<List<Account>> searchAccounts(String searchKey);

  /// Create a new account
  Future<Account> createAccount(Account account);

  /// Update an existing account
  Future<Account> updateAccount(Account account);

  /// Delete an account
  Future<void> deleteAccount(String accountId);

  /// Get accounts with balance above a certain threshold
  Future<List<Account>> getAccountsWithBalance(double minBalance);

  /// Get accounts by company
  Future<List<Account>> getAccountsByCompany(String company);

  /// Stream for reactive updates when accounts data changes
  Stream<RepositoryResponse<List<Account>>> get accountsStream;

  /// Stream for reactive updates when individual account data changes
  Stream<RepositoryResponse<Account>> get accountStream;
}
