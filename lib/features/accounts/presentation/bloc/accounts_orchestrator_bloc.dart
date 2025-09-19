import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'accounts_list_bloc.dart';
import 'account_detail_bloc.dart';
import 'account_multiselect_bloc.dart';
import 'account_export_bloc.dart';
import 'events/accounts_event.dart';
import 'events/accounts_list_events.dart' as list_events;
import 'events/account_detail_events.dart' as detail_events;
import 'events/account_multiselect_events.dart' as multiselect_events;
import 'events/account_export_events.dart' as export_events;
import 'states/accounts_state.dart';

/// Main orchestrator BLoC that coordinates between specialized BLoCs
@injectable
class AccountsOrchestratorBloc extends Bloc<AccountsEvent, AccountsState> {
  final AccountsListBloc _accountsListBloc;
  final AccountDetailBloc _accountDetailBloc;
  final AccountMultiSelectBloc _accountMultiSelectBloc;
  final AccountExportBloc _accountExportBloc;

  StreamSubscription? _accountsListSubscription;
  StreamSubscription? _accountDetailSubscription;
  StreamSubscription? _accountMultiSelectSubscription;
  StreamSubscription? _accountExportSubscription;

  AccountsOrchestratorBloc({
    required AccountsListBloc accountsListBloc,
    required AccountDetailBloc accountDetailBloc,
    required AccountMultiSelectBloc accountMultiSelectBloc,
    required AccountExportBloc accountExportBloc,
  }) : _accountsListBloc = accountsListBloc,
       _accountDetailBloc = accountDetailBloc,
       _accountMultiSelectBloc = accountMultiSelectBloc,
       _accountExportBloc = accountExportBloc,
       super(AccountsInitial()) {
    // Register event handlers
    _registerEventHandlers();

    // Initialize stream subscriptions
    _initializeStreamSubscriptions();
  }

  void _registerEventHandlers() {
    // Accounts List Events
    on<LoadAccounts>(_onLoadAccounts);
    on<RefreshAccounts>(_onRefreshAccounts);
    on<LoadMoreAccounts>(_onLoadMoreAccounts);
    on<SearchAccounts>(_onSearchAccounts);
    on<FilterAccountsByCompany>(_onFilterAccountsByCompany);
    on<FilterAccountsByBalance>(_onFilterAccountsByBalance);
    on<SortAccounts>(_onSortAccounts);
    on<ClearAccountsFilters>(_onClearAccountsFilters);

    // Account Detail Events
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
    on<AssignMultipleTagsToAccount>(_onAssignMultipleTagsToAccount);
    on<RemoveMultipleTagsFromAccount>(_onRemoveMultipleTagsFromAccount);
    on<LoadAllTagsForAccount>(_onLoadAllTagsForAccount);
    on<LoadAccountCustomFields>(_onLoadAccountCustomFields);
    on<CreateAccountCustomField>(_onCreateAccountCustomField);
    on<UpdateAccountCustomField>(_onUpdateAccountCustomField);
    on<DeleteAccountCustomField>(_onDeleteAccountCustomField);
    on<LoadAccountEmails>(_onLoadAccountEmails);
    on<LoadAccountBlockingStates>(_onLoadAccountBlockingStates);
    on<LoadAccountInvoicePayments>(_onLoadAccountInvoicePayments);
    on<LoadAccountAuditLogs>(_onLoadAccountAuditLogs);
    on<LoadAccountPaymentMethods>(_onLoadAccountPaymentMethods);
    on<LoadAccountPayments>(_onLoadAccountPayments);
    on<CreateAccountPayment>(_onCreateAccountPayment);

    // Multi-Select Events
    on<EnableMultiSelectMode>(_onEnableMultiSelectMode);
    on<DisableMultiSelectMode>(_onDisableMultiSelectMode);
    on<SelectAccount>(_onSelectAccount);
    on<DeselectAccount>(_onDeselectAccount);
    on<SelectAllAccounts>(_onSelectAllAccounts);
    on<DeselectAllAccounts>(_onDeselectAllAccounts);
    on<BulkDeleteAccounts>(_onBulkDeleteAccounts);

    // Export Events
    on<ExportAccounts>(_onExportAccounts);
    on<ExportSelectedAccounts>(_onExportSelectedAccounts);
    on<ShareFile>(_onShareExportedFile);
  }

  void _initializeStreamSubscriptions() {
    // Listen to accounts list state changes
    _accountsListSubscription = _accountsListBloc.stream.listen((state) {
      // Note: We don't emit states from stream listeners as it's not allowed
      // The UI should listen to the individual specialized blocs directly
    });

    // Listen to account detail state changes
    _accountDetailSubscription = _accountDetailBloc.stream.listen((state) {
      // Note: We don't emit states from stream listeners as it's not allowed
      // The UI should listen to the individual specialized blocs directly
    });

    // Listen to multi-select state changes
    _accountMultiSelectSubscription = _accountMultiSelectBloc.stream.listen((
      state,
    ) {
      // Note: We don't emit states from stream listeners as it's not allowed
      // The UI should listen to the individual specialized blocs directly
    });

    // Listen to export state changes
    _accountExportSubscription = _accountExportBloc.stream.listen((state) {
      // Note: We don't emit states from stream listeners as it's not allowed
      // The UI should listen to the individual specialized blocs directly
    });
  }

  // Accounts List Event Handlers
  Future<void> _onLoadAccounts(
    LoadAccounts event,
    Emitter<AccountsState> emit,
  ) async {
    _accountsListBloc.add(list_events.LoadAccounts(event.params));
  }

  Future<void> _onRefreshAccounts(
    RefreshAccounts event,
    Emitter<AccountsState> emit,
  ) async {
    _accountsListBloc.add(list_events.RefreshAccounts());
  }

  Future<void> _onLoadMoreAccounts(
    LoadMoreAccounts event,
    Emitter<AccountsState> emit,
  ) async {
    _accountsListBloc.add(list_events.LoadMoreAccounts());
  }

  Future<void> _onSearchAccounts(
    SearchAccounts event,
    Emitter<AccountsState> emit,
  ) async {
    _accountsListBloc.add(list_events.SearchAccounts(event.searchKey));
  }

  Future<void> _onFilterAccountsByCompany(
    FilterAccountsByCompany event,
    Emitter<AccountsState> emit,
  ) async {
    _accountsListBloc.add(list_events.FilterAccountsByCompany(event.company));
  }

  Future<void> _onFilterAccountsByBalance(
    FilterAccountsByBalance event,
    Emitter<AccountsState> emit,
  ) async {
    _accountsListBloc.add(
      list_events.FilterAccountsByBalance(
        minBalance: event.minBalance,
        maxBalance: event.maxBalance,
      ),
    );
  }

  Future<void> _onSortAccounts(
    SortAccounts event,
    Emitter<AccountsState> emit,
  ) async {
    _accountsListBloc.add(
      list_events.SortAccounts(event.sortBy, event.sortOrder),
    );
  }

  Future<void> _onClearAccountsFilters(
    ClearAccountsFilters event,
    Emitter<AccountsState> emit,
  ) async {
    _accountsListBloc.add(list_events.ClearAccountsFilters());
  }

  // Account Detail Event Handlers
  Future<void> _onLoadAccountDetails(
    LoadAccountDetails event,
    Emitter<AccountsState> emit,
  ) async {
    _accountDetailBloc.add(detail_events.LoadAccountDetails(event.accountId));
  }

  Future<void> _onCreateAccount(
    CreateAccount event,
    Emitter<AccountsState> emit,
  ) async {
    _accountDetailBloc.add(detail_events.CreateAccount(event.account));
  }

  Future<void> _onUpdateAccount(
    UpdateAccount event,
    Emitter<AccountsState> emit,
  ) async {
    _accountDetailBloc.add(detail_events.UpdateAccount(event.account));
  }

  Future<void> _onDeleteAccount(
    DeleteAccount event,
    Emitter<AccountsState> emit,
  ) async {
    _accountDetailBloc.add(detail_events.DeleteAccount(event.accountId));
  }

  Future<void> _onLoadAccountTimeline(
    LoadAccountTimeline event,
    Emitter<AccountsState> emit,
  ) async {
    _accountDetailBloc.add(detail_events.LoadAccountTimeline(event.accountId));
  }

  Future<void> _onRefreshAccountTimeline(
    RefreshAccountTimeline event,
    Emitter<AccountsState> emit,
  ) async {
    _accountDetailBloc.add(
      detail_events.RefreshAccountTimeline(event.accountId),
    );
  }

  Future<void> _onLoadAccountTags(
    LoadAccountTags event,
    Emitter<AccountsState> emit,
  ) async {
    _accountDetailBloc.add(detail_events.LoadAccountTags(event.accountId));
  }

  Future<void> _onRefreshAccountTags(
    RefreshAccountTags event,
    Emitter<AccountsState> emit,
  ) async {
    _accountDetailBloc.add(detail_events.RefreshAccountTags(event.accountId));
  }

  Future<void> _onAssignTagToAccount(
    AssignTagToAccount event,
    Emitter<AccountsState> emit,
  ) async {
    _accountDetailBloc.add(
      detail_events.AssignTagToAccount(event.accountId, event.tagId),
    );
  }

  Future<void> _onRemoveTagFromAccount(
    RemoveTagFromAccount event,
    Emitter<AccountsState> emit,
  ) async {
    _accountDetailBloc.add(
      detail_events.RemoveTagFromAccount(event.accountId, event.tagId),
    );
  }

  Future<void> _onAssignMultipleTagsToAccount(
    AssignMultipleTagsToAccount event,
    Emitter<AccountsState> emit,
  ) async {
    _accountDetailBloc.add(
      detail_events.AssignMultipleTagsToAccount(event.accountId, event.tagIds),
    );
  }

  Future<void> _onRemoveMultipleTagsFromAccount(
    RemoveMultipleTagsFromAccount event,
    Emitter<AccountsState> emit,
  ) async {
    _accountDetailBloc.add(
      detail_events.RemoveMultipleTagsFromAccount(
        event.accountId,
        event.tagIds,
      ),
    );
  }

  Future<void> _onLoadAllTagsForAccount(
    LoadAllTagsForAccount event,
    Emitter<AccountsState> emit,
  ) async {
    _accountDetailBloc.add(
      detail_events.LoadAllTagsForAccount(event.accountId),
    );
  }

  Future<void> _onLoadAccountCustomFields(
    LoadAccountCustomFields event,
    Emitter<AccountsState> emit,
  ) async {
    _accountDetailBloc.add(
      detail_events.LoadAccountCustomFields(event.accountId),
    );
  }

  Future<void> _onCreateAccountCustomField(
    CreateAccountCustomField event,
    Emitter<AccountsState> emit,
  ) async {
    _accountDetailBloc.add(
      detail_events.CreateAccountCustomField(event.accountId, {
        'name': event.name,
        'value': event.value,
      }),
    );
  }

  Future<void> _onUpdateAccountCustomField(
    UpdateAccountCustomField event,
    Emitter<AccountsState> emit,
  ) async {
    _accountDetailBloc.add(
      detail_events.UpdateAccountCustomField(
        event.accountId,
        event.customFieldId,
        {'name': event.name, 'value': event.value},
      ),
    );
  }

  Future<void> _onDeleteAccountCustomField(
    DeleteAccountCustomField event,
    Emitter<AccountsState> emit,
  ) async {
    _accountDetailBloc.add(
      detail_events.DeleteAccountCustomField(
        event.accountId,
        event.customFieldId,
      ),
    );
  }

  Future<void> _onLoadAccountEmails(
    LoadAccountEmails event,
    Emitter<AccountsState> emit,
  ) async {
    _accountDetailBloc.add(detail_events.LoadAccountEmails(event.accountId));
  }

  Future<void> _onLoadAccountBlockingStates(
    LoadAccountBlockingStates event,
    Emitter<AccountsState> emit,
  ) async {
    _accountDetailBloc.add(
      detail_events.LoadAccountBlockingStates(event.accountId),
    );
  }

  Future<void> _onLoadAccountInvoicePayments(
    LoadAccountInvoicePayments event,
    Emitter<AccountsState> emit,
  ) async {
    _accountDetailBloc.add(
      detail_events.LoadAccountInvoicePayments(event.accountId),
    );
  }

  Future<void> _onLoadAccountAuditLogs(
    LoadAccountAuditLogs event,
    Emitter<AccountsState> emit,
  ) async {
    _accountDetailBloc.add(detail_events.LoadAccountAuditLogs(event.accountId));
  }

  Future<void> _onLoadAccountPaymentMethods(
    LoadAccountPaymentMethods event,
    Emitter<AccountsState> emit,
  ) async {
    _accountDetailBloc.add(
      detail_events.LoadAccountPaymentMethods(event.accountId),
    );
  }

  Future<void> _onLoadAccountPayments(
    LoadAccountPayments event,
    Emitter<AccountsState> emit,
  ) async {
    _accountDetailBloc.add(detail_events.LoadAccountPayments(event.accountId));
  }

  Future<void> _onCreateAccountPayment(
    CreateAccountPayment event,
    Emitter<AccountsState> emit,
  ) async {
    _accountDetailBloc.add(
      detail_events.CreateAccountPayment(event.accountId, {
        'paymentMethodId': event.paymentMethodId,
        'transactionType': event.transactionType,
        'amount': event.amount,
        'currency': event.currency,
        'effectiveDate': event.effectiveDate.toIso8601String(),
        'description': event.description,
        'properties': event.properties,
      }),
    );
  }

  // Multi-Select Event Handlers
  Future<void> _onEnableMultiSelectMode(
    EnableMultiSelectMode event,
    Emitter<AccountsState> emit,
  ) async {
    _accountMultiSelectBloc.add(multiselect_events.EnableMultiSelectMode());
  }

  Future<void> _onDisableMultiSelectMode(
    DisableMultiSelectMode event,
    Emitter<AccountsState> emit,
  ) async {
    _accountMultiSelectBloc.add(multiselect_events.DisableMultiSelectMode());
  }

  Future<void> _onSelectAccount(
    SelectAccount event,
    Emitter<AccountsState> emit,
  ) async {
    _accountMultiSelectBloc.add(
      multiselect_events.SelectAccount(event.account),
    );
  }

  Future<void> _onDeselectAccount(
    DeselectAccount event,
    Emitter<AccountsState> emit,
  ) async {
    _accountMultiSelectBloc.add(
      multiselect_events.DeselectAccount(event.account),
    );
  }

  Future<void> _onSelectAllAccounts(
    SelectAllAccounts event,
    Emitter<AccountsState> emit,
  ) async {
    _accountMultiSelectBloc.add(multiselect_events.SelectAllAccounts());
  }

  Future<void> _onDeselectAllAccounts(
    DeselectAllAccounts event,
    Emitter<AccountsState> emit,
  ) async {
    _accountMultiSelectBloc.add(multiselect_events.DeselectAllAccounts());
  }

  Future<void> _onBulkDeleteAccounts(
    BulkDeleteAccounts event,
    Emitter<AccountsState> emit,
  ) async {
    _accountMultiSelectBloc.add(multiselect_events.BulkDeleteAccounts());
  }

  // Export Event Handlers
  Future<void> _onExportAccounts(
    ExportAccounts event,
    Emitter<AccountsState> emit,
  ) async {
    _accountExportBloc.add(
      export_events.ExportAccounts(
        accounts: event.accounts,
        format: event.format,
      ),
    );
  }

  Future<void> _onExportSelectedAccounts(
    ExportSelectedAccounts event,
    Emitter<AccountsState> emit,
  ) async {
    _accountExportBloc.add(
      export_events.ExportSelectedAccounts(
        accountIds: event.accountIds,
        format: event.format,
      ),
    );
  }

  Future<void> _onShareExportedFile(
    ShareFile event,
    Emitter<AccountsState> emit,
  ) async {
    _accountExportBloc.add(
      export_events.ShareFile(
        filePath: event.filePath,
        fileName: event.filePath.split('/').last, // Extract filename from path
      ),
    );
  }

  @override
  Future<void> close() {
    _accountsListSubscription?.cancel();
    _accountDetailSubscription?.cancel();
    _accountMultiSelectSubscription?.cancel();
    _accountExportSubscription?.cancel();
    return super.close();
  }
}
