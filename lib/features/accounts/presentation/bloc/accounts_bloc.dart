import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/account.dart';
import '../../domain/entities/accounts_query_params.dart';
import '../../domain/usecases/get_accounts_usecase.dart';
import '../../domain/usecases/search_accounts_usecase.dart';
import '../../domain/usecases/get_account_by_id_usecase.dart';
import '../../domain/usecases/create_account_usecase.dart';
import '../../domain/usecases/update_account_usecase.dart';
import '../../domain/usecases/delete_account_usecase.dart';
import '../../domain/usecases/get_account_timeline_usecase.dart';
import '../../domain/usecases/get_account_tags_usecase.dart';
import '../../domain/usecases/get_all_tags_for_account_usecase.dart';
import '../../domain/usecases/assign_multiple_tags_to_account_usecase.dart';
import '../../domain/usecases/remove_multiple_tags_from_account_usecase.dart';
import '../../domain/usecases/get_account_custom_fields_usecase.dart';
import '../../domain/usecases/create_account_custom_field_usecase.dart';
import '../../domain/usecases/create_multiple_account_custom_fields_usecase.dart';
import '../../domain/usecases/update_account_custom_field_usecase.dart';
import '../../domain/usecases/update_multiple_account_custom_fields_usecase.dart';
import '../../domain/usecases/delete_account_custom_field_usecase.dart';
import '../../domain/usecases/delete_multiple_account_custom_fields_usecase.dart';
import '../../domain/usecases/get_account_emails_usecase.dart';
import '../../domain/usecases/get_account_blocking_states_usecase.dart';
import '../../domain/usecases/get_account_invoice_payments_usecase.dart';
import '../../domain/repositories/accounts_repository.dart';
import '../../domain/repositories/account_tags_repository.dart';
import '../../domain/repositories/account_custom_fields_repository.dart';
import '../../domain/repositories/account_emails_repository.dart';
import 'accounts_event.dart';
import 'accounts_state.dart';

@injectable
class AccountsBloc extends Bloc<AccountsEvent, AccountsState> {
  final GetAccountsUseCase _getAccountsUseCase;
  final SearchAccountsUseCase _searchAccountsUseCase;
  final GetAccountByIdUseCase _getAccountByIdUseCase;
  final CreateAccountUseCase _createAccountUseCase;
  final UpdateAccountUseCase _updateAccountUseCase;
  final DeleteAccountUseCase _deleteAccountUseCase;
  final GetAccountTimelineUseCase _getAccountTimelineUseCase;
  final GetAccountTagsUseCase _getAccountTagsUseCase;
  final GetAllTagsForAccountUseCase _getAllTagsForAccountUseCase;
  final AssignMultipleTagsToAccountUseCase _assignMultipleTagsToAccountUseCase;
  final RemoveMultipleTagsFromAccountUseCase _removeMultipleTagsFromAccountUseCase;
  final GetAccountCustomFieldsUseCase _getAccountCustomFieldsUseCase;
  final CreateAccountCustomFieldUseCase _createAccountCustomFieldUseCase;
  final CreateMultipleAccountCustomFieldsUseCase _createMultipleAccountCustomFieldsUseCase;
  final UpdateAccountCustomFieldUseCase _updateAccountCustomFieldUseCase;
  final UpdateMultipleAccountCustomFieldsUseCase _updateMultipleAccountCustomFieldsUseCase;
  final DeleteAccountCustomFieldUseCase _deleteAccountCustomFieldUseCase;
  final DeleteMultipleAccountCustomFieldsUseCase _deleteMultipleAccountCustomFieldsUseCase;
  final GetAccountEmailsUseCase _getAccountEmailsUseCase;
  final GetAccountBlockingStatesUseCase _getAccountBlockingStatesUseCase;
  final GetAccountInvoicePaymentsUseCase _getAccountInvoicePaymentsUseCase;
  final AccountsRepository _accountsRepository;
  final AccountTagsRepository _accountTagsRepository;
  final AccountCustomFieldsRepository _accountCustomFieldsRepository;
  final AccountEmailsRepository _accountEmailsRepository;

  AccountsBloc({
    required GetAccountsUseCase getAccountsUseCase,
    required SearchAccountsUseCase searchAccountsUseCase,
    required GetAccountByIdUseCase getAccountByIdUseCase,
    required CreateAccountUseCase createAccountUseCase,
    required UpdateAccountUseCase updateAccountUseCase,
    required DeleteAccountUseCase deleteAccountUseCase,
    required GetAccountTimelineUseCase getAccountTimelineUseCase,
    required GetAccountTagsUseCase getAccountTagsUseCase,
    required GetAllTagsForAccountUseCase getAllTagsForAccountUseCase,
    required AssignMultipleTagsToAccountUseCase assignMultipleTagsToAccountUseCase,
    required RemoveMultipleTagsFromAccountUseCase removeMultipleTagsFromAccountUseCase,
    required GetAccountCustomFieldsUseCase getAccountCustomFieldsUseCase,
    required CreateAccountCustomFieldUseCase createAccountCustomFieldUseCase,
    required CreateMultipleAccountCustomFieldsUseCase createMultipleAccountCustomFieldsUseCase,
    required UpdateAccountCustomFieldUseCase updateAccountCustomFieldUseCase,
    required UpdateMultipleAccountCustomFieldsUseCase updateMultipleAccountCustomFieldsUseCase,
    required DeleteAccountCustomFieldUseCase deleteAccountCustomFieldUseCase,
    required DeleteMultipleAccountCustomFieldsUseCase deleteMultipleAccountCustomFieldsUseCase,
    required GetAccountEmailsUseCase getAccountEmailsUseCase,
    required GetAccountBlockingStatesUseCase getAccountBlockingStatesUseCase,
    required GetAccountInvoicePaymentsUseCase getAccountInvoicePaymentsUseCase,
    required AccountsRepository accountsRepository,
    required AccountTagsRepository accountTagsRepository,
    required AccountCustomFieldsRepository accountCustomFieldsRepository,
    required AccountEmailsRepository accountEmailsRepository,
  })  : _getAccountsUseCase = getAccountsUseCase,
        _searchAccountsUseCase = searchAccountsUseCase,
        _getAccountByIdUseCase = getAccountByIdUseCase,
        _createAccountUseCase = createAccountUseCase,
        _updateAccountUseCase = updateAccountUseCase,
        _deleteAccountUseCase = deleteAccountUseCase,
        _getAccountTimelineUseCase = getAccountTimelineUseCase,
        _getAccountTagsUseCase = getAccountTagsUseCase,
        _getAllTagsForAccountUseCase = getAllTagsForAccountUseCase,
        _assignMultipleTagsToAccountUseCase = assignMultipleTagsToAccountUseCase,
        _removeMultipleTagsFromAccountUseCase = removeMultipleTagsFromAccountUseCase,
        _getAccountCustomFieldsUseCase = getAccountCustomFieldsUseCase,
        _createAccountCustomFieldUseCase = createAccountCustomFieldUseCase,
        _createMultipleAccountCustomFieldsUseCase = createMultipleAccountCustomFieldsUseCase,
        _updateAccountCustomFieldUseCase = updateAccountCustomFieldUseCase,
        _updateMultipleAccountCustomFieldsUseCase = updateMultipleAccountCustomFieldsUseCase,
        _deleteAccountCustomFieldUseCase = deleteAccountCustomFieldUseCase,
        _deleteMultipleAccountCustomFieldsUseCase = deleteMultipleAccountCustomFieldsUseCase,
        _getAccountEmailsUseCase = getAccountEmailsUseCase,
        _getAccountBlockingStatesUseCase = getAccountBlockingStatesUseCase,
        _getAccountInvoicePaymentsUseCase = getAccountInvoicePaymentsUseCase,
        _accountsRepository = accountsRepository,
        _accountTagsRepository = accountTagsRepository,
        _accountCustomFieldsRepository = accountCustomFieldsRepository,
        _accountEmailsRepository = accountEmailsRepository,
        super(AccountsInitial()) {
    on<LoadAccounts>(_onLoadAccounts);
    on<SearchAccounts>(_onSearchAccounts);
    on<RefreshAccounts>(_onRefreshAccounts);
    on<LoadMoreAccounts>(_onLoadMoreAccounts);
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
    on<LoadAccountCustomFields>(_onLoadAccountCustomFields);
    on<RefreshAccountCustomFields>(_onRefreshAccountCustomFields);
    on<CreateAccountCustomField>(_onCreateAccountCustomField);
    on<CreateMultipleAccountCustomFields>(_onCreateMultipleAccountCustomFields);
    on<UpdateAccountCustomField>(_onUpdateAccountCustomField);
    on<UpdateMultipleAccountCustomFields>(_onUpdateMultipleAccountCustomFields);
    on<DeleteAccountCustomField>(_onDeleteAccountCustomField);
    on<DeleteMultipleAccountCustomFields>(_onDeleteMultipleAccountCustomFields);
    on<LoadAccountEmails>(_onLoadAccountEmails);
    on<RefreshAccountEmails>(_onRefreshAccountEmails);
    on<CreateAccountEmail>(_onCreateAccountEmail);
    on<UpdateAccountEmail>(_onUpdateAccountEmail);
    on<DeleteAccountEmail>(_onDeleteAccountEmail);
    on<LoadAccountBlockingStates>(_onLoadAccountBlockingStates);
    on<RefreshAccountBlockingStates>(_onRefreshAccountBlockingStates);
    on<LoadAccountInvoicePayments>(_onLoadAccountInvoicePayments);
    on<RefreshAccountInvoicePayments>(_onRefreshAccountInvoicePayments);
  }

  Future<void> _onLoadAccounts(
    LoadAccounts event,
    Emitter<AccountsState> emit,
  ) async {
    try {
      emit(AccountsLoading(event.params));
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
        final nextParams = AccountsQueryParams(
          offset: currentState.currentOffset + currentState.accounts.length,
          limit: 20,
        );
        emit(AccountsLoadingMore(currentState.accounts));
        final moreAccounts = await _getAccountsUseCase(nextParams);
        final allAccounts = [...currentState.accounts, ...moreAccounts];
        emit(
          currentState.copyWith(
            accounts: allAccounts,
            currentOffset: nextParams.offset,
            hasReachedMax: moreAccounts.length < 20,
          ),
        );
      }
    } catch (e) {
      emit(AccountsFailure(e.toString()));
    }
  }

  Future<void> _onSearchAccounts(
    SearchAccounts event,
    Emitter<AccountsState> emit,
  ) async {
    try {
      emit(AccountsSearching(event.searchKey));
      final accounts = await _searchAccountsUseCase(event.searchKey);
      emit(AccountsSearchResults(accounts, event.searchKey));
    } catch (e) {
      emit(AccountsFailure(e.toString()));
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
      emit(AccountsLoading(const AccountsQueryParams()));

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

  Future<void> _onLoadAccountCustomFields(
    LoadAccountCustomFields event,
    Emitter<AccountsState> emit,
  ) async {
    try {
      emit(AccountCustomFieldsLoading(event.accountId));
      final customFields = await _accountCustomFieldsRepository.getAccountCustomFields(event.accountId);
      emit(AccountCustomFieldsLoaded(event.accountId, customFields));
    } catch (e) {
      emit(AccountCustomFieldsFailure(e.toString(), event.accountId));
    }
  }

  Future<void> _onRefreshAccountCustomFields(
    RefreshAccountCustomFields event,
    Emitter<AccountsState> emit,
  ) async {
    try {
      emit(AccountCustomFieldsLoading(event.accountId));
      final customFields = await _accountCustomFieldsRepository.getAccountCustomFields(event.accountId);
      emit(AccountCustomFieldsLoaded(event.accountId, customFields));
    } catch (e) {
      emit(AccountCustomFieldsFailure(e.toString(), event.accountId));
    }
  }

  Future<void> _onCreateAccountCustomField(
    CreateAccountCustomField event,
    Emitter<AccountsState> emit,
  ) async {
    try {
      emit(CustomFieldCreating(event.accountId, event.name, event.value));
      final createdCustomField = await _accountCustomFieldsRepository.createCustomField(
        event.accountId,
        event.name,
        event.value,
      );
      emit(CustomFieldCreated(event.accountId, createdCustomField));
    } catch (e) {
      emit(CustomFieldCreationFailure(e.toString(), event.accountId, event.name, event.value));
    }
  }

  Future<void> _onCreateMultipleAccountCustomFields(
    CreateMultipleAccountCustomFields event,
    Emitter<AccountsState> emit,
  ) async {
    try {
      emit(MultipleCustomFieldsCreating(event.accountId, event.customFields));
      final createdCustomFields = await _accountCustomFieldsRepository.createMultipleCustomFields(
        event.accountId,
        event.customFields,
      );
      emit(MultipleCustomFieldsCreated(event.accountId, createdCustomFields));
    } catch (e) {
      emit(MultipleCustomFieldsCreationFailure(e.toString(), event.accountId, event.customFields));
    }
  }

  Future<void> _onUpdateAccountCustomField(
    UpdateAccountCustomField event,
    Emitter<AccountsState> emit,
  ) async {
    try {
      emit(CustomFieldUpdating(event.accountId, event.customFieldId, event.name, event.value));
      final updatedCustomField = await _accountCustomFieldsRepository.updateCustomField(
        event.accountId,
        event.customFieldId,
        event.name,
        event.value,
      );
      emit(CustomFieldUpdated(event.accountId, updatedCustomField));
    } catch (e) {
      emit(CustomFieldUpdateFailure(e.toString(), event.accountId, event.customFieldId, event.name, event.value));
    }
  }

  Future<void> _onUpdateMultipleAccountCustomFields(
    UpdateMultipleAccountCustomFields event,
    Emitter<AccountsState> emit,
  ) async {
    try {
      emit(MultipleCustomFieldsUpdating(event.accountId, event.customFields));
      final updatedCustomFields = await _accountCustomFieldsRepository.updateMultipleCustomFields(
        event.accountId,
        event.customFields,
      );
      emit(MultipleCustomFieldsUpdated(event.accountId, updatedCustomFields));
    } catch (e) {
      emit(MultipleCustomFieldsUpdateFailure(e.toString(), event.accountId, event.customFields));
    }
  }

  Future<void> _onDeleteAccountCustomField(
    DeleteAccountCustomField event,
    Emitter<AccountsState> emit,
  ) async {
    try {
      emit(CustomFieldDeleting(event.accountId, event.customFieldId));
      await _accountCustomFieldsRepository.deleteCustomField(event.accountId, event.customFieldId);
      emit(CustomFieldDeleted(event.accountId, event.customFieldId));
    } catch (e) {
      emit(CustomFieldDeletionFailure(e.toString(), event.accountId, event.customFieldId));
    }
  }

  Future<void> _onDeleteMultipleAccountCustomFields(
    DeleteMultipleAccountCustomFields event,
    Emitter<AccountsState> emit,
  ) async {
    try {
      emit(MultipleCustomFieldsDeleting(event.accountId, event.customFieldIds));
      await _accountCustomFieldsRepository.deleteMultipleCustomFields(
        event.accountId,
        event.customFieldIds,
      );
      emit(MultipleCustomFieldsDeleted(event.accountId, event.customFieldIds));
    } catch (e) {
      emit(MultipleCustomFieldsDeletionFailure(e.toString(), event.accountId, event.customFieldIds));
    }
  }

  Future<void> _onLoadAccountEmails(
    LoadAccountEmails event,
    Emitter<AccountsState> emit,
  ) async {
    try {
      emit(AccountEmailsLoading(event.accountId));
      final emails = await _accountEmailsRepository.getAccountEmails(event.accountId);
      emit(AccountEmailsLoaded(event.accountId, emails));
    } catch (e) {
      emit(AccountEmailsFailure(e.toString(), event.accountId));
    }
  }

  Future<void> _onRefreshAccountEmails(
    RefreshAccountEmails event,
    Emitter<AccountsState> emit,
  ) async {
    try {
      emit(AccountEmailsLoading(event.accountId));
      final emails = await _accountEmailsRepository.getAccountEmails(event.accountId);
      emit(AccountEmailsLoaded(event.accountId, emails));
    } catch (e) {
      emit(AccountEmailsFailure(e.toString(), event.accountId));
    }
  }

  Future<void> _onCreateAccountEmail(
    CreateAccountEmail event,
    Emitter<AccountsState> emit,
  ) async {
    try {
      emit(AccountEmailCreating(event.accountId, event.email));
      final createdEmail = await _accountEmailsRepository.createAccountEmail(
        event.accountId,
        event.email,
      );
      emit(AccountEmailCreated(event.accountId, createdEmail));
    } catch (e) {
      emit(AccountEmailCreationFailure(e.toString(), event.accountId, event.email));
    }
  }

  Future<void> _onUpdateAccountEmail(
    UpdateAccountEmail event,
    Emitter<AccountsState> emit,
  ) async {
    try {
      emit(AccountEmailUpdating(event.accountId, event.emailId, event.email));
      final updatedEmail = await _accountEmailsRepository.updateAccountEmail(
        event.accountId,
        event.emailId,
        event.email,
      );
      emit(AccountEmailUpdated(event.accountId, updatedEmail));
    } catch (e) {
      emit(AccountEmailUpdateFailure(e.toString(), event.accountId, event.emailId, event.email));
    }
  }

  Future<void> _onDeleteAccountEmail(
    DeleteAccountEmail event,
    Emitter<AccountsState> emit,
  ) async {
    try {
      emit(AccountEmailDeleting(event.accountId, event.emailId));
      await _accountEmailsRepository.deleteAccountEmail(event.accountId, event.emailId);
      emit(AccountEmailDeleted(event.accountId, event.emailId));
    } catch (e) {
      emit(AccountEmailDeletionFailure(e.toString(), event.accountId, event.emailId));
    }
  }

  Future<void> _onLoadAccountBlockingStates(
    LoadAccountBlockingStates event,
    Emitter<AccountsState> emit,
  ) async {
    try {
      emit(AccountBlockingStatesLoading(event.accountId));
      final blockingStates = await _getAccountBlockingStatesUseCase(event.accountId);
      emit(AccountBlockingStatesLoaded(event.accountId, blockingStates));
    } catch (e) {
      emit(AccountBlockingStatesFailure(e.toString(), event.accountId));
    }
  }

  Future<void> _onRefreshAccountBlockingStates(
    RefreshAccountBlockingStates event,
    Emitter<AccountsState> emit,
  ) async {
    try {
      emit(AccountBlockingStatesLoading(event.accountId));
      final blockingStates = await _getAccountBlockingStatesUseCase(event.accountId);
      emit(AccountBlockingStatesLoaded(event.accountId, blockingStates));
    } catch (e) {
      emit(AccountBlockingStatesFailure(e.toString(), event.accountId));
    }
  }

  Future<void> _onLoadAccountInvoicePayments(
    LoadAccountInvoicePayments event,
    Emitter<AccountsState> emit,
  ) async {
    try {
      emit(AccountInvoicePaymentsLoading(event.accountId));
      final payments = await _getAccountInvoicePaymentsUseCase(event.accountId);
      emit(AccountInvoicePaymentsLoaded(event.accountId, payments));
    } catch (e) {
      emit(AccountInvoicePaymentsFailure(e.toString(), event.accountId));
    }
  }

  Future<void> _onRefreshAccountInvoicePayments(
    RefreshAccountInvoicePayments event,
    Emitter<AccountsState> emit,
  ) async {
    try {
      emit(AccountInvoicePaymentsLoading(event.accountId));
      final payments = await _getAccountInvoicePaymentsUseCase(event.accountId);
      emit(AccountInvoicePaymentsLoaded(event.accountId, payments));
    } catch (e) {
      emit(AccountInvoicePaymentsFailure(e.toString(), event.accountId));
    }
  }
}
