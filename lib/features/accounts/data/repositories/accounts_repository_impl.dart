import 'package:injectable/injectable.dart';
import '../../domain/entities/account.dart';
import '../../domain/entities/accounts_query_params.dart';
import '../../domain/repositories/accounts_repository.dart';
import '../datasources/accounts_remote_data_source.dart';
import '../models/account_model.dart';

@Injectable(as: AccountsRepository)
class AccountsRepositoryImpl implements AccountsRepository {
  final AccountsRemoteDataSource _remoteDataSource;

  AccountsRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<Account>> getAccounts(AccountsQueryParams params) async {
    try {
      final accountModels = await _remoteDataSource.getAccounts(params);
      return accountModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Account> getAccountById(String accountId) async {
    try {
      final accountModel = await _remoteDataSource.getAccountById(accountId);
      return accountModel.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Account> createAccount(Account account) async {
    try {
      final accountModel = AccountModel.fromEntity(account);
      final createdModel = await _remoteDataSource.createAccount(accountModel);
      return createdModel.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Account> updateAccount(Account account) async {
    try {
      final accountModel = AccountModel.fromEntity(account);
      final updatedModel = await _remoteDataSource.updateAccount(accountModel);
      return updatedModel.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteAccount(String accountId) async {
    try {
      await _remoteDataSource.deleteAccount(accountId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Account>> searchAccounts(String query) async {
    try {
      // For now, we'll fetch all accounts and filter locally
      // In a real app, you might have a dedicated search endpoint
      final allAccounts = await getAccounts(const AccountsQueryParams());
      final lowercaseQuery = query.toLowerCase();

      return allAccounts.where((account) {
        return account.name.toLowerCase().contains(lowercaseQuery) ||
            account.email.toLowerCase().contains(lowercaseQuery) ||
            account.company.toLowerCase().contains(lowercaseQuery);
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Account>> getAccountsWithBalance(double minBalance) async {
    try {
      final allAccounts = await getAccounts(const AccountsQueryParams());
      return allAccounts
          .where((account) => account.balance >= minBalance)
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Account>> getAccountsByCompany(String company) async {
    try {
      final allAccounts = await getAccounts(const AccountsQueryParams());
      final lowercaseCompany = company.toLowerCase();
      return allAccounts
          .where(
            (account) =>
                account.company.toLowerCase().contains(lowercaseCompany),
          )
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}
