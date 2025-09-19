import 'package:equatable/equatable.dart';
import '../../../domain/entities/account.dart';

/// Base class for multi-select states
abstract class AccountMultiSelectState extends Equatable {
  const AccountMultiSelectState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class AccountMultiSelectInitial extends AccountMultiSelectState {
  const AccountMultiSelectInitial();
}

/// Multi-select mode enabled state
class MultiSelectModeEnabled extends AccountMultiSelectState {
  final List<Account> selectedAccounts;

  const MultiSelectModeEnabled({required this.selectedAccounts});

  @override
  List<Object?> get props => [selectedAccounts];
}

/// Multi-select mode disabled state
class MultiSelectModeDisabled extends AccountMultiSelectState {
  const MultiSelectModeDisabled();
}

/// Account selected state
class AccountSelected extends AccountMultiSelectState {
  final Account account;
  final List<Account> selectedAccounts;

  const AccountSelected({
    required this.account,
    required this.selectedAccounts,
  });

  @override
  List<Object?> get props => [account, selectedAccounts];
}

/// Account deselected state
class AccountDeselected extends AccountMultiSelectState {
  final Account account;
  final List<Account> selectedAccounts;

  const AccountDeselected({
    required this.account,
    required this.selectedAccounts,
  });

  @override
  List<Object?> get props => [account, selectedAccounts];
}

/// All accounts selected state
class AllAccountsSelected extends AccountMultiSelectState {
  final List<Account> selectedAccounts;

  const AllAccountsSelected({required this.selectedAccounts});

  @override
  List<Object?> get props => [selectedAccounts];
}

/// All accounts deselected state
class AllAccountsDeselected extends AccountMultiSelectState {
  const AllAccountsDeselected();
}

/// Bulk delete in progress state
class BulkDeleteInProgress extends AccountMultiSelectState {
  final List<Account> accountsToDelete;

  const BulkDeleteInProgress({required this.accountsToDelete});

  @override
  List<Object?> get props => [accountsToDelete];
}

/// Bulk delete completed state
class BulkDeleteCompleted extends AccountMultiSelectState {
  final int deletedCount;

  const BulkDeleteCompleted({required this.deletedCount});

  @override
  List<Object?> get props => [deletedCount];
}

/// Bulk delete failure state
class BulkDeleteFailure extends AccountMultiSelectState {
  final String message;
  final List<Account> failedAccounts;

  const BulkDeleteFailure({
    required this.message,
    required this.failedAccounts,
  });

  @override
  List<Object?> get props => [message, failedAccounts];
}
