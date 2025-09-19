import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import '../../domain/entities/accounts_query_params.dart';
import '../../domain/repositories/accounts_repository.dart';
import '../../domain/usecases/get_accounts_usecase.dart';
import '../../domain/usecases/search_accounts_usecase.dart';
import '../bloc/events/accounts_list_events.dart';
import '../bloc/states/accounts_list_states.dart';

/// BLoC for handling account listing, searching, and filtering operations
@injectable
class AccountsListBloc extends Bloc<ListAccountsEvent, AccountsListState> {
  final GetAccountsUseCase _getAccountsUseCase;
  final SearchAccountsUseCase _searchAccountsUseCase;
  final AccountsRepository _accountsRepository;
  final Logger _logger = Logger();

  AccountsQueryParams _currentQueryParams = const AccountsQueryParams();
  StreamSubscription? _accountsStreamSubscription;

  AccountsListBloc({
    required GetAccountsUseCase getAccountsUseCase,
    required SearchAccountsUseCase searchAccountsUseCase,
    required AccountsRepository accountsRepository,
  }) : _getAccountsUseCase = getAccountsUseCase,
       _searchAccountsUseCase = searchAccountsUseCase,
       _accountsRepository = accountsRepository,
       super(const AccountsListInitial()) {
    // Register event handlers
    on<LoadAccounts>(_onLoadAccounts);
    on<GetAllAccounts>(_onGetAllAccounts);
    on<RefreshAllAccounts>(_onRefreshAllAccounts);
    on<SearchAccounts>(_onSearchAccounts);
    on<RefreshAccounts>(_onRefreshAccounts);
    on<LoadMoreAccounts>(_onLoadMoreAccounts);
    on<FilterAccountsByCompany>(_onFilterAccountsByCompany);
    on<FilterAccountsByBalance>(_onFilterAccountsByBalance);
    on<FilterAccountsByAuditLevel>(_onFilterAccountsByAuditLevel);
    on<ClearFilters>(_onClearFilters);

    // Initialize stream subscriptions for reactive updates
    _initializeStreamSubscriptions();
  }

  /// Initialize stream subscriptions for reactive updates from repository
  void _initializeStreamSubscriptions() {
    // Listen to accounts list updates from repository background sync
    _accountsStreamSubscription = _accountsRepository.accountsStream.listen(
      (response) {
        if (response.isLoading) {
          // Handle loading state - don't emit if we already have data
          final currentState = state;
          if (currentState is! AccountsListLoaded &&
              currentState is! AllAccountsLoaded) {
            add(LoadAccounts(_currentQueryParams));
          }
        } else if (response.isSuccess && response.data != null) {
          // Update accounts list with fresh data
          final accounts = response.data!;
          add(LoadAccounts(_currentQueryParams));
          _logger.d(
            'Accounts list updated from background sync: ${accounts.length} accounts',
          );
        } else if (response.hasError) {
          _logger.e('Error in accounts stream: ${response.errorMessage}');
        }
      },
      onError: (error) {
        _logger.e('Error in accounts stream subscription: $error');
      },
    );
  }

  Future<void> _onLoadAccounts(
    LoadAccounts event,
    Emitter<AccountsListState> emit,
  ) async {
    try {
      _logger.d('Loading accounts with params: ${event.params.toString()}');
      _currentQueryParams = event.params;
      emit(AccountsListLoading(event.params));

      final accounts = await _getAccountsUseCase(event.params);

      emit(
        AccountsListLoaded(
          accounts: accounts,
          currentOffset: event.params.offset,
          totalCount: accounts.length,
          hasReachedMax: accounts.length < event.params.limit,
        ),
      );

      _logger.d('Loaded ${accounts.length} accounts');
    } catch (e) {
      _logger.e('Error loading accounts: $e');
      emit(AccountsListFailure(e.toString()));
    }
  }

  Future<void> _onGetAllAccounts(
    GetAllAccounts event,
    Emitter<AccountsListState> emit,
  ) async {
    try {
      emit(const GetAllAccountsLoading());
      final accounts = await _getAccountsUseCase(const AccountsQueryParams());
      emit(AllAccountsLoaded(accounts: accounts, totalCount: accounts.length));
    } catch (e) {
      _logger.e('Error getting all accounts: $e');
      emit(AccountsListFailure(e.toString()));
    }
  }

  Future<void> _onRefreshAllAccounts(
    RefreshAllAccounts event,
    Emitter<AccountsListState> emit,
  ) async {
    try {
      emit(const AllAccountsRefreshing());
      final accounts = await _getAccountsUseCase(const AccountsQueryParams());
      emit(AllAccountsLoaded(accounts: accounts, totalCount: accounts.length));
    } catch (e) {
      _logger.e('Error refreshing all accounts: $e');
      emit(AccountsListFailure(e.toString()));
    }
  }

  Future<void> _onSearchAccounts(
    SearchAccounts event,
    Emitter<AccountsListState> emit,
  ) async {
    try {
      _logger.d('Searching accounts with key: ${event.searchKey}');
      emit(AccountsListLoading(_currentQueryParams));

      final accounts = await _searchAccountsUseCase(event.searchKey);

      emit(
        AccountsListLoaded(
          accounts: accounts,
          currentOffset: 0,
          totalCount: accounts.length,
          hasReachedMax: true, // Search results are not paginated
        ),
      );

      _logger.d(
        'Found ${accounts.length} accounts for search: ${event.searchKey}',
      );
    } catch (e) {
      _logger.e('Error searching accounts: $e');
      emit(AccountsListFailure(e.toString()));
    }
  }

  Future<void> _onRefreshAccounts(
    RefreshAccounts event,
    Emitter<AccountsListState> emit,
  ) async {
    try {
      _logger.d('Refreshing accounts');
      emit(AccountsListLoading(_currentQueryParams));

      final accounts = await _getAccountsUseCase(_currentQueryParams);

      emit(
        AccountsListLoaded(
          accounts: accounts,
          currentOffset: _currentQueryParams.offset,
          totalCount: accounts.length,
          hasReachedMax: accounts.length < _currentQueryParams.limit,
        ),
      );

      _logger.d('Refreshed ${accounts.length} accounts');
    } catch (e) {
      _logger.e('Error refreshing accounts: $e');
      emit(AccountsListFailure(e.toString()));
    }
  }

  Future<void> _onLoadMoreAccounts(
    LoadMoreAccounts event,
    Emitter<AccountsListState> emit,
  ) async {
    try {
      final currentState = state;
      if (currentState is! AccountsListLoaded || currentState.hasReachedMax) {
        return;
      }

      _logger.d('Loading more accounts');
      final nextOffset = currentState.currentOffset + _currentQueryParams.limit;
      final nextParams = _currentQueryParams.copyWith(offset: nextOffset);

      final moreAccounts = await _getAccountsUseCase(nextParams);

      if (moreAccounts.isNotEmpty) {
        final allAccounts = [...currentState.accounts, ...moreAccounts];
        emit(
          AccountsListLoaded(
            accounts: allAccounts,
            currentOffset: nextOffset,
            totalCount: allAccounts.length,
            hasReachedMax: moreAccounts.length < _currentQueryParams.limit,
          ),
        );
        _logger.d('Loaded ${moreAccounts.length} more accounts');
      }
    } catch (e) {
      _logger.e('Error loading more accounts: $e');
      emit(AccountsListFailure(e.toString()));
    }
  }

  Future<void> _onFilterAccountsByCompany(
    FilterAccountsByCompany event,
    Emitter<AccountsListState> emit,
  ) async {
    try {
      final currentState = state;
      if (currentState is AccountsListLoaded) {
        emit(AccountsFiltered(currentState.accounts, 'company', event.company));

        final params = AccountsQueryParams(
          company: event.company,
          limit: 1000, // Get all accounts with this company
        );
        final filteredAccounts = await _getAccountsUseCase(params);

        emit(
          AccountsListLoaded(
            accounts: filteredAccounts,
            currentOffset: 0,
            totalCount: filteredAccounts.length,
            hasReachedMax: true, // Filtered results are not paginated
          ),
        );
      }
    } catch (e) {
      _logger.e('Error filtering accounts by company: $e');
      final currentState = state;
      if (currentState is AccountsFiltered) {
        emit(
          AccountsListFailure(
            e.toString(),
            previousAccounts: currentState.accounts,
          ),
        );
      } else {
        emit(AccountsListFailure(e.toString()));
      }
    }
  }

  Future<void> _onFilterAccountsByBalance(
    FilterAccountsByBalance event,
    Emitter<AccountsListState> emit,
  ) async {
    try {
      final currentState = state;
      if (currentState is AccountsListLoaded) {
        emit(
          AccountsFiltered(
            currentState.accounts,
            'balance',
            '${event.minBalance}-${event.maxBalance}',
          ),
        );

        final params = AccountsQueryParams(
          minBalance: event.minBalance,
          maxBalance: event.maxBalance,
          limit: 1000, // Get all accounts in this balance range
        );
        final filteredAccounts = await _getAccountsUseCase(params);

        emit(
          AccountsListLoaded(
            accounts: filteredAccounts,
            currentOffset: 0,
            totalCount: filteredAccounts.length,
            hasReachedMax: true, // Filtered results are not paginated
          ),
        );
      }
    } catch (e) {
      _logger.e('Error filtering accounts by balance: $e');
      final currentState = state;
      if (currentState is AccountsFiltered) {
        emit(
          AccountsListFailure(
            e.toString(),
            previousAccounts: currentState.accounts,
          ),
        );
      } else {
        emit(AccountsListFailure(e.toString()));
      }
    }
  }

  Future<void> _onFilterAccountsByAuditLevel(
    FilterAccountsByAuditLevel event,
    Emitter<AccountsListState> emit,
  ) async {
    try {
      final currentState = state;
      if (currentState is AccountsListLoaded) {
        emit(
          AccountsFiltered(currentState.accounts, 'audit', event.auditLevel),
        );

        final params = AccountsQueryParams(
          audit: event.auditLevel,
          limit: 1000, // Get all accounts with this audit level
        );
        final filteredAccounts = await _getAccountsUseCase(params);

        emit(
          AccountsListLoaded(
            accounts: filteredAccounts,
            currentOffset: 0,
            totalCount: filteredAccounts.length,
            hasReachedMax: true, // Filtered results are not paginated
          ),
        );
      }
    } catch (e) {
      _logger.e('Error filtering accounts by audit level: $e');
      final currentState = state;
      if (currentState is AccountsFiltered) {
        emit(
          AccountsListFailure(
            e.toString(),
            previousAccounts: currentState.accounts,
          ),
        );
      } else {
        emit(AccountsListFailure(e.toString()));
      }
    }
  }

  Future<void> _onClearFilters(
    ClearFilters event,
    Emitter<AccountsListState> emit,
  ) async {
    try {
      _logger.d('Clearing filters');
      emit(AccountsListLoading(const AccountsQueryParams()));

      final accounts = await _getAccountsUseCase(const AccountsQueryParams());

      emit(
        AccountsListLoaded(
          accounts: accounts,
          currentOffset: 0,
          totalCount: accounts.length,
          hasReachedMax: accounts.length < 100,
        ),
      );
    } catch (e) {
      _logger.e('Error clearing filters: $e');
      emit(AccountsListFailure(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _accountsStreamSubscription?.cancel();
    return super.close();
  }
}
