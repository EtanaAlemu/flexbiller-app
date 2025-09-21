import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import '../../domain/repositories/accounts_repository.dart';
import '../../domain/usecases/get_account_by_id_usecase.dart';
import '../../domain/usecases/create_account_usecase.dart';
import '../../domain/usecases/update_account_usecase.dart';
import '../../domain/usecases/delete_account_usecase.dart';
import '../../domain/usecases/get_account_timeline_usecase.dart';
import '../../domain/usecases/get_account_tags_usecase.dart';
import '../../domain/usecases/assign_multiple_tags_to_account_usecase.dart';
import '../../domain/usecases/remove_multiple_tags_from_account_usecase.dart';
import '../../domain/usecases/get_all_tags_for_account_usecase.dart';
import '../../domain/usecases/get_account_custom_fields_usecase.dart';
import '../../domain/usecases/create_account_custom_field_usecase.dart';
import '../../domain/usecases/update_account_custom_field_usecase.dart';
import '../../domain/usecases/delete_account_custom_field_usecase.dart';
import '../../domain/usecases/get_account_emails_usecase.dart';
import '../../domain/usecases/get_account_blocking_states_usecase.dart';
import '../../domain/usecases/get_account_invoice_payments_usecase.dart';
import '../../domain/usecases/get_account_audit_logs_usecase.dart';
import '../../domain/usecases/get_account_payment_methods_usecase.dart';
import '../../domain/usecases/get_account_payments_usecase.dart';
import '../../domain/usecases/create_account_payment_usecase.dart';
import '../bloc/events/account_detail_events.dart';
import '../bloc/states/account_detail_states.dart';
import '../../domain/entities/account_payment.dart';
import '../../../tags/domain/entities/tag.dart';

/// BLoC for handling single account operations
@injectable
class AccountDetailBloc extends Bloc<AccountDetailEvent, AccountDetailState> {
  final GetAccountByIdUseCase _getAccountByIdUseCase;
  final CreateAccountUseCase _createAccountUseCase;
  final UpdateAccountUseCase _updateAccountUseCase;
  final DeleteAccountUseCase _deleteAccountUseCase;
  final GetAccountTimelineUseCase _getAccountTimelineUseCase;
  final GetAccountTagsUseCase _getAccountTagsUseCase;
  final AssignMultipleTagsToAccountUseCase _assignMultipleTagsToAccountUseCase;
  final RemoveMultipleTagsFromAccountUseCase
  _removeMultipleTagsFromAccountUseCase;
  final GetAllTagsForAccountUseCase _getAllTagsForAccountUseCase;
  final GetAccountCustomFieldsUseCase _getAccountCustomFieldsUseCase;
  final CreateAccountCustomFieldUseCase _createAccountCustomFieldUseCase;
  final UpdateAccountCustomFieldUseCase _updateAccountCustomFieldUseCase;
  final DeleteAccountCustomFieldUseCase _deleteAccountCustomFieldUseCase;
  final GetAccountEmailsUseCase _getAccountEmailsUseCase;
  final GetAccountBlockingStatesUseCase _getAccountBlockingStatesUseCase;
  final GetAccountInvoicePaymentsUseCase _getAccountInvoicePaymentsUseCase;
  final GetAccountAuditLogsUseCase _getAccountAuditLogsUseCase;
  final GetAccountPaymentMethodsUseCase _getAccountPaymentMethodsUseCase;
  final GetAccountPaymentsUseCase _getAccountPaymentsUseCase;
  final CreateAccountPaymentUseCase _createAccountPaymentUseCase;
  final AccountsRepository _accountsRepository;
  final Logger _logger = Logger();

  StreamSubscription? _accountStreamSubscription;

  AccountDetailBloc({
    required GetAccountByIdUseCase getAccountByIdUseCase,
    required CreateAccountUseCase createAccountUseCase,
    required UpdateAccountUseCase updateAccountUseCase,
    required DeleteAccountUseCase deleteAccountUseCase,
    required GetAccountTimelineUseCase getAccountTimelineUseCase,
    required GetAccountTagsUseCase getAccountTagsUseCase,
    required AssignMultipleTagsToAccountUseCase
    assignMultipleTagsToAccountUseCase,
    required RemoveMultipleTagsFromAccountUseCase
    removeMultipleTagsFromAccountUseCase,
    required GetAllTagsForAccountUseCase getAllTagsForAccountUseCase,
    required GetAccountCustomFieldsUseCase getAccountCustomFieldsUseCase,
    required CreateAccountCustomFieldUseCase createAccountCustomFieldUseCase,
    required UpdateAccountCustomFieldUseCase updateAccountCustomFieldUseCase,
    required DeleteAccountCustomFieldUseCase deleteAccountCustomFieldUseCase,
    required GetAccountEmailsUseCase getAccountEmailsUseCase,
    required GetAccountBlockingStatesUseCase getAccountBlockingStatesUseCase,
    required GetAccountInvoicePaymentsUseCase getAccountInvoicePaymentsUseCase,
    required GetAccountAuditLogsUseCase getAccountAuditLogsUseCase,
    required GetAccountPaymentMethodsUseCase getAccountPaymentMethodsUseCase,
    required GetAccountPaymentsUseCase getAccountPaymentsUseCase,
    required CreateAccountPaymentUseCase createAccountPaymentUseCase,
    required AccountsRepository accountsRepository,
  }) : _getAccountByIdUseCase = getAccountByIdUseCase,
       _createAccountUseCase = createAccountUseCase,
       _updateAccountUseCase = updateAccountUseCase,
       _deleteAccountUseCase = deleteAccountUseCase,
       _getAccountTimelineUseCase = getAccountTimelineUseCase,
       _getAccountTagsUseCase = getAccountTagsUseCase,
       _assignMultipleTagsToAccountUseCase = assignMultipleTagsToAccountUseCase,
       _removeMultipleTagsFromAccountUseCase =
           removeMultipleTagsFromAccountUseCase,
       _getAllTagsForAccountUseCase = getAllTagsForAccountUseCase,
       _getAccountCustomFieldsUseCase = getAccountCustomFieldsUseCase,
       _createAccountCustomFieldUseCase = createAccountCustomFieldUseCase,
       _updateAccountCustomFieldUseCase = updateAccountCustomFieldUseCase,
       _deleteAccountCustomFieldUseCase = deleteAccountCustomFieldUseCase,
       _getAccountEmailsUseCase = getAccountEmailsUseCase,
       _getAccountBlockingStatesUseCase = getAccountBlockingStatesUseCase,
       _getAccountInvoicePaymentsUseCase = getAccountInvoicePaymentsUseCase,
       _getAccountAuditLogsUseCase = getAccountAuditLogsUseCase,
       _getAccountPaymentMethodsUseCase = getAccountPaymentMethodsUseCase,
       _getAccountPaymentsUseCase = getAccountPaymentsUseCase,
       _createAccountPaymentUseCase = createAccountPaymentUseCase,
       _accountsRepository = accountsRepository,
       super(const AccountDetailInitial()) {
    // Register event handlers
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
    on<RefreshAccountPayments>(_onRefreshAccountPayments);
    on<CreateAccountPayment>(_onCreateAccountPayment);

    // Initialize stream subscriptions for reactive updates
    _initializeStreamSubscriptions();
  }

  /// Initialize stream subscriptions for reactive updates from repository
  void _initializeStreamSubscriptions() {
    // Listen to individual account updates from repository background sync
    _accountStreamSubscription = _accountsRepository.accountStream.listen(
      (response) {
        // Only handle success states with data - ignore loading states
        if (response.isSuccess && response.data != null) {
          final currentState = state;

          // Check if we're currently viewing account details for this specific account
          final isViewingAccountDetails =
              (currentState is AccountDetailsLoaded &&
                  currentState.account.accountId == response.data!.accountId) ||
              (currentState is AccountDetailsLoading &&
                  currentState.accountId == response.data!.accountId);

          if (isViewingAccountDetails) {
            // If we're loading account details, emit loaded state immediately
            if (currentState is AccountDetailsLoading) {
              emit(AccountDetailsLoaded(response.data!));
              _logger.d(
                'UI updated with fresh account from background sync during loading: ${response.data!.accountId}',
              );
            }
            // If we already have account details loaded, only update if data is different
            else if (currentState is AccountDetailsLoaded) {
              if (currentState.account != response.data!) {
                emit(AccountDetailsLoaded(response.data!));
                _logger.d(
                  'UI updated with fresh account from background sync: ${response.data!.accountId}',
                );
              } else {
                _logger.d(
                  'Account data unchanged, skipping UI update: ${response.data!.accountId}',
                );
              }
            }
          } else {
            // Don't emit AccountDetailsLoaded if we're not viewing account details
            _logger.d(
              'Skipping account stream update - not viewing account details for ${response.data!.accountId}',
            );
          }
        } else if (response.hasError) {
          _logger.e('Error in account stream: ${response.errorMessage}');
        }
      },
      onError: (error) {
        _logger.e('Error in account stream subscription: $error');
      },
    );
  }

  Future<void> _onLoadAccountDetails(
    LoadAccountDetails event,
    Emitter<AccountDetailState> emit,
  ) async {
    try {
      // Check if we already have the account details loaded for this account
      final currentState = state;
      if (currentState is AccountDetailsLoaded &&
          currentState.account.accountId == event.accountId) {
        // We already have the data, don't show loading
        _logger.d('Account details already loaded for: ${event.accountId}');
        return;
      }

      // Check if we're already loading this account to prevent duplicate calls
      if (currentState is AccountDetailsLoading &&
          currentState.accountId == event.accountId) {
        _logger.d('Account details already loading for: ${event.accountId}');
        return;
      }

      // Emit loading state first
      emit(AccountDetailsLoading(event.accountId));

      // Get account data first to check if we have cached data
      final account = await _getAccountByIdUseCase(event.accountId);

      // If we got data immediately (from cache), emit loaded state directly
      emit(AccountDetailsLoaded(account));
    } catch (e) {
      _logger.e('Error loading account details: $e');
      emit(AccountDetailsFailure(e.toString(), event.accountId));
    }
  }

  Future<void> _onCreateAccount(
    CreateAccount event,
    Emitter<AccountDetailState> emit,
  ) async {
    try {
      emit(const AccountCreating());

      final newAccount = await _createAccountUseCase(event.account);

      emit(AccountCreated(newAccount));
    } catch (e) {
      _logger.e('Error creating account: $e');
      emit(AccountCreationFailure(e.toString()));
    }
  }

  Future<void> _onUpdateAccount(
    UpdateAccount event,
    Emitter<AccountDetailState> emit,
  ) async {
    try {
      emit(const AccountUpdating());

      final updatedAccount = await _updateAccountUseCase(event.account);

      emit(AccountUpdated(updatedAccount));
    } catch (e) {
      _logger.e('Error updating account: $e');
      emit(AccountUpdateFailure(e.toString()));
    }
  }

  Future<void> _onDeleteAccount(
    DeleteAccount event,
    Emitter<AccountDetailState> emit,
  ) async {
    try {
      emit(AccountDeleting(event.accountId));

      await _deleteAccountUseCase(event.accountId);

      emit(AccountDeleted(event.accountId));
    } catch (e) {
      _logger.e('Error deleting account: $e');
      emit(AccountDeleteFailure(e.toString(), event.accountId));
    }
  }

  Future<void> _onLoadAccountTimeline(
    LoadAccountTimeline event,
    Emitter<AccountDetailState> emit,
  ) async {
    try {
      emit(AccountTimelineLoading(event.accountId));
      final timeline = await _getAccountTimelineUseCase(event.accountId);
      emit(AccountTimelineLoaded(event.accountId, [timeline]));
    } catch (e) {
      _logger.e('Error loading account timeline: $e');
      emit(AccountTimelineFailure(e.toString(), event.accountId));
    }
  }

  Future<void> _onRefreshAccountTimeline(
    RefreshAccountTimeline event,
    Emitter<AccountDetailState> emit,
  ) async {
    try {
      emit(AccountTimelineLoading(event.accountId));
      final timeline = await _getAccountTimelineUseCase(event.accountId);
      emit(AccountTimelineLoaded(event.accountId, [timeline]));
    } catch (e) {
      _logger.e('Error refreshing account timeline: $e');
      emit(AccountTimelineFailure(e.toString(), event.accountId));
    }
  }

  Future<void> _onLoadAccountTags(
    LoadAccountTags event,
    Emitter<AccountDetailState> emit,
  ) async {
    try {
      emit(AccountTagsLoading(event.accountId));
      final tagAssignments = await _getAccountTagsUseCase(event.accountId);
      final tags = tagAssignments
          .map(
            (assignment) => Tag(
              tagId: assignment.tagId,
              objectType: 'ACCOUNT',
              objectId: assignment.accountId,
              tagDefinitionId: assignment.tagId,
              tagDefinitionName: assignment.tagName,
              auditLogs: [],
            ),
          )
          .toList();
      emit(AccountTagsLoaded(event.accountId, tags));
    } catch (e) {
      _logger.e('Error loading account tags: $e');
      emit(AccountTagsFailure(e.toString(), event.accountId));
    }
  }

  Future<void> _onRefreshAccountTags(
    RefreshAccountTags event,
    Emitter<AccountDetailState> emit,
  ) async {
    try {
      emit(AccountTagsLoading(event.accountId));
      final tagAssignments = await _getAccountTagsUseCase(event.accountId);
      final tags = tagAssignments
          .map(
            (assignment) => Tag(
              tagId: assignment.tagId,
              objectType: 'ACCOUNT',
              objectId: assignment.accountId,
              tagDefinitionId: assignment.tagId,
              tagDefinitionName: assignment.tagName,
              auditLogs: [],
            ),
          )
          .toList();
      emit(AccountTagsLoaded(event.accountId, tags));
    } catch (e) {
      _logger.e('Error refreshing account tags: $e');
      emit(AccountTagsFailure(e.toString(), event.accountId));
    }
  }

  Future<void> _onAssignTagToAccount(
    AssignTagToAccount event,
    Emitter<AccountDetailState> emit,
  ) async {
    // Reuse multiple tags logic for single tag
    await _onAssignMultipleTagsToAccount(
      AssignMultipleTagsToAccount(event.accountId, [event.tagId]),
      emit,
    );
  }

  Future<void> _onRemoveTagFromAccount(
    RemoveTagFromAccount event,
    Emitter<AccountDetailState> emit,
  ) async {
    // Reuse multiple tags logic for single tag
    await _onRemoveMultipleTagsFromAccount(
      RemoveMultipleTagsFromAccount(event.accountId, [event.tagId]),
      emit,
    );
  }

  Future<void> _onAssignMultipleTagsToAccount(
    AssignMultipleTagsToAccount event,
    Emitter<AccountDetailState> emit,
  ) async {
    try {
      await _assignMultipleTagsToAccountUseCase(event.accountId, event.tagIds);
      for (final tagId in event.tagIds) {
        emit(TagAssigned(event.accountId, tagId));
      }
    } catch (e) {
      _logger.e('Error assigning multiple tags to account: $e');
      emit(AccountTagsFailure(e.toString(), event.accountId));
    }
  }

  Future<void> _onRemoveMultipleTagsFromAccount(
    RemoveMultipleTagsFromAccount event,
    Emitter<AccountDetailState> emit,
  ) async {
    try {
      await _removeMultipleTagsFromAccountUseCase(
        event.accountId,
        event.tagIds,
      );
      for (final tagId in event.tagIds) {
        emit(TagRemoved(event.accountId, tagId));
      }
    } catch (e) {
      _logger.e('Error removing multiple tags from account: $e');
      emit(AccountTagsFailure(e.toString(), event.accountId));
    }
  }

  Future<void> _onLoadAllTagsForAccount(
    LoadAllTagsForAccount event,
    Emitter<AccountDetailState> emit,
  ) async {
    try {
      emit(AccountTagsLoading(event.accountId));
      final accountTags = await _getAllTagsForAccountUseCase(event.accountId);
      final tags = accountTags
          .map(
            (accountTag) => Tag(
              tagId: accountTag.id,
              objectType: 'ACCOUNT',
              objectId: event.accountId,
              tagDefinitionId: accountTag.id,
              tagDefinitionName: accountTag.name,
              auditLogs: [],
            ),
          )
          .toList();
      emit(AccountTagsLoaded(event.accountId, tags));
    } catch (e) {
      _logger.e('Error loading all tags for account: $e');
      emit(AccountTagsFailure(e.toString(), event.accountId));
    }
  }

  Future<void> _onLoadAccountCustomFields(
    LoadAccountCustomFields event,
    Emitter<AccountDetailState> emit,
  ) async {
    try {
      emit(AccountCustomFieldsLoading(event.accountId));
      final customFields = await _getAccountCustomFieldsUseCase(
        event.accountId,
      );
      emit(AccountCustomFieldsLoaded(event.accountId, customFields));
    } catch (e) {
      _logger.e('Error loading account custom fields: $e');
      emit(AccountCustomFieldsFailure(e.toString(), event.accountId));
    }
  }

  Future<void> _onCreateAccountCustomField(
    CreateAccountCustomField event,
    Emitter<AccountDetailState> emit,
  ) async {
    try {
      await _createAccountCustomFieldUseCase(
        event.accountId,
        event.customField['name'] ?? '',
        event.customField['value'] ?? '',
      );
      // Reload custom fields after creation
      add(LoadAccountCustomFields(event.accountId));
    } catch (e) {
      _logger.e('Error creating account custom field: $e');
      emit(AccountCustomFieldsFailure(e.toString(), event.accountId));
    }
  }

  Future<void> _onUpdateAccountCustomField(
    UpdateAccountCustomField event,
    Emitter<AccountDetailState> emit,
  ) async {
    try {
      await _updateAccountCustomFieldUseCase(
        event.accountId,
        event.customFieldId,
        event.customField['name'] ?? '',
        event.customField['value'] ?? '',
      );
      // Reload custom fields after update
      add(LoadAccountCustomFields(event.accountId));
    } catch (e) {
      _logger.e('Error updating account custom field: $e');
      emit(AccountCustomFieldsFailure(e.toString(), event.accountId));
    }
  }

  Future<void> _onDeleteAccountCustomField(
    DeleteAccountCustomField event,
    Emitter<AccountDetailState> emit,
  ) async {
    try {
      await _deleteAccountCustomFieldUseCase(
        event.accountId,
        event.customFieldId,
      );
      // Reload custom fields after deletion
      add(LoadAccountCustomFields(event.accountId));
    } catch (e) {
      _logger.e('Error deleting account custom field: $e');
      emit(AccountCustomFieldsFailure(e.toString(), event.accountId));
    }
  }

  Future<void> _onLoadAccountEmails(
    LoadAccountEmails event,
    Emitter<AccountDetailState> emit,
  ) async {
    try {
      emit(AccountEmailsLoading(event.accountId));
      final accountEmails = await _getAccountEmailsUseCase(event.accountId);
      final emails = accountEmails.map((email) => email.email).toList();
      emit(AccountEmailsLoaded(event.accountId, emails));
    } catch (e) {
      _logger.e('Error loading account emails: $e');
      emit(AccountEmailsFailure(e.toString(), event.accountId));
    }
  }

  Future<void> _onLoadAccountBlockingStates(
    LoadAccountBlockingStates event,
    Emitter<AccountDetailState> emit,
  ) async {
    try {
      emit(AccountBlockingStatesLoading(event.accountId));
      final blockingStates = await _getAccountBlockingStatesUseCase(
        event.accountId,
      );
      emit(AccountBlockingStatesLoaded(event.accountId, blockingStates));
    } catch (e) {
      _logger.e('Error loading account blocking states: $e');
      emit(AccountBlockingStatesFailure(e.toString(), event.accountId));
    }
  }

  Future<void> _onLoadAccountInvoicePayments(
    LoadAccountInvoicePayments event,
    Emitter<AccountDetailState> emit,
  ) async {
    try {
      emit(AccountInvoicePaymentsLoading(event.accountId));
      final invoicePayments = await _getAccountInvoicePaymentsUseCase(
        event.accountId,
      );
      final payments = invoicePayments
          .map(
            (invoicePayment) => AccountPayment(
              id: invoicePayment.id,
              accountId: invoicePayment.accountId,
              paymentType: 'INVOICE_PAYMENT',
              paymentStatus: invoicePayment.status,
              amount: invoicePayment.amount,
              currency: invoicePayment.currency,
              paymentMethodId: invoicePayment.paymentMethod,
              transactionId: invoicePayment.transactionId,
              notes: invoicePayment.notes,
              paymentDate: invoicePayment.paymentDate,
              processedDate: invoicePayment.processedDate,
              createdAt: invoicePayment.paymentDate,
              metadata: invoicePayment.metadata,
              isRefunded: false,
            ),
          )
          .toList();
      emit(AccountInvoicePaymentsLoaded(event.accountId, payments));
    } catch (e) {
      _logger.e('Error loading account invoice payments: $e');
      emit(AccountInvoicePaymentsFailure(e.toString(), event.accountId));
    }
  }

  Future<void> _onLoadAccountAuditLogs(
    LoadAccountAuditLogs event,
    Emitter<AccountDetailState> emit,
  ) async {
    try {
      emit(AccountAuditLogsLoading(event.accountId));
      final auditLogs = await _getAccountAuditLogsUseCase(event.accountId);
      emit(AccountAuditLogsLoaded(event.accountId, auditLogs));
    } catch (e) {
      _logger.e('Error loading account audit logs: $e');
      emit(AccountAuditLogsFailure(e.toString(), event.accountId));
    }
  }

  Future<void> _onLoadAccountPaymentMethods(
    LoadAccountPaymentMethods event,
    Emitter<AccountDetailState> emit,
  ) async {
    try {
      emit(AccountPaymentMethodsLoading(event.accountId));
      final paymentMethods = await _getAccountPaymentMethodsUseCase(
        event.accountId,
      );
      emit(AccountPaymentMethodsLoaded(event.accountId, paymentMethods));
    } catch (e) {
      _logger.e('Error loading account payment methods: $e');
      emit(AccountPaymentMethodsFailure(e.toString(), event.accountId));
    }
  }

  Future<void> _onLoadAccountPayments(
    LoadAccountPayments event,
    Emitter<AccountDetailState> emit,
  ) async {
    print(
      '🔍 AccountDetailBloc: Received LoadAccountPayments for accountId: ${event.accountId}',
    );
    try {
      print('🔍 AccountDetailBloc: Emitting AccountPaymentsLoading');
      emit(AccountPaymentsLoading(event.accountId));
      print('🔍 AccountDetailBloc: Calling _getAccountPaymentsUseCase');
      final payments = await _getAccountPaymentsUseCase(event.accountId);
      print(
        '🔍 AccountDetailBloc: Use case returned ${payments.length} payments',
      );
      print('🔍 AccountDetailBloc: Emitting AccountPaymentsLoaded');
      emit(AccountPaymentsLoaded(event.accountId, payments));
    } catch (e) {
      print('🔍 AccountDetailBloc: Error loading account payments: $e');
      _logger.e('Error loading account payments: $e');
      emit(AccountPaymentsFailure(e.toString(), event.accountId));
    }
  }

  Future<void> _onRefreshAccountPayments(
    RefreshAccountPayments event,
    Emitter<AccountDetailState> emit,
  ) async {
    try {
      emit(AccountPaymentsLoading(event.accountId));
      final payments = await _getAccountPaymentsUseCase(event.accountId);
      emit(AccountPaymentsLoaded(event.accountId, payments));
    } catch (e) {
      _logger.e('Error refreshing account payments: $e');
      emit(AccountPaymentsFailure(e.toString(), event.accountId));
    }
  }

  Future<void> _onCreateAccountPayment(
    CreateAccountPayment event,
    Emitter<AccountDetailState> emit,
  ) async {
    try {
      await _createAccountPaymentUseCase(
        accountId: event.accountId,
        paymentMethodId: event.paymentData['paymentMethodId'] ?? '',
        transactionType: event.paymentData['transactionType'] ?? 'PAYMENT',
        amount: event.paymentData['amount']?.toDouble() ?? 0.0,
        currency: event.paymentData['currency'] ?? 'USD',
        effectiveDate: event.paymentData['effectiveDate'] ?? DateTime.now(),
        description: event.paymentData['description'],
        properties: event.paymentData['properties'],
      );
      // Reload payments after creation
      add(LoadAccountPayments(event.accountId));
    } catch (e) {
      _logger.e('Error creating account payment: $e');
      emit(AccountPaymentsFailure(e.toString(), event.accountId));
    }
  }

  @override
  Future<void> close() {
    _accountStreamSubscription?.cancel();
    return super.close();
  }
}
