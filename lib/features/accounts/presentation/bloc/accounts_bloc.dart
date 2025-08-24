import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/account.dart';
import '../../domain/entities/accounts_query_params.dart';
import '../../domain/usecases/get_accounts_usecase.dart';
import '../../domain/usecases/get_account_by_id_usecase.dart';
import '../../domain/repositories/accounts_repository.dart';
import 'accounts_event.dart';
import 'accounts_state.dart';

@injectable
class AccountsBloc extends Bloc<AccountsEvent, AccountsState> {
  final GetAccountsUseCase _getAccountsUseCase;
  final GetAccountByIdUseCase _getAccountByIdUseCase;
  final AccountsRepository _accountsRepository;

  AccountsBloc({
    required GetAccountsUseCase getAccountsUseCase,
    required GetAccountByIdUseCase getAccountByIdUseCase,
    required AccountsRepository accountsRepository,
  }) : _getAccountsUseCase = getAccountsUseCase,
       _getAccountByIdUseCase = getAccountByIdUseCase,
       _accountsRepository = accountsRepository,
       super(AccountsInitial()) {
    on<LoadAccounts>(_onLoadAccounts);
    on<RefreshAccounts>(_onRefreshAccounts);
    on<LoadMoreAccounts>(_onLoadMoreAccounts);
    on<SearchAccounts>(_onSearchAccounts);
    on<FilterAccountsByCompany>(_onFilterAccountsByCompany);
    on<FilterAccountsByBalance>(_onFilterAccountsByBalance);
    on<ClearFilters>(_onClearFilters);
    on<LoadAccountDetails>(_onLoadAccountDetails);
  }

  Future<void> _onLoadAccounts(
    LoadAccounts event,
    Emitter<AccountsState> emit,
  ) async {
    try {
      emit(AccountsLoading());

      final accounts = await _getAccountsUseCase(event.params);

      emit(
        AccountsLoaded(
          accounts: accounts,
          currentOffset: event.params.offset,
          totalCount: accounts.length,
          hasReachedMax: accounts.length < event.params.limit,
        ),
      );
    } catch (e) {
      emit(AccountsFailure(e.toString()));
    }
  }

  Future<void> _onRefreshAccounts(
    RefreshAccounts event,
    Emitter<AccountsState> emit,
  ) async {
    try {
      final currentState = state;
      if (currentState is AccountsLoaded) {
        emit(AccountsRefreshing(currentState.accounts));
      }

      final accounts = await _getAccountsUseCase(event.params);

      emit(
        AccountsLoaded(
          accounts: accounts,
          currentOffset: event.params.offset,
          totalCount: accounts.length,
          hasReachedMax: accounts.length < event.params.limit,
        ),
      );
    } catch (e) {
      final currentState = state;
      if (currentState is AccountsRefreshing) {
        emit(
          AccountsFailure(
            e.toString(),
            previousAccounts: currentState.accounts,
          ),
        );
      } else {
        emit(AccountsFailure(e.toString()));
      }
    }
  }

  Future<void> _onLoadMoreAccounts(
    LoadMoreAccounts event,
    Emitter<AccountsState> emit,
  ) async {
    try {
      final currentState = state;
      if (currentState is AccountsLoaded) {
        emit(AccountsLoadingMore(currentState.accounts));

        final params = AccountsQueryParams(
          offset: event.offset,
          limit: event.limit,
        );

        final newAccounts = await _getAccountsUseCase(params);

        if (newAccounts.isEmpty) {
          emit(currentState.copyWith(hasReachedMax: true));
        } else {
          final allAccounts = [...currentState.accounts, ...newAccounts];
          emit(
            AccountsLoaded(
              accounts: allAccounts,
              currentOffset: event.offset + event.limit,
              totalCount: allAccounts.length,
              hasReachedMax: newAccounts.length < event.limit,
            ),
          );
        }
      }
    } catch (e) {
      final currentState = state;
      if (currentState is AccountsLoadingMore) {
        emit(
          AccountsFailure(
            e.toString(),
            previousAccounts: currentState.accounts,
          ),
        );
      }
    }
  }

  Future<void> _onSearchAccounts(
    SearchAccounts event,
    Emitter<AccountsState> emit,
  ) async {
    try {
      final currentState = state;
      if (currentState is AccountsLoaded) {
        emit(AccountsSearching(currentState.accounts, event.query));

        if (event.query.isEmpty) {
          // If search query is empty, reload all accounts
          final accounts = await _getAccountsUseCase(
            const AccountsQueryParams(),
          );
          emit(
            AccountsLoaded(
              accounts: accounts,
              currentOffset: 0,
              totalCount: accounts.length,
              hasReachedMax: accounts.length < 100,
            ),
          );
        } else {
          // Search accounts
          final searchResults = await _accountsRepository.searchAccounts(
            event.query,
          );
          emit(
            AccountsLoaded(
              accounts: searchResults,
              currentOffset: 0,
              totalCount: searchResults.length,
              hasReachedMax: true, // Search results are not paginated
            ),
          );
        }
      }
    } catch (e) {
      final currentState = state;
      if (currentState is AccountsSearching) {
        emit(
          AccountsFailure(
            e.toString(),
            previousAccounts: currentState.accounts,
          ),
        );
      }
    }
  }

  Future<void> _onFilterAccountsByCompany(
    FilterAccountsByCompany event,
    Emitter<AccountsState> emit,
  ) async {
    try {
      final currentState = state;
      if (currentState is AccountsLoaded) {
        emit(AccountsFiltered(currentState.accounts, 'company', event.company));

        final filteredAccounts = await _accountsRepository.getAccountsByCompany(
          event.company,
        );
        emit(
          AccountsLoaded(
            accounts: filteredAccounts,
            currentOffset: 0,
            totalCount: filteredAccounts.length,
            hasReachedMax: true, // Filtered results are not paginated
          ),
        );
      }
    } catch (e) {
      final currentState = state;
      if (currentState is AccountsFiltered) {
        emit(
          AccountsFailure(
            e.toString(),
            previousAccounts: currentState.accounts,
          ),
        );
      }
    }
  }

  Future<void> _onFilterAccountsByBalance(
    FilterAccountsByBalance event,
    Emitter<AccountsState> emit,
  ) async {
    try {
      final currentState = state;
      if (currentState is AccountsLoaded) {
        emit(
          AccountsFiltered(
            currentState.accounts,
            'balance',
            event.minBalance.toString(),
          ),
        );

        final filteredAccounts = await _accountsRepository
            .getAccountsWithBalance(event.minBalance);
        emit(
          AccountsLoaded(
            accounts: filteredAccounts,
            currentOffset: 0,
            totalCount: filteredAccounts.length,
            hasReachedMax: true, // Filtered results are not paginated
          ),
        );
      }
    } catch (e) {
      final currentState = state;
      if (currentState is AccountsFiltered) {
        emit(
          AccountsFailure(
            e.toString(),
            previousAccounts: currentState.accounts,
          ),
        );
      }
    }
  }

  Future<void> _onClearFilters(
    ClearFilters event,
    Emitter<AccountsState> emit,
  ) async {
    try {
      emit(AccountsLoading());

      final accounts = await _getAccountsUseCase(const AccountsQueryParams());

      emit(
        AccountsLoaded(
          accounts: accounts,
          currentOffset: 0,
          totalCount: accounts.length,
          hasReachedMax: accounts.length < 100,
        ),
      );
    } catch (e) {
      emit(AccountsFailure(e.toString()));
    }
  }

  Future<void> _onLoadAccountDetails(
    LoadAccountDetails event,
    Emitter<AccountsState> emit,
  ) async {
    try {
      emit(AccountDetailsLoading(event.accountId));

      final account = await _getAccountByIdUseCase(event.accountId);

      emit(AccountDetailsLoaded(account));
    } catch (e) {
      emit(AccountDetailsFailure(e.toString(), event.accountId));
    }
  }
}
