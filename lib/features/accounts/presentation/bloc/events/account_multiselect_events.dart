import 'package:equatable/equatable.dart';
import '../../../domain/entities/account.dart';

/// Base class for multi-select events
abstract class MultiSelectEvent extends Equatable {
  const MultiSelectEvent();

  @override
  List<Object?> get props => [];
}

/// Event to enable multi-select mode
class EnableMultiSelectMode extends MultiSelectEvent {
  const EnableMultiSelectMode();
}

/// Event to enable multi-select mode and select an account
class EnableMultiSelectModeAndSelect extends MultiSelectEvent {
  final Account account;

  const EnableMultiSelectModeAndSelect(this.account);

  @override
  List<Object?> get props => [account];
}

/// Event to disable multi-select mode
class DisableMultiSelectMode extends MultiSelectEvent {
  const DisableMultiSelectMode();
}

/// Event to select an account
class SelectAccount extends MultiSelectEvent {
  final Account account;

  const SelectAccount(this.account);

  @override
  List<Object?> get props => [account];
}

/// Event to deselect an account
class DeselectAccount extends MultiSelectEvent {
  final Account account;

  const DeselectAccount(this.account);

  @override
  List<Object?> get props => [account];
}

/// Event to select all accounts
class SelectAllAccounts extends MultiSelectEvent {
  final List<Account> accounts;

  const SelectAllAccounts({required this.accounts});

  @override
  List<Object?> get props => [accounts];
}

/// Event to deselect all accounts
class DeselectAllAccounts extends MultiSelectEvent {
  const DeselectAllAccounts();
}

/// Event to bulk delete selected accounts
class BulkDeleteAccounts extends MultiSelectEvent {
  const BulkDeleteAccounts();
}

/// Event to bulk export selected accounts
class BulkExportAccounts extends MultiSelectEvent {
  final String format;

  const BulkExportAccounts(this.format);

  @override
  List<Object?> get props => [format];
}
