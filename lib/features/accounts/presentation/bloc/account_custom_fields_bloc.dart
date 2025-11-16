import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import '../../../../core/bloc/bloc_error_handler_mixin.dart';
import '../../domain/entities/account_custom_field.dart';
import '../../domain/repositories/account_custom_fields_repository.dart';
import '../../domain/usecases/get_account_custom_fields_usecase.dart';
import '../../domain/usecases/create_account_custom_field_usecase.dart';
import '../../domain/usecases/create_multiple_account_custom_fields_usecase.dart';
import '../../domain/usecases/update_account_custom_field_usecase.dart';
import '../../domain/usecases/update_multiple_account_custom_fields_usecase.dart';
import '../../domain/usecases/delete_account_custom_field_usecase.dart';
import '../../domain/usecases/delete_multiple_account_custom_fields_usecase.dart';
import 'events/account_custom_fields_events.dart';
import 'states/account_custom_fields_states.dart';

/// BLoC for handling account custom fields operations
@injectable
class AccountCustomFieldsBloc
    extends Bloc<AccountCustomFieldsEvent, AccountCustomFieldsState>
    with BlocErrorHandlerMixin {
  final GetAccountCustomFieldsUseCase _getAccountCustomFieldsUseCase;
  final CreateAccountCustomFieldUseCase _createAccountCustomFieldUseCase;
  final CreateMultipleAccountCustomFieldsUseCase
  _createMultipleAccountCustomFieldsUseCase;
  final UpdateAccountCustomFieldUseCase _updateAccountCustomFieldUseCase;
  final UpdateMultipleAccountCustomFieldsUseCase
  _updateMultipleAccountCustomFieldsUseCase;
  final DeleteAccountCustomFieldUseCase _deleteAccountCustomFieldUseCase;
  final DeleteMultipleAccountCustomFieldsUseCase
  _deleteMultipleAccountCustomFieldsUseCase;
  final AccountCustomFieldsRepository _accountCustomFieldsRepository;
  final Logger _logger = Logger();

  StreamSubscription<List<AccountCustomField>>? _customFieldsSubscription;
  String? _currentAccountId;

  AccountCustomFieldsBloc({
    required GetAccountCustomFieldsUseCase getAccountCustomFieldsUseCase,
    required CreateAccountCustomFieldUseCase createAccountCustomFieldUseCase,
    required CreateMultipleAccountCustomFieldsUseCase
    createMultipleAccountCustomFieldsUseCase,
    required UpdateAccountCustomFieldUseCase updateAccountCustomFieldUseCase,
    required UpdateMultipleAccountCustomFieldsUseCase
    updateMultipleAccountCustomFieldsUseCase,
    required DeleteAccountCustomFieldUseCase deleteAccountCustomFieldUseCase,
    required DeleteMultipleAccountCustomFieldsUseCase
    deleteMultipleAccountCustomFieldsUseCase,
    required AccountCustomFieldsRepository accountCustomFieldsRepository,
  }) : _getAccountCustomFieldsUseCase = getAccountCustomFieldsUseCase,
       _createAccountCustomFieldUseCase = createAccountCustomFieldUseCase,
       _createMultipleAccountCustomFieldsUseCase =
           createMultipleAccountCustomFieldsUseCase,
       _updateAccountCustomFieldUseCase = updateAccountCustomFieldUseCase,
       _updateMultipleAccountCustomFieldsUseCase =
           updateMultipleAccountCustomFieldsUseCase,
       _deleteAccountCustomFieldUseCase = deleteAccountCustomFieldUseCase,
       _deleteMultipleAccountCustomFieldsUseCase =
           deleteMultipleAccountCustomFieldsUseCase,
       _accountCustomFieldsRepository = accountCustomFieldsRepository,
       super(const AccountCustomFieldsInitial('')) {
    // Register event handlers
    on<LoadAccountCustomFields>(_onLoadAccountCustomFields);
    on<RefreshAccountCustomFields>(_onRefreshAccountCustomFields);
    on<CreateAccountCustomField>(_onCreateAccountCustomField);
    on<CreateMultipleAccountCustomFields>(_onCreateMultipleAccountCustomFields);
    on<UpdateAccountCustomField>(_onUpdateAccountCustomField);
    on<UpdateMultipleAccountCustomFields>(_onUpdateMultipleAccountCustomFields);
    on<DeleteAccountCustomField>(_onDeleteAccountCustomField);
    on<DeleteMultipleAccountCustomFields>(_onDeleteMultipleAccountCustomFields);
    on<SearchCustomFieldsByName>(_onSearchCustomFieldsByName);
    on<SearchCustomFieldsByValue>(_onSearchCustomFieldsByValue);
    on<SyncAccountCustomFields>(_onSyncAccountCustomFields);
    on<ClearAccountCustomFields>(_onClearAccountCustomFields);
  }

  /// Initialize stream subscriptions for reactive updates from repository
  void _initializeStreamSubscriptions() {
    _logger.d('🔍 AccountCustomFieldsBloc: Initializing stream subscriptions');
    _logger.d(
      '🔍 AccountCustomFieldsBloc: Repository stream: ${_accountCustomFieldsRepository.customFieldsStream}',
    );
    // Listen to custom fields updates from repository background sync
    _customFieldsSubscription = _accountCustomFieldsRepository.customFieldsStream.listen(
      (updatedCustomFields) {
        _logger.d(
          '🔍 AccountCustomFieldsBloc: Stream update received with ${updatedCustomFields.length} custom fields, currentAccountId: $_currentAccountId',
        );

        // Only process updates if we have a current account ID
        if (_currentAccountId != null) {
          // Filter custom fields for the current account
          final currentAccountCustomFields = updatedCustomFields
              .where((field) => field.accountId == _currentAccountId)
              .toList();

          _logger.d(
            '🔍 AccountCustomFieldsBloc: Filtered ${currentAccountCustomFields.length} custom fields for current account',
          );

          // Update custom fields list with fresh data directly without triggering new events
          final currentState = state;
          _logger.d(
            '🔍 AccountCustomFieldsBloc: Current state: ${currentState.runtimeType}',
          );

          // Update if we're in a loaded state or loading state
          if (currentState is AccountCustomFieldsLoaded) {
            emit(
              AccountCustomFieldsLoaded(
                accountId: _currentAccountId!,
                customFields: currentAccountCustomFields,
              ),
            );
            _logger.d(
              '🔍 AccountCustomFieldsBloc: Account custom fields updated from background sync: ${currentAccountCustomFields.length} custom fields',
            );
          } else if (currentState is AccountCustomFieldsLoading) {
            // Handle the case when we're still loading and background sync completes
            emit(
              AccountCustomFieldsLoaded(
                accountId: _currentAccountId!,
                customFields: currentAccountCustomFields,
              ),
            );
            _logger.d(
              '🔍 AccountCustomFieldsBloc: Account custom fields loaded from background sync: ${currentAccountCustomFields.length} custom fields',
            );
          } else {
            _logger.d(
              '🔍 AccountCustomFieldsBloc: Ignoring stream update - current state is not loaded or loading: ${currentState.runtimeType}',
            );
          }
        } else {
          _logger.d(
            '🔍 AccountCustomFieldsBloc: Ignoring stream update - no current account ID set',
          );
        }
      },
      onError: (error) {
        _logger.e('🔍 AccountCustomFieldsBloc: Stream error: $error');
        if (_currentAccountId != null) {
          emit(
            AccountCustomFieldsFailure(
              accountId: _currentAccountId!,
              message: 'Stream error: $error',
            ),
          );
        }
      },
    );
    _logger.d(
      '🔍 AccountCustomFieldsBloc: Stream subscription created successfully',
    );
  }

  Future<void> _onLoadAccountCustomFields(
    LoadAccountCustomFields event,
    Emitter<AccountCustomFieldsState> emit,
  ) async {
    _logger.d(
      '🔍 AccountCustomFieldsBloc: LoadAccountCustomFields called for accountId: ${event.accountId}',
    );

    _currentAccountId = event.accountId;

    // Set up stream subscription if not already set up
    if (_customFieldsSubscription == null) {
      _initializeStreamSubscriptions();
    }

    emit(AccountCustomFieldsLoading(event.accountId));

    try {
      // LOCAL-FIRST: This will return local data immediately
      final customFields = await _getAccountCustomFieldsUseCase(
        event.accountId,
      );
      _logger.d(
        '🔍 AccountCustomFieldsBloc: LoadAccountCustomFields succeeded with ${customFields.length} custom fields from local cache',
      );
      emit(
        AccountCustomFieldsLoaded(
          accountId: event.accountId,
          customFields: customFields,
        ),
      );

      // The repository will handle background sync and emit updates via stream
      // The UI will reactively update when new data arrives
    } catch (e) {
      _logger.e(
        '🔍 AccountCustomFieldsBloc: LoadAccountCustomFields exception: $e',
      );
      emit(
        AccountCustomFieldsFailure(
          accountId: event.accountId,
          message: 'An unexpected error occurred: $e',
        ),
      );
    }
  }

  Future<void> _onRefreshAccountCustomFields(
    RefreshAccountCustomFields event,
    Emitter<AccountCustomFieldsState> emit,
  ) async {
    _logger.d(
      '🔍 AccountCustomFieldsBloc: RefreshAccountCustomFields called for accountId: ${event.accountId}',
    );

    _currentAccountId = event.accountId;
    emit(AccountCustomFieldsLoading(event.accountId));

    try {
      // LOCAL-FIRST: This will return local data immediately
      final customFields = await _getAccountCustomFieldsUseCase(
        event.accountId,
      );
      _logger.d(
        '🔍 AccountCustomFieldsBloc: RefreshAccountCustomFields succeeded with ${customFields.length} custom fields from local cache',
      );
      emit(
        AccountCustomFieldsLoaded(
          accountId: event.accountId,
          customFields: customFields,
        ),
      );

      // The repository will handle background sync and emit updates via stream
      // The UI will reactively update when new data arrives
    } catch (e) {
      _logger.e(
        '🔍 AccountCustomFieldsBloc: RefreshAccountCustomFields exception: $e',
      );
      emit(
        AccountCustomFieldsFailure(
          accountId: event.accountId,
          message: 'An unexpected error occurred: $e',
        ),
      );
    }
  }

  Future<void> _onCreateAccountCustomField(
    CreateAccountCustomField event,
    Emitter<AccountCustomFieldsState> emit,
  ) async {
    _logger.d(
      '🔍 AccountCustomFieldsBloc: CreateAccountCustomField called for accountId: ${event.accountId}',
    );

    emit(AccountCustomFieldCreating(event.accountId));

    try {
      final customField = await _createAccountCustomFieldUseCase(
        event.accountId,
        event.name,
        event.value,
      );
      _logger.i(
        '🔍 AccountCustomFieldsBloc: CreateAccountCustomField succeeded with customFieldId: ${customField.customFieldId}',
      );
      emit(
        AccountCustomFieldCreated(
          accountId: event.accountId,
          customField: customField,
        ),
      );

      // Reload custom fields to get updated list
      add(LoadAccountCustomFields(event.accountId));
    } catch (e) {
      _logger.e(
        '🔍 AccountCustomFieldsBloc: CreateAccountCustomField exception: $e',
      );
      emit(
        AccountCustomFieldCreationFailure(
          accountId: event.accountId,
          message: 'Failed to create custom field: $e',
        ),
      );
    }
  }

  Future<void> _onCreateMultipleAccountCustomFields(
    CreateMultipleAccountCustomFields event,
    Emitter<AccountCustomFieldsState> emit,
  ) async {
    _logger.d(
      '🔍 AccountCustomFieldsBloc: CreateMultipleAccountCustomFields called for accountId: ${event.accountId}',
    );

    emit(AccountCustomFieldCreating(event.accountId));

    try {
      final customFields = await _createMultipleAccountCustomFieldsUseCase(
        event.accountId,
        event.customFields,
      );
      _logger.i(
        '🔍 AccountCustomFieldsBloc: CreateMultipleAccountCustomFields succeeded with ${customFields.length} custom fields',
      );
      emit(
        MultipleAccountCustomFieldsCreated(
          accountId: event.accountId,
          customFields: customFields,
        ),
      );

      // Reload custom fields to get updated list
      add(LoadAccountCustomFields(event.accountId));
    } catch (e) {
      _logger.e(
        '🔍 AccountCustomFieldsBloc: CreateMultipleAccountCustomFields exception: $e',
      );
      emit(
        MultipleAccountCustomFieldsCreationFailure(
          accountId: event.accountId,
          message: 'Failed to create custom fields: $e',
        ),
      );
    }
  }

  Future<void> _onUpdateAccountCustomField(
    UpdateAccountCustomField event,
    Emitter<AccountCustomFieldsState> emit,
  ) async {
    _logger.d(
      '🔍 AccountCustomFieldsBloc: UpdateAccountCustomField called for accountId: ${event.accountId}',
    );

    emit(AccountCustomFieldUpdating(event.accountId));

    try {
      final customField = await _updateAccountCustomFieldUseCase(
        event.accountId,
        event.customFieldId,
        event.name,
        event.value,
      );
      _logger.i(
        '🔍 AccountCustomFieldsBloc: UpdateAccountCustomField succeeded with customFieldId: ${customField.customFieldId}',
      );
      emit(
        AccountCustomFieldUpdated(
          accountId: event.accountId,
          customField: customField,
        ),
      );

      // Reload custom fields to get updated list
      add(LoadAccountCustomFields(event.accountId));
    } catch (e) {
      _logger.e(
        '🔍 AccountCustomFieldsBloc: UpdateAccountCustomField exception: $e',
      );
      emit(
        AccountCustomFieldUpdateFailure(
          accountId: event.accountId,
          message: 'Failed to update custom field: $e',
        ),
      );
    }
  }

  Future<void> _onUpdateMultipleAccountCustomFields(
    UpdateMultipleAccountCustomFields event,
    Emitter<AccountCustomFieldsState> emit,
  ) async {
    _logger.d(
      '🔍 AccountCustomFieldsBloc: UpdateMultipleAccountCustomFields called for accountId: ${event.accountId}',
    );

    emit(AccountCustomFieldUpdating(event.accountId));

    try {
      final customFields = await _updateMultipleAccountCustomFieldsUseCase(
        event.accountId,
        event.customFields,
      );
      _logger.i(
        '🔍 AccountCustomFieldsBloc: UpdateMultipleAccountCustomFields succeeded with ${customFields.length} custom fields',
      );
      emit(
        MultipleAccountCustomFieldsUpdated(
          accountId: event.accountId,
          customFields: customFields,
        ),
      );

      // Reload custom fields to get updated list
      add(LoadAccountCustomFields(event.accountId));
    } catch (e) {
      _logger.e(
        '🔍 AccountCustomFieldsBloc: UpdateMultipleAccountCustomFields exception: $e',
      );
      emit(
        MultipleAccountCustomFieldsUpdateFailure(
          accountId: event.accountId,
          message: 'Failed to update custom fields: $e',
        ),
      );
    }
  }

  Future<void> _onDeleteAccountCustomField(
    DeleteAccountCustomField event,
    Emitter<AccountCustomFieldsState> emit,
  ) async {
    _logger.d(
      '🔍 AccountCustomFieldsBloc: DeleteAccountCustomField called for accountId: ${event.accountId}',
    );

    emit(AccountCustomFieldDeleting(event.accountId));

    try {
      await _deleteAccountCustomFieldUseCase(
        event.accountId,
        event.customFieldId,
      );
      _logger.i(
        '🔍 AccountCustomFieldsBloc: DeleteAccountCustomField succeeded for customFieldId: ${event.customFieldId}',
      );
      emit(
        AccountCustomFieldDeleted(
          accountId: event.accountId,
          customFieldId: event.customFieldId,
        ),
      );

      // Reload custom fields to get updated list
      add(LoadAccountCustomFields(event.accountId));
    } catch (e) {
      _logger.e(
        '🔍 AccountCustomFieldsBloc: DeleteAccountCustomField exception: $e',
      );
      emit(
        AccountCustomFieldDeletionFailure(
          accountId: event.accountId,
          message: 'Failed to delete custom field: $e',
        ),
      );
    }
  }

  Future<void> _onDeleteMultipleAccountCustomFields(
    DeleteMultipleAccountCustomFields event,
    Emitter<AccountCustomFieldsState> emit,
  ) async {
    _logger.d(
      '🔍 AccountCustomFieldsBloc: DeleteMultipleAccountCustomFields called for accountId: ${event.accountId}',
    );

    emit(AccountCustomFieldDeleting(event.accountId));

    try {
      await _deleteMultipleAccountCustomFieldsUseCase(
        event.accountId,
        event.customFieldIds,
      );
      _logger.i(
        '🔍 AccountCustomFieldsBloc: DeleteMultipleAccountCustomFields succeeded for ${event.customFieldIds.length} custom fields',
      );
      emit(
        MultipleAccountCustomFieldsDeleted(
          accountId: event.accountId,
          customFieldIds: event.customFieldIds,
        ),
      );

      // Reload custom fields to get updated list
      add(LoadAccountCustomFields(event.accountId));
    } catch (e) {
      _logger.e(
        '🔍 AccountCustomFieldsBloc: DeleteMultipleAccountCustomFields exception: $e',
      );
      emit(
        MultipleAccountCustomFieldsDeletionFailure(
          accountId: event.accountId,
          message: 'Failed to delete custom fields: $e',
        ),
      );
    }
  }

  Future<void> _onSearchCustomFieldsByName(
    SearchCustomFieldsByName event,
    Emitter<AccountCustomFieldsState> emit,
  ) async {
    _logger.d(
      '🔍 AccountCustomFieldsBloc: SearchCustomFieldsByName called for accountId: ${event.accountId}',
    );

    emit(AccountCustomFieldsSearching(event.accountId));

    try {
      final customFields = await _accountCustomFieldsRepository
          .getCustomFieldsByName(event.accountId, event.name);
      _logger.d(
        '🔍 AccountCustomFieldsBloc: SearchCustomFieldsByName succeeded with ${customFields.length} custom fields',
      );
      emit(
        AccountCustomFieldsSearchResults(
          accountId: event.accountId,
          customFields: customFields,
          searchQuery: event.name,
        ),
      );
    } catch (e) {
      _logger.e(
        '🔍 AccountCustomFieldsBloc: SearchCustomFieldsByName exception: $e',
      );
      emit(
        AccountCustomFieldsSearchFailure(
          accountId: event.accountId,
          message: 'Failed to search custom fields: $e',
        ),
      );
    }
  }

  Future<void> _onSearchCustomFieldsByValue(
    SearchCustomFieldsByValue event,
    Emitter<AccountCustomFieldsState> emit,
  ) async {
    _logger.d(
      '🔍 AccountCustomFieldsBloc: SearchCustomFieldsByValue called for accountId: ${event.accountId}',
    );

    emit(AccountCustomFieldsSearching(event.accountId));

    try {
      final customFields = await _accountCustomFieldsRepository
          .getCustomFieldsByValue(event.accountId, event.value);
      _logger.d(
        '🔍 AccountCustomFieldsBloc: SearchCustomFieldsByValue succeeded with ${customFields.length} custom fields',
      );
      emit(
        AccountCustomFieldsSearchResults(
          accountId: event.accountId,
          customFields: customFields,
          searchQuery: event.value,
        ),
      );
    } catch (e) {
      _logger.e(
        '🔍 AccountCustomFieldsBloc: SearchCustomFieldsByValue exception: $e',
      );
      emit(
        AccountCustomFieldsSearchFailure(
          accountId: event.accountId,
          message: 'Failed to search custom fields: $e',
        ),
      );
    }
  }

  Future<void> _onSyncAccountCustomFields(
    SyncAccountCustomFields event,
    Emitter<AccountCustomFieldsState> emit,
  ) async {
    _logger.d(
      '🔍 AccountCustomFieldsBloc: SyncAccountCustomFields called for accountId: ${event.accountId}',
    );

    emit(AccountCustomFieldsSyncing(event.accountId));

    try {
      // Trigger refresh which will handle background sync
      add(RefreshAccountCustomFields(event.accountId));
    } catch (e) {
      _logger.e(
        '🔍 AccountCustomFieldsBloc: SyncAccountCustomFields exception: $e',
      );
      emit(
        AccountCustomFieldsSyncFailure(
          accountId: event.accountId,
          message: 'Failed to sync custom fields: $e',
        ),
      );
    }
  }

  void _onClearAccountCustomFields(
    ClearAccountCustomFields event,
    Emitter<AccountCustomFieldsState> emit,
  ) {
    _logger.d(
      '🔍 AccountCustomFieldsBloc: ClearAccountCustomFields called for accountId: ${event.accountId}',
    );
    emit(AccountCustomFieldsInitial(event.accountId));
  }

  @override
  Future<void> close() async {
    await _customFieldsSubscription?.cancel();
    return super.close();
  }
}
