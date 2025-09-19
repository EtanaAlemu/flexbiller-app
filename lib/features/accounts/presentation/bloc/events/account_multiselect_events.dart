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
  const SelectAllAccounts();
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
