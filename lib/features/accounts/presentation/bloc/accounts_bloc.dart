import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/account.dart';
import '../../domain/entities/accounts_query_params.dart';
import '../../domain/usecases/get_accounts_usecase.dart';
import '../../domain/usecases/get_account_by_id_usecase.dart';
import '../../domain/usecases/create_account_usecase.dart';
import '../../domain/usecases/update_account_usecase.dart';
import '../../domain/usecases/delete_account_usecase.dart';
import '../../domain/usecases/get_account_timeline_usecase.dart';
import '../../domain/usecases/get_account_tags_usecase.dart';
import '../../domain/usecases/get_all_tags_for_account_usecase.dart';
import '../../domain/usecases/assign_multiple_tags_to_account_usecase.dart';
import '../../domain/usecases/remove_multiple_tags_from_account_usecase.dart';
import '../../domain/repositories/accounts_repository.dart';
import '../../domain/repositories/account_tags_repository.dart';
import 'accounts_event.dart';
import 'accounts_state.dart';

@injectable
class AccountsBloc extends Bloc<AccountsEvent, AccountsState> {
  final GetAccountsUseCase _getAccountsUseCase;
  final GetAccountByIdUseCase _getAccountByIdUseCase;
  final CreateAccountUseCase _createAccountUseCase;
  final UpdateAccountUseCase _updateAccountUseCase;
  final DeleteAccountUseCase _deleteAccountUseCase;
  final GetAccountTimelineUseCase _getAccountTimelineUseCase;
  final GetAccountTagsUseCase _getAccountTagsUseCase;
  final GetAllTagsForAccountUseCase _getAllTagsForAccountUseCase;
  final AssignMultipleTagsToAccountUseCase _assignMultipleTagsToAccountUseCase;
  final RemoveMultipleTagsFromAccountUseCase _removeMultipleTagsFromAccountUseCase;
  final AccountsRepository _accountsRepository;
  final AccountTagsRepository _accountTagsRepository;

  AccountsBloc({
    required GetAccountsUseCase getAccountsUseCase,
    required GetAccountByIdUseCase getAccountByIdUseCase,
    required CreateAccountUseCase createAccountUseCase,
    required UpdateAccountUseCase updateAccountUseCase,
    required DeleteAccountUseCase deleteAccountUseCase,
    required GetAccountTimelineUseCase getAccountTimelineUseCase,
    required GetAccountTagsUseCase getAccountTagsUseCase,
    required GetAllTagsForAccountUseCase getAllTagsForAccountUseCase,
    required AssignMultipleTagsToAccountUseCase assignMultipleTagsToAccountUseCase,
    required RemoveMultipleTagsFromAccountUseCase removeMultipleTagsFromAccountUseCase,
    required AccountsRepository accountsRepository,
    required AccountTagsRepository accountTagsRepository,
  })  : _getAccountsUseCase = getAccountsUseCase,
        _getAccountByIdUseCase = getAccountByIdUseCase,
        _createAccountUseCase = createAccountUseCase,
        _updateAccountUseCase = updateAccountUseCase,
        _deleteAccountUseCase = deleteAccountUseCase,
        _getAccountTimelineUseCase = getAccountTimelineUseCase,
        _getAccountTagsUseCase = getAccountTagsUseCase,
        _getAllTagsForAccountUseCase = getAllTagsForAccountUseCase,
        _assignMultipleTagsToAccountUseCase = assignMultipleTagsToAccountUseCase,
        _removeMultipleTagsFromAccountUseCase = removeMultipleTagsFromAccountUseCase,
        _accountsRepository = accountsRepository,
        _accountTagsRepository = accountTagsRepository,
        super(AccountsInitial()) {
    on<LoadAccounts>(_onLoadAccounts);
    on<RefreshAccounts>(_onRefreshAccounts);
    on<LoadMoreAccounts>(_onLoadMoreAccounts);
    on<SearchAccounts>(_onSearchAccounts);
    on<FilterAccountsByCompany>(_onFilterAccountsByCompany);
    on<FilterAccountsByBalance>(_onFilterAccountsByBalance);
    on<ClearFilters>(_onClearFilters);
    on<LoadAccountDetails>(_onLoadAccountDetails);
    on<CreateAccount>(_onCreateAccount);
    on<UpdateAccount>(_onUpdateAccount);
    on<DeleteAccount>(_onDeleteAccount);
    on<LoadAccountTimeline>(_onLoadAccountTimeline);
    on<RefreshAccountTimeline>(_onRefreshAccountTimeline);
    on<LoadAccountTags>(_onLoadAccountTags);
    on<RefreshAccountTags>(_onRefreshAccountTags);
    on<AssignTagToAccount>(_onAssignTagToAccount);
    on<RemoveTagFromAccount>(_onRemoveTagFromAccount);
    on<LoadAllTagsForAccount>(_onLoadAllTagsForAccount);
    on<RefreshAllTagsForAccount>(_onRefreshAllTagsForAccount);
    on<AssignMultipleTagsToAccount>(_onAssignMultipleTagsToAccount);
    on<RemoveMultipleTagsFromAccount>(_onRemoveMultipleTagsFromAccount);
    on<RemoveAllTagsFromAccount>(_onRemoveAllTagsFromAccount);
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

  Future<void> _onCreateAccount(
    CreateAccount event,
    Emitter<AccountsState> emit,
  ) async {
    try {
      emit(AccountCreating());

      final newAccount = await _createAccountUseCase(event.account);

      emit(AccountCreated(newAccount));
    } catch (e) {
      emit(AccountCreationFailure(e.toString()));
    }
  }

  Future<void> _onUpdateAccount(
    UpdateAccount event,
    Emitter<AccountsState> emit,
  ) async {
    try {
      emit(AccountUpdating());

      final updatedAccount = await _updateAccountUseCase(event.account);

      emit(AccountUpdated(updatedAccount));
    } catch (e) {
      emit(AccountUpdateFailure(e.toString()));
    }
  }

  Future<void> _onDeleteAccount(
    DeleteAccount event,
    Emitter<AccountsState> emit,
  ) async {
    try {
      emit(AccountDeleting());
      await _deleteAccountUseCase(event.accountId);
      emit(AccountDeleted(event.accountId));
    } catch (e) {
      emit(AccountDeletionFailure(e.toString(), event.accountId));
    }
  }

  Future<void> _onLoadAccountTimeline(
    LoadAccountTimeline event,
    Emitter<AccountsState> emit,
  ) async {
    try {
      emit(AccountTimelineLoading(event.accountId));
      final timeline = await _getAccountTimelineUseCase(event.accountId);
      emit(AccountTimelineLoaded(event.accountId, timeline.events));
    } catch (e) {
      emit(AccountTimelineFailure(e.toString(), event.accountId));
    }
  }

  Future<void> _onRefreshAccountTimeline(
    RefreshAccountTimeline event,
    Emitter<AccountsState> emit,
  ) async {
    try {
      emit(AccountTimelineLoading(event.accountId));
      final timeline = await _getAccountTimelineUseCase(event.accountId);
      emit(AccountTimelineLoaded(event.accountId, timeline.events));
    } catch (e) {
      emit(AccountTimelineFailure(e.toString(), event.accountId));
    }
  }

  Future<void> _onLoadAccountTags(
    LoadAccountTags event,
    Emitter<AccountsState> emit,
  ) async {
    try {
      emit(AccountTagsLoading(event.accountId));
      final tags = await _getAccountTagsUseCase(event.accountId);
      emit(AccountTagsLoaded(event.accountId, tags));
    } catch (e) {
      emit(AccountTagsFailure(e.toString(), event.accountId));
    }
  }

  Future<void> _onRefreshAccountTags(
    RefreshAccountTags event,
    Emitter<AccountsState> emit,
  ) async {
    try {
      emit(AccountTagsLoading(event.accountId));
      final tags = await _getAccountTagsUseCase(event.accountId);
      emit(AccountTagsLoaded(event.accountId, tags));
    } catch (e) {
      emit(AccountTagsFailure(e.toString(), event.accountId));
    }
  }

  Future<void> _onAssignTagToAccount(
    AssignTagToAccount event,
    Emitter<AccountsState> emit,
  ) async {
    try {
      emit(TagAssigning(event.accountId, event.tagId));
      final assignedTag = await _accountTagsRepository.assignTagToAccount(
        event.accountId,
        event.tagId,
      );
      emit(TagAssigned(event.accountId, assignedTag));
    } catch (e) {
      emit(TagAssignmentFailure(e.toString(), event.accountId, event.tagId));
    }
  }

  Future<void> _onRemoveTagFromAccount(
    RemoveTagFromAccount event,
    Emitter<AccountsState> emit,
  ) async {
    try {
      emit(TagRemoving(event.accountId, event.tagId));
      await _accountTagsRepository.removeTagFromAccount(
        event.accountId,
        event.tagId,
      );
      emit(TagRemoved(event.accountId, event.tagId));
    } catch (e) {
      emit(TagRemovalFailure(e.toString(), event.accountId, event.tagId));
    }
  }

  Future<void> _onLoadAllTagsForAccount(
    LoadAllTagsForAccount event,
    Emitter<AccountsState> emit,
  ) async {
    try {
      emit(AllTagsForAccountLoading(event.accountId));
      final tags = await _getAllTagsForAccountUseCase(event.accountId);
      emit(AllTagsForAccountLoaded(event.accountId, tags));
    } catch (e) {
      emit(AllTagsForAccountFailure(e.toString(), event.accountId));
    }
  }

  Future<void> _onRefreshAllTagsForAccount(
    RefreshAllTagsForAccount event,
    Emitter<AccountsState> emit,
  ) async {
    try {
      emit(AllTagsForAccountLoading(event.accountId));
      final tags = await _getAllTagsForAccountUseCase(event.accountId);
      emit(AllTagsForAccountLoaded(event.accountId, tags));
    } catch (e) {
      emit(AllTagsForAccountFailure(e.toString(), event.accountId));
    }
  }

  Future<void> _onAssignMultipleTagsToAccount(
    AssignMultipleTagsToAccount event,
    Emitter<AccountsState> emit,
  ) async {
    try {
      emit(MultipleTagsAssigning(event.accountId, event.tagIds));
      final assignedTags = await _assignMultipleTagsToAccountUseCase(
        event.accountId,
        event.tagIds,
      );
      emit(MultipleTagsAssigned(event.accountId, assignedTags));
    } catch (e) {
      emit(MultipleTagsAssignmentFailure(e.toString(), event.accountId, event.tagIds));
    }
  }

  Future<void> _onRemoveMultipleTagsFromAccount(
    RemoveMultipleTagsFromAccount event,
    Emitter<AccountsState> emit,
  ) async {
    try {
      emit(MultipleTagsRemoving(event.accountId, event.tagIds));
      await _removeMultipleTagsFromAccountUseCase(
        event.accountId,
        event.tagIds,
      );
      emit(MultipleTagsRemoved(event.accountId, event.tagIds));
    } catch (e) {
      emit(MultipleTagsRemovalFailure(e.toString(), event.accountId, event.tagIds));
    }
  }

  Future<void> _onRemoveAllTagsFromAccount(
    RemoveAllTagsFromAccount event,
    Emitter<AccountsState> emit,
  ) async {
    try {
      emit(AllTagsRemoving(event.accountId));
      // Get current tags to remove them all
      final currentTags = await _getAccountTagsUseCase(event.accountId);
      if (currentTags.isNotEmpty) {
        final tagIds = currentTags.map((tag) => tag.tagId).toList();
        await _removeMultipleTagsFromAccountUseCase(event.accountId, tagIds);
      }
      emit(AllTagsRemoved(event.accountId));
    } catch (e) {
      emit(AllTagsRemovalFailure(e.toString(), event.accountId));
    }
  }
}
