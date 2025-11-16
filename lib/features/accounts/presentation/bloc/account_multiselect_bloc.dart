import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import '../../../../core/bloc/bloc_error_handler_mixin.dart';
import '../../domain/entities/account.dart';
import '../../domain/usecases/delete_account_usecase.dart';
import '../bloc/events/account_multiselect_events.dart';
import '../bloc/states/account_multiselect_states.dart';

/// BLoC for handling multi-select operations
@injectable
class AccountMultiSelectBloc
    extends Bloc<MultiSelectEvent, AccountMultiSelectState>
    with BlocErrorHandlerMixin {
  final DeleteAccountUseCase _deleteAccountUseCase;
  final Logger _logger = Logger();

  final List<Account> _selectedAccounts = [];
  bool _isMultiSelectMode = false;

  AccountMultiSelectBloc({required DeleteAccountUseCase deleteAccountUseCase})
    : _deleteAccountUseCase = deleteAccountUseCase,
      super(const AccountMultiSelectInitial()) {
    // Register event handlers
    on<EnableMultiSelectMode>(_onEnableMultiSelectMode);
    on<EnableMultiSelectModeAndSelect>(_onEnableMultiSelectModeAndSelect);
    on<DisableMultiSelectMode>(_onDisableMultiSelectMode);
    on<SelectAccount>(_onSelectAccount);
    on<DeselectAccount>(_onDeselectAccount);
    on<SelectAllAccounts>(_onSelectAllAccounts);
    on<DeselectAllAccounts>(_onDeselectAllAccounts);
    on<BulkDeleteAccounts>(_onBulkDeleteAccounts);
    on<BulkExportAccounts>(_onBulkExportAccounts);
  }

  /// Get the current list of selected accounts
  List<Account> get selectedAccounts => List.unmodifiable(_selectedAccounts);

  /// Check if multi-select mode is enabled
  bool get isMultiSelectMode => _isMultiSelectMode;

  /// Check if an account is selected
  bool isAccountSelected(Account account) {
    return _selectedAccounts.any(
      (selected) => selected.accountId == account.accountId,
    );
  }

  /// Get the count of selected accounts
  int get selectedCount => _selectedAccounts.length;

  void _onEnableMultiSelectMode(
    EnableMultiSelectMode event,
    Emitter<AccountMultiSelectState> emit,
  ) {
    _logger.d('Enabling multi-select mode');
    _isMultiSelectMode = true;
    _selectedAccounts.clear();
    emit(MultiSelectModeEnabled(selectedAccounts: _selectedAccounts));
  }

  void _onEnableMultiSelectModeAndSelect(
    EnableMultiSelectModeAndSelect event,
    Emitter<AccountMultiSelectState> emit,
  ) {
    _logger.d(
      'Enabling multi-select mode and selecting account: ${event.account.accountId}',
    );
    _isMultiSelectMode = true;
    _selectedAccounts.clear();
    _selectedAccounts.add(event.account);
    emit(
      MultiSelectModeEnabled(selectedAccounts: List.from(_selectedAccounts)),
    );
  }

  void _onDisableMultiSelectMode(
    DisableMultiSelectMode event,
    Emitter<AccountMultiSelectState> emit,
  ) {
    _logger.d('Disabling multi-select mode');
    _isMultiSelectMode = false;
    _selectedAccounts.clear();
    emit(const MultiSelectModeDisabled());
  }

  void _onSelectAccount(
    SelectAccount event,
    Emitter<AccountMultiSelectState> emit,
  ) {
    if (!_isMultiSelectMode) {
      _logger.w('Cannot select account - multi-select mode is not enabled');
      return;
    }

    if (!isAccountSelected(event.account)) {
      _logger.d('Selecting account: ${event.account.accountId}');
      _selectedAccounts.add(event.account);
      emit(
        AccountSelected(
          account: event.account,
          selectedAccounts: List.from(_selectedAccounts),
        ),
      );
    } else {
      _logger.d('Account already selected: ${event.account.accountId}');
    }
  }

  void _onDeselectAccount(
    DeselectAccount event,
    Emitter<AccountMultiSelectState> emit,
  ) {
    if (!_isMultiSelectMode) {
      _logger.w('Cannot deselect account - multi-select mode is not enabled');
      return;
    }

    if (isAccountSelected(event.account)) {
      _logger.d('Deselecting account: ${event.account.accountId}');
      _selectedAccounts.removeWhere(
        (selected) => selected.accountId == event.account.accountId,
      );
      emit(
        AccountDeselected(
          account: event.account,
          selectedAccounts: List.from(_selectedAccounts),
        ),
      );
    } else {
      _logger.d('Account not selected: ${event.account.accountId}');
    }
  }

  void _onSelectAllAccounts(
    SelectAllAccounts event,
    Emitter<AccountMultiSelectState> emit,
  ) {
    if (!_isMultiSelectMode) {
      _logger.w(
        'Cannot select all accounts - multi-select mode is not enabled',
      );
      return;
    }

    _logger.d('Selecting all ${event.accounts.length} accounts');

    // Clear current selections and add all accounts
    _selectedAccounts.clear();
    _selectedAccounts.addAll(event.accounts);

    emit(AllAccountsSelected(selectedAccounts: List.from(_selectedAccounts)));
  }

  void _onDeselectAllAccounts(
    DeselectAllAccounts event,
    Emitter<AccountMultiSelectState> emit,
  ) {
    if (!_isMultiSelectMode) {
      _logger.w(
        'Cannot deselect all accounts - multi-select mode is not enabled',
      );
      return;
    }

    _logger.d('Deselecting all accounts');
    _selectedAccounts.clear();
    emit(const AllAccountsDeselected());
  }

  Future<void> _onBulkDeleteAccounts(
    BulkDeleteAccounts event,
    Emitter<AccountMultiSelectState> emit,
  ) async {
    if (!_isMultiSelectMode || _selectedAccounts.isEmpty) {
      _logger.w(
        'Cannot bulk delete - no accounts selected or multi-select mode not enabled',
      );
      return;
    }

    try {
      _logger.d('Starting bulk delete of ${_selectedAccounts.length} accounts');
      emit(
        BulkDeleteInProgress(accountsToDelete: List.from(_selectedAccounts)),
      );

      final accountsToDelete = List<Account>.from(_selectedAccounts);
      int deletedCount = 0;
      final List<Account> failedAccounts = [];

      for (final account in accountsToDelete) {
        try {
          await _deleteAccountUseCase(account.accountId);
          deletedCount++;
          _logger.d('Successfully deleted account: ${account.accountId}');
        } catch (e) {
          handleException(
            e,
            context: 'delete_account',
            metadata: {'accountId': account.accountId},
          );
          failedAccounts.add(account);
        }
      }

      // Clear selected accounts
      _selectedAccounts.clear();

      if (failedAccounts.isEmpty) {
        // Disable multi-select mode after successful deletion
        _isMultiSelectMode = false;
        emit(BulkDeleteCompleted(deletedCount: deletedCount));
        emit(const MultiSelectModeDisabled());
        _logger.d(
          'Bulk delete completed successfully: $deletedCount accounts deleted, multi-select mode disabled',
        );
      } else {
        emit(
          BulkDeleteFailure(
            message: 'Failed to delete ${failedAccounts.length} accounts',
            failedAccounts: failedAccounts,
          ),
        );
        _logger.w(
          'Bulk delete completed with failures: $deletedCount deleted, ${failedAccounts.length} failed',
        );
      }
    } catch (e) {
      final message = handleException(e, context: 'bulk_delete_accounts');
      emit(
        BulkDeleteFailure(
          message: message,
          failedAccounts: List.from(_selectedAccounts),
        ),
      );
    }
  }

  Future<void> _onBulkExportAccounts(
    BulkExportAccounts event,
    Emitter<AccountMultiSelectState> emit,
  ) async {
    if (!_isMultiSelectMode || _selectedAccounts.isEmpty) {
      _logger.w(
        'Cannot bulk export - no accounts selected or multi-select mode not enabled',
      );
      return;
    }

    _logger.d(
      'Bulk export requested for ${_selectedAccounts.length} accounts in ${event.format} format',
    );
    // Note: This would typically trigger an export event or delegate to an export service
    // For now, we'll just log the request
    _logger.d(
      'Bulk export functionality would be handled by the export service',
    );
  }

  /// Toggle selection of an account
  void toggleAccountSelection(Account account) {
    if (!_isMultiSelectMode) {
      add(const EnableMultiSelectMode());
    }

    if (isAccountSelected(account)) {
      add(DeselectAccount(account));
    } else {
      add(SelectAccount(account));
    }
  }

  /// Clear all selections
  void clearSelections() {
    if (_isMultiSelectMode) {
      add(const DeselectAllAccounts());
    }
  }

  /// Exit multi-select mode
  void exitMultiSelectMode() {
    if (_isMultiSelectMode) {
      add(const DisableMultiSelectMode());
    }
  }
}
