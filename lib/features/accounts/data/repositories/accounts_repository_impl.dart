import 'dart:async';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/account.dart';
import '../../domain/entities/accounts_query_params.dart';
import '../../domain/repositories/accounts_repository.dart';
import '../datasources/local/accounts_local_data_source.dart';
import '../datasources/remote/accounts_remote_data_source.dart';
import '../models/account_model.dart';

@LazySingleton(as: AccountsRepository)
class AccountsRepositoryImpl implements AccountsRepository {
  final AccountsRemoteDataSource _remoteDataSource;
  final AccountsLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;
  final Logger _logger = Logger();
  
  // Stream controllers for reactive UI updates
  final StreamController<List<Account>> _accountsStreamController = 
      StreamController<List<Account>>.broadcast();
  final StreamController<Account> _accountStreamController = 
      StreamController<Account>.broadcast();

  AccountsRepositoryImpl({
    required AccountsRemoteDataSource remoteDataSource,
    required AccountsLocalDataSource localDataSource,
    required NetworkInfo networkInfo,
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource,
       _networkInfo = networkInfo;

  // Stream getters for reactive UI updates
  Stream<List<Account>> get accountsStream => _accountsStreamController.stream;
  Stream<Account> get accountStream => _accountStreamController.stream;

  @override
  Future<List<Account>> getAccounts(AccountsQueryParams params) async {
    try {
      // First, try to get data from local cache
      final cachedAccounts = await _localDataSource.getCachedAccountsByQuery(
        params,
      );

      if (cachedAccounts.isNotEmpty) {
        _logger.d('Returning ${cachedAccounts.length} cached accounts');
        // Return cached data immediately for fast UI response
        final accounts = cachedAccounts
            .map((model) => model.toEntity())
            .toList();

        // Then, in the background, try to sync with remote if online
        _syncAccountsInBackground(params);

        return accounts;
      }

      // If no cached data, check if we're online
      if (await _networkInfo.isConnected) {
        try {
          // Fetch from remote API
          final remoteAccounts = await _remoteDataSource.getAccounts(params);

          // Cache the remote data locally
          await _localDataSource.cacheAccounts(remoteAccounts);

          _logger.d(
            'Fetched and cached ${remoteAccounts.length} accounts from remote',
          );
          return remoteAccounts.map((model) => model.toEntity()).toList();
        } on ServerException catch (e) {
          _logger.e('Server error while fetching accounts: ${e.message}');
          rethrow;
        } on NetworkException catch (e) {
          _logger.e('Network error while fetching accounts: ${e.message}');
          rethrow;
        } on AuthException catch (e) {
          _logger.e('Auth error while fetching accounts: ${e.message}');
          rethrow;
        }
      } else {
        // Offline and no cached data
        _logger.w('No cached accounts and device is offline');
        throw NetworkException(
          'No cached data available and device is offline',
        );
      }
    } catch (e) {
      _logger.e('Unexpected error in getAccounts: $e');
      rethrow;
    }
  }

  @override
  Future<Account> getAccountById(String accountId) async {
    try {
      // First, try to get from local cache
      final cachedAccount = await _localDataSource.getCachedAccountById(
        accountId,
      );

      if (cachedAccount != null) {
        _logger.d('Returning cached account: $accountId');
        // Return cached data immediately
        final account = cachedAccount.toEntity();

        // Then, in the background, try to sync if online
        _syncAccountInBackground(accountId);

        return account;
      }

      // If no cached data, check if we're online
      if (await _networkInfo.isConnected) {
        try {
          // Fetch from remote API
          final remoteAccount = await _remoteDataSource.getAccountById(
            accountId,
          );

          // Cache the remote data locally
          await _localDataSource.cacheAccount(remoteAccount);

          _logger.d('Fetched and cached account from remote: $accountId');
          return remoteAccount.toEntity();
        } on ServerException catch (e) {
          _logger.e('Server error while fetching account: ${e.message}');
          rethrow;
        } on NetworkException catch (e) {
          _logger.e('Network error while fetching account: ${e.message}');
          rethrow;
        } on AuthException catch (e) {
          _logger.e('Auth error while fetching account: ${e.message}');
          rethrow;
        }
      } else {
        // Offline and no cached data
        _logger.w('No cached account and device is offline: $accountId');
        throw NetworkException(
          'Account not found in cache and device is offline',
        );
      }
    } catch (e) {
      _logger.e('Unexpected error in getAccountById: $e');
      rethrow;
    }
  }

  @override
  Future<List<Account>> searchAccounts(String searchKey) async {
    try {
      // First, try to search in local cache
      final cachedResults = await _localDataSource.searchCachedAccounts(
        searchKey,
      );

      if (cachedResults.isNotEmpty) {
        _logger.d(
          'Found ${cachedResults.length} cached accounts for search: $searchKey',
        );
        return cachedResults.map((model) => model.toEntity()).toList();
      }

      // If no cached results, check if we're online
      if (await _networkInfo.isConnected) {
        try {
          // Search from remote API
          final remoteResults = await _remoteDataSource.searchAccounts(
            searchKey,
          );

          // Cache the remote results locally
          await _localDataSource.cacheAccounts(remoteResults);

          _logger.d(
            'Found and cached ${remoteResults.length} accounts from remote search: $searchKey',
          );
          return remoteResults.map((model) => model.toEntity()).toList();
        } on ServerException catch (e) {
          _logger.e('Server error while searching accounts: ${e.message}');
          rethrow;
        } on NetworkException catch (e) {
          _logger.e('Network error while searching accounts: ${e.message}');
          rethrow;
        } on AuthException catch (e) {
          _logger.e('Auth error while searching accounts: ${e.message}');
          rethrow;
        }
      } else {
        // Offline and no cached results
        _logger.w('No cached search results and device is offline: $searchKey');
        throw NetworkException(
          'No search results in cache and device is offline',
        );
      }
    } catch (e) {
      _logger.e('Unexpected error in searchAccounts: $e');
      rethrow;
    }
  }

  @override
  Future<Account> createAccount(Account account) async {
    try {
      // Convert entity to model
      final accountModel = AccountModel(
        accountId: account.accountId,
        name: account.name,
        firstNameLength: account.firstNameLength,
        externalKey: account.externalKey,
        email: account.email,
        billCycleDayLocal: account.billCycleDayLocal,
        currency: account.currency,
        parentAccountId: account.parentAccountId,
        isPaymentDelegatedToParent: account.isPaymentDelegatedToParent,
        paymentMethodId: account.paymentMethodId,
        referenceTime: account.referenceTime,
        timeZone: account.timeZone,
        address1: account.address1,
        address2: account.address2,
        postalCode: account.postalCode,
        company: account.company,
        city: account.city,
        state: account.state,
        country: account.country,
        locale: account.locale,
        phone: account.phone,
        notes: account.notes,
        isMigrated: account.isMigrated,
        accountBalance: account.accountBalance,
        accountCBA: account.accountCBA,
        auditLogs: const [],
      );

      // First, save to local cache
      await _localDataSource.cacheAccount(accountModel);
      _logger.d('Account saved to local cache: ${account.accountId}');

      // If online, try to sync with remote
      if (await _networkInfo.isConnected) {
        try {
          final remoteAccount = await _remoteDataSource.createAccount(
            accountModel,
          );

          // Update local cache with remote data (in case server modified it)
          await _localDataSource.updateCachedAccount(remoteAccount);

          _logger.d(
            'Account created and synced with remote: ${account.accountId}',
          );
          return remoteAccount.toEntity();
        } on ServerException catch (e) {
          _logger.w(
            'Failed to sync account with remote, but saved locally: ${e.message}',
          );
          // Return local data even if remote sync failed
          return account;
        } on NetworkException catch (e) {
          _logger.w(
            'Network error while syncing account, but saved locally: ${e.message}',
          );
          return account;
        } on AuthException catch (e) {
          _logger.e('Auth error while creating account: ${e.message}');
          rethrow;
        }
      } else {
        // Offline - return local data
        _logger.d(
          'Account created offline and saved locally: ${account.accountId}',
        );
        return account;
      }
    } catch (e) {
      _logger.e('Unexpected error in createAccount: $e');
      rethrow;
    }
  }

  @override
  Future<Account> updateAccount(Account account) async {
    try {
      // Convert entity to model
      final accountModel = AccountModel(
        accountId: account.accountId,
        name: account.name,
        firstNameLength: account.firstNameLength,
        externalKey: account.externalKey,
        email: account.email,
        billCycleDayLocal: account.billCycleDayLocal,
        currency: account.currency,
        parentAccountId: account.parentAccountId,
        isPaymentDelegatedToParent: account.isPaymentDelegatedToParent,
        paymentMethodId: account.paymentMethodId,
        referenceTime: account.referenceTime,
        timeZone: account.timeZone,
        address1: account.address1,
        address2: account.address2,
        postalCode: account.postalCode,
        company: account.company,
        city: account.city,
        state: account.state,
        country: account.country,
        locale: account.locale,
        phone: account.phone,
        notes: account.notes,
        isMigrated: account.isMigrated,
        accountBalance: account.accountBalance,
        accountCBA: account.accountCBA,
        auditLogs: const [],
      );

      // First, update local cache
      await _localDataSource.updateCachedAccount(accountModel);
      _logger.d('Account updated in local cache: ${account.accountId}');

      // If online, try to sync with remote
      if (await _networkInfo.isConnected) {
        try {
          final remoteAccount = await _remoteDataSource.updateAccount(
            accountModel,
          );

          // Update local cache with remote data (in case server modified it)
          await _localDataSource.updateCachedAccount(remoteAccount);

          _logger.d(
            'Account updated and synced with remote: ${account.accountId}',
          );
          return remoteAccount.toEntity();
        } on ServerException catch (e) {
          _logger.w(
            'Failed to sync account update with remote, but updated locally: ${e.message}',
          );
          // Return local data even if remote sync failed
          return account;
        } on NetworkException catch (e) {
          _logger.w(
            'Network error while syncing account update, but updated locally: ${e.message}',
          );
          return account;
        } on AuthException catch (e) {
          _logger.e('Auth error while updating account: ${e.message}');
          rethrow;
        }
      } else {
        // Offline - return local data
        _logger.d(
          'Account updated offline and saved locally: ${account.accountId}',
        );
        return account;
      }
    } catch (e) {
      _logger.e('Unexpected error in updateAccount: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteAccount(String accountId) async {
    try {
      // First, delete from local cache
      await _localDataSource.deleteCachedAccount(accountId);
      _logger.d('Account deleted from local cache: $accountId');

      // If online, try to sync with remote
      if (await _networkInfo.isConnected) {
        try {
          await _remoteDataSource.deleteAccount(accountId);
          _logger.d('Account deleted and synced with remote: $accountId');
        } on ServerException catch (e) {
          _logger.w(
            'Failed to sync account deletion with remote, but deleted locally: ${e.message}',
          );
          // Return success even if remote sync failed
        } on NetworkException catch (e) {
          _logger.w(
            'Network error while syncing account deletion, but deleted locally: ${e.message}',
          );
          // Return success even if remote sync failed
        } on AuthException catch (e) {
          _logger.e('Auth error while deleting account: ${e.message}');
          rethrow;
        }
      } else {
        // Offline - return success
        _logger.d(
          'Account deleted offline and removed from local cache: $accountId',
        );
      }
    } catch (e) {
      _logger.e('Unexpected error in deleteAccount: $e');
      rethrow;
    }
  }

  // Additional methods for local-first operations
  Future<bool> hasAccounts() async {
    try {
      return await _localDataSource.hasCachedAccounts();
    } catch (e) {
      _logger.e('Error checking if has accounts: $e');
      return false;
    }
  }

  Future<int> getAccountsCount() async {
    try {
      return await _localDataSource.getCachedAccountsCount();
    } catch (e) {
      _logger.e('Error getting accounts count: $e');
      return 0;
    }
  }

  Future<void> clearAllAccounts() async {
    try {
      await _localDataSource.clearAllCachedAccounts();
      _logger.d('All accounts cleared from local cache');
    } catch (e) {
      _logger.e('Error clearing all accounts: $e');
      rethrow;
    }
  }

  @override
  Future<List<Account>> getAccountsWithBalance(double minBalance) async {
    try {
      // Get all accounts from local cache first
      final allAccounts = await _localDataSource.getCachedAccounts();

      if (allAccounts.isNotEmpty) {
        // Filter accounts with balance above threshold
        final filteredAccounts = allAccounts
            .where(
              (account) =>
                  account.accountBalance != null &&
                  account.accountBalance! >= minBalance,
            )
            .map((model) => model.toEntity())
            .toList();

        _logger.d(
          'Found ${filteredAccounts.length} accounts with balance >= $minBalance',
        );
        return filteredAccounts;
      }

      // If no cached data, check if we're online
      if (await _networkInfo.isConnected) {
        try {
          // Fetch from remote API with default params
          final remoteAccounts = await _remoteDataSource.getAccounts(
            const AccountsQueryParams(),
          );

          // Cache the remote data locally
          await _localDataSource.cacheAccounts(remoteAccounts);

          // Filter the remote results
          final filteredAccounts = remoteAccounts
              .where(
                (account) =>
                    account.accountBalance != null &&
                    account.accountBalance! >= minBalance,
              )
              .map((model) => model.toEntity())
              .toList();

          _logger.d(
            'Fetched and filtered ${filteredAccounts.length} accounts with balance >= $minBalance from remote',
          );
          return filteredAccounts;
        } on ServerException catch (e) {
          _logger.e(
            'Server error while fetching accounts with balance: ${e.message}',
          );
          rethrow;
        } on NetworkException catch (e) {
          _logger.e(
            'Network error while fetching accounts with balance: ${e.message}',
          );
          rethrow;
        } on AuthException catch (e) {
          _logger.e(
            'Auth error while fetching accounts with balance: ${e.message}',
          );
          rethrow;
        }
      } else {
        // Offline and no cached data
        _logger.w('No cached accounts and device is offline');
        throw NetworkException(
          'No cached data available and device is offline',
        );
      }
    } catch (e) {
      _logger.e('Unexpected error in getAccountsWithBalance: $e');
      rethrow;
    }
  }

  @override
  Future<List<Account>> getAccountsByCompany(String company) async {
    try {
      // Search in local cache first
      final cachedResults = await _localDataSource.searchCachedAccounts(
        company,
      );

      if (cachedResults.isNotEmpty) {
        // Filter results to only include accounts matching the company
        final companyAccounts = cachedResults
            .where(
              (account) =>
                  account.company != null &&
                  account.company!.toLowerCase().contains(
                    company.toLowerCase(),
                  ),
            )
            .map((model) => model.toEntity())
            .toList();

        _logger.d(
          'Found ${companyAccounts.length} cached accounts for company: $company',
        );
        return companyAccounts;
      }

      // If no cached results, check if we're online
      if (await _networkInfo.isConnected) {
        try {
          // Fetch from remote API with default params
          final remoteAccounts = await _remoteDataSource.getAccounts(
            const AccountsQueryParams(),
          );

          // Cache the remote data locally
          await _localDataSource.cacheAccounts(remoteAccounts);

          // Filter the remote results
          final companyAccounts = remoteAccounts
              .where(
                (account) =>
                    account.company != null &&
                    account.company!.toLowerCase().contains(
                      company.toLowerCase(),
                    ),
              )
              .map((model) => model.toEntity())
              .toList();

          _logger.d(
            'Fetched and filtered ${companyAccounts.length} accounts for company from remote: $company',
          );
          return companyAccounts;
        } on ServerException catch (e) {
          _logger.e(
            'Server error while fetching accounts by company: ${e.message}',
          );
          rethrow;
        } on NetworkException catch (e) {
          _logger.e(
            'Network error while fetching accounts by company: ${e.message}',
          );
          rethrow;
        } on AuthException catch (e) {
          _logger.e(
            'Auth error while fetching accounts by company: ${e.message}',
          );
          rethrow;
        }
      } else {
        // Offline and no cached results
        _logger.w('No cached company results and device is offline: $company');
        throw NetworkException(
          'No search results in cache and device is offline',
        );
      }
    } catch (e) {
      _logger.e('Unexpected error in getAccountsByCompany: $e');
      rethrow;
    }
  }

  // Background synchronization methods
  Future<void> _syncAccountsInBackground(AccountsQueryParams params) async {
    try {
      if (await _networkInfo.isConnected) {
        final remoteAccounts = await _remoteDataSource.getAccounts(params);
        await _localDataSource.cacheAccounts(remoteAccounts);
        
        // 🔥 KEY: Update UI with fresh data via stream
        final freshAccounts = remoteAccounts.map((model) => model.toEntity()).toList();
        _accountsStreamController.add(freshAccounts);
        
        _logger.d('Background sync completed for accounts - UI updated with fresh data');
      }
    } catch (e) {
      _logger.w('Background sync failed for accounts: $e');
    }
  }

  Future<void> _syncAccountInBackground(String accountId) async {
    try {
      if (await _networkInfo.isConnected) {
        final remoteAccount = await _remoteDataSource.getAccountById(accountId);
        await _localDataSource.updateCachedAccount(remoteAccount);
        
        // 🔥 KEY: Update UI with fresh data via stream
        final freshAccount = remoteAccount.toEntity();
        _accountStreamController.add(freshAccount);
        
        _logger.d('Background sync completed for account: $accountId - UI updated with fresh data');
      }
    } catch (e) {
      _logger.w('Background sync failed for account $accountId: $e');
    }
  }

  // Clean up stream controllers
  void dispose() {
    _accountsStreamController.close();
    _accountStreamController.close();
  }
}
