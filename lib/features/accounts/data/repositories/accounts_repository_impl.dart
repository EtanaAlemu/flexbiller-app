import 'dart:async';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/models/repository_response.dart';
import '../../../../core/services/sync_service.dart';
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
  final SyncService _syncService;
  final Logger _logger = Logger();

  // Stream controllers for reactive UI updates
  final StreamController<RepositoryResponse<List<Account>>>
  _accountsStreamController =
      StreamController<RepositoryResponse<List<Account>>>.broadcast();
  final StreamController<RepositoryResponse<Account>> _accountStreamController =
      StreamController<RepositoryResponse<Account>>.broadcast();

  // Stream subscriptions for local data changes
  StreamSubscription<List<AccountModel>>? _localAccountsSubscription;
  StreamSubscription<AccountModel?>? _localAccountSubscription;

  // Track accounts currently being synced to prevent duplicate syncs
  final Map<String, Completer<void>> _syncingAccounts =
      <String, Completer<void>>{};

  // Track last sync time to prevent rapid successive syncs
  final Map<String, DateTime> _lastSyncTime = <String, DateTime>{};

  // Track if we're currently processing an account to prevent loops
  final Set<String> _processingAccounts = <String>{};

  // Track if we're currently syncing accounts list to prevent loops
  bool _isSyncingAccountsList = false;
  DateTime? _lastAccountsListSyncTime;

  // Flag to prevent recursive stream emissions during background sync
  bool _isEmittingFromBackgroundSync = false;

  AccountsRepositoryImpl({
    required AccountsRemoteDataSource remoteDataSource,
    required AccountsLocalDataSource localDataSource,
    required NetworkInfo networkInfo,
    required SyncService syncService,
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource,
       _networkInfo = networkInfo,
       _syncService = syncService {
    _initializeLocalStreams();
  }

  // Stream getters for reactive UI updates
  Stream<RepositoryResponse<List<Account>>> get accountsStream =>
      _accountsStreamController.stream;
  Stream<RepositoryResponse<Account>> get accountStream =>
      _accountStreamController.stream;

  /// Initialize local data streams for reactive updates
  void _initializeLocalStreams() {
    // Listen to local accounts changes - only emit when accounts list is explicitly requested
    // This prevents individual account updates from triggering accounts list updates
    _localAccountsSubscription = _localDataSource.watchAccounts().listen(
      (accountModels) {
        final accounts = accountModels
            .map((model) => model.toEntity())
            .toList();
        // Only emit accounts list updates when explicitly requested, not for individual account updates
        _logger.d(
          'Local accounts data updated: ${accounts.length} accounts (not emitting to stream)',
        );
      },
      onError: (error) {
        _logger.e('Error in local accounts stream: $error');
      },
    );

    // Note: Individual account updates will be handled by specific methods
    // as we need to know which account ID to watch for
  }

  @override
  Future<List<Account>> getAccounts(AccountsQueryParams params) async {
    try {
      _logger.d(
        '🔍 DEBUG: getAccounts called with params: ${params.toString()}',
      );

      // First, try to get data from local cache
      final cachedAccounts = await _localDataSource.getCachedAccountsByQuery(
        params,
      );

      _logger.d('🔍 DEBUG: Cached accounts count: ${cachedAccounts.length}');

      if (cachedAccounts.isNotEmpty) {
        _logger.d('Returning ${cachedAccounts.length} cached accounts');
        final accounts = cachedAccounts
            .map((model) => model.toEntity())
            .toList();

        // Emit success state with cached data immediately
        _accountsStreamController.add(RepositoryResponse.success(accounts));

        // Then, in the background, try to sync with remote if online
        // Only sync if we haven't synced recently to prevent loops
        _syncAccountsInBackground(params);

        return accounts;
      }

      // If no cached data, check if we're online
      if (await _networkInfo.isConnected) {
        try {
          // Emit loading state
          _accountsStreamController.add(RepositoryResponse.loading());

          // Fetch from remote API
          final remoteAccounts = await _remoteDataSource.getAccounts(params);

          // Cache the remote data locally
          await _localDataSource.cacheAccounts(remoteAccounts);

          final accounts = remoteAccounts
              .map((model) => model.toEntity())
              .toList();
          _logger.d(
            'Fetched and cached ${accounts.length} accounts from remote',
          );

          // Emit success state
          _accountsStreamController.add(RepositoryResponse.success(accounts));

          return accounts;
        } on ServerException catch (e) {
          _logger.e('Server error while fetching accounts: ${e.message}');
          _accountsStreamController.add(RepositoryResponse.error(exception: e));
          rethrow;
        } on NetworkException catch (e) {
          _logger.e('Network error while fetching accounts: ${e.message}');
          _accountsStreamController.add(RepositoryResponse.error(exception: e));
          rethrow;
        } on AuthException catch (e) {
          _logger.e('Auth error while fetching accounts: ${e.message}');
          _accountsStreamController.add(RepositoryResponse.error(exception: e));
          rethrow;
        }
      } else {
        // Offline and no cached data
        _logger.w('No cached accounts and device is offline');
        final error = NetworkException(
          'No cached data available and device is offline',
        );
        _accountsStreamController.add(
          RepositoryResponse.error(exception: error),
        );
        throw error;
      }
    } catch (e) {
      _logger.e('Unexpected error in getAccounts: $e');
      final exception = e is Exception ? e : Exception(e.toString());
      _accountsStreamController.add(
        RepositoryResponse.error(exception: exception),
      );
      rethrow;
    }
  }

  @override
  Future<Account> getAccountById(String accountId) async {
    _logger.d('🔍 getAccountById called for: $accountId');
    try {
      // First, try to get from local cache
      final cachedAccount = await _localDataSource.getCachedAccountById(
        accountId,
      );

      if (cachedAccount != null) {
        _logger.d('Returning cached account: $accountId');
        // Return cached data immediately
        final account = cachedAccount.toEntity();

        // Emit success state with cached data immediately
        _accountStreamController.add(RepositoryResponse.success(account));

        // Only sync in background if we're online and not already syncing this account
        if (await _networkInfo.isConnected) {
          if (!_syncingAccounts.containsKey(accountId) &&
              !_processingAccounts.contains(accountId)) {
            // Check if we synced this account recently (within last 60 seconds)
            final lastSync = _lastSyncTime[accountId];
            final now = DateTime.now();
            if (lastSync == null || now.difference(lastSync).inSeconds > 60) {
              _logger.d(
                'Account $accountId not in syncing set, starting background sync',
              );
              _syncAccountInBackground(accountId);
            } else {
              _logger.d(
                'Account $accountId synced recently (${now.difference(lastSync).inSeconds}s ago), skipping sync',
              );
            }
          } else {
            _logger.d(
              'Account $accountId already being synced or processed, skipping duplicate sync',
            );
          }
        } else {
          _logger.d(
            'No network connection, skipping background sync for account $accountId',
          );
        }

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

      // Check if we're online before attempting to create account
      if (!await _networkInfo.isConnected) {
        throw NetworkException(
          'No network connection available. Please check your internet connection and try again.',
        );
      }

      _logger.d('Creating account on remote server: ${account.accountId}');

      // Create account on remote server first and wait for response
      final remoteAccount = await _remoteDataSource.createAccount(accountModel);
      _logger.d(
        'Account created successfully on remote server: ${account.accountId}',
      );

      // Save the remote response to local cache
      await _localDataSource.cacheAccount(remoteAccount);
      _logger.d('Account saved to local cache: ${account.accountId}');

      // Emit success state with remote data
      final createdAccount = remoteAccount.toEntity();
      _accountStreamController.add(RepositoryResponse.success(createdAccount));

      return createdAccount;
    } on ValidationException catch (e) {
      _logger.e('Validation error while creating account: ${e.message}');
      _accountStreamController.add(RepositoryResponse.error(exception: e));
      rethrow;
    } on ServerException catch (e) {
      _logger.e('Server error while creating account: ${e.message}');
      _accountStreamController.add(RepositoryResponse.error(exception: e));
      rethrow;
    } on NetworkException catch (e) {
      _logger.e('Network error while creating account: ${e.message}');
      _accountStreamController.add(RepositoryResponse.error(exception: e));
      rethrow;
    } on AuthException catch (e) {
      _logger.e('Auth error while creating account: ${e.message}');
      _accountStreamController.add(RepositoryResponse.error(exception: e));
      rethrow;
    } catch (e) {
      _logger.e('Unexpected error in createAccount: $e');
      final exception = e is Exception ? e : Exception(e.toString());
      _accountStreamController.add(
        RepositoryResponse.error(exception: exception),
      );
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
    // Prevent duplicate syncs and rapid successive syncs
    if (_isSyncingAccountsList) {
      _logger.d(
        'Accounts list sync already in progress, skipping duplicate sync',
      );
      return;
    }

    // Check if we've synced recently (within last 30 seconds)
    final now = DateTime.now();
    if (_lastAccountsListSyncTime != null &&
        now.difference(_lastAccountsListSyncTime!).inSeconds < 30) {
      _logger.d(
        'Accounts list synced recently, skipping rapid successive sync',
      );
      return;
    }

    _isSyncingAccountsList = true;
    _lastAccountsListSyncTime = now;

    _syncService.queueOperation(() async {
      try {
        final remoteAccounts = await _remoteDataSource.getAccounts(params);
        await _localDataSource.cacheAccounts(remoteAccounts);

        // Get fresh data from local cache with consistent sorting
        final freshAccounts = await _localDataSource.getCachedAccountsByQuery(
          params,
        );
        final sortedAccounts = freshAccounts
            .map((model) => model.toEntity())
            .toList();

        // Emit success state with fresh data (only if not already emitting from background sync)
        if (!_isEmittingFromBackgroundSync) {
          _isEmittingFromBackgroundSync = true;
          _accountsStreamController.add(
            RepositoryResponse.success(sortedAccounts),
          );
          _isEmittingFromBackgroundSync = false;
        }

        _logger.d(
          'Background sync completed for accounts - UI updated with fresh data (sorted consistently)',
        );
      } catch (e) {
        _logger.w('Background sync failed for accounts: $e');
        _accountsStreamController.add(
          RepositoryResponse.error(
            exception: e is Exception ? e : Exception(e.toString()),
          ),
        );
      } finally {
        _isSyncingAccountsList = false;
      }
    });
  }

  Future<void> _syncAccountInBackground(String accountId) async {
    // Check if already syncing or processing this account
    if (_syncingAccounts.containsKey(accountId) ||
        _processingAccounts.contains(accountId)) {
      _logger.d(
        'Account $accountId is already being synced or processed, skipping duplicate sync',
      );
      return;
    }

    // Add to processing set to prevent loops
    _processingAccounts.add(accountId);

    // Create a completer to track this sync operation
    final completer = Completer<void>();
    _syncingAccounts[accountId] = completer;
    _logger.d('Starting background sync for account: $accountId');

    _syncService.queueOperation(() async {
      try {
        _logger.d(
          '🔄 About to call remote data source for account: $accountId',
        );
        final remoteAccount = await _remoteDataSource.getAccountById(accountId);
        _logger.d('✅ Remote data source returned for account: $accountId');
        await _localDataSource.updateCachedAccount(remoteAccount);

        // Update UI with fresh data via stream
        final freshAccount = remoteAccount.toEntity();
        _accountStreamController.add(RepositoryResponse.success(freshAccount));

        // Record the sync time
        _lastSyncTime[accountId] = DateTime.now();

        _logger.d(
          'Background sync completed for account: $accountId - UI updated with fresh data',
        );
      } catch (e) {
        _logger.w('Background sync failed for account $accountId: $e');
        _accountStreamController.add(
          RepositoryResponse.error(
            exception: e is Exception ? e : Exception(e.toString()),
          ),
        );
      } finally {
        // Complete the completer and remove from both sets
        if (!completer.isCompleted) {
          completer.complete();
        }
        _syncingAccounts.remove(accountId);
        _processingAccounts.remove(accountId);
        _logger.d(
          'Removed account $accountId from syncing and processing sets',
        );
      }
    });
  }

  // Clean up stream controllers and subscriptions
  void dispose() {
    _logger.d('🛑 [Accounts Repository] Disposing resources...');

    // Cancel local subscriptions
    _localAccountsSubscription?.cancel();
    _localAccountsSubscription = null;
    _localAccountSubscription?.cancel();
    _localAccountSubscription = null;

    // Close stream controllers
    if (!_accountsStreamController.isClosed) {
      _accountsStreamController.close();
    }
    if (!_accountStreamController.isClosed) {
      _accountStreamController.close();
    }

    // Clear tracking maps
    _syncingAccounts.clear();
    _lastSyncTime.clear();
    _processingAccounts.clear();

    // Note: _syncService is a shared service, don't dispose it here
    // It will be disposed separately if needed

    _logger.i('✅ [Accounts Repository] All resources disposed');
  }
}
