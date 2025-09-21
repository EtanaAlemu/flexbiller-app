import 'package:equatable/equatable.dart';
import '../../domain/entities/account_custom_field.dart';

abstract class AccountCustomFieldsState extends Equatable {
  final String accountId;

  const AccountCustomFieldsState(this.accountId);

  @override
  List<Object> get props => [accountId];
}

/// Initial state
class AccountCustomFieldsInitial extends AccountCustomFieldsState {
  const AccountCustomFieldsInitial(String accountId) : super(accountId);
}

/// Loading state
class AccountCustomFieldsLoading extends AccountCustomFieldsState {
  const AccountCustomFieldsLoading(String accountId) : super(accountId);
}

/// Loaded state with custom fields
class AccountCustomFieldsLoaded extends AccountCustomFieldsState {
  final List<AccountCustomField> customFields;

  const AccountCustomFieldsLoaded({
    required String accountId,
    required this.customFields,
  }) : super(accountId);

  @override
  List<Object> get props => [accountId, customFields];
}

/// Failure state
class AccountCustomFieldsFailure extends AccountCustomFieldsState {
  final String message;

  const AccountCustomFieldsFailure({
    required String accountId,
    required this.message,
  }) : super(accountId);

  @override
  List<Object> get props => [accountId, message];
}

/// Creating custom field state
class AccountCustomFieldCreating extends AccountCustomFieldsState {
  const AccountCustomFieldCreating(String accountId) : super(accountId);
}

/// Custom field created successfully
class AccountCustomFieldCreated extends AccountCustomFieldsState {
  final AccountCustomField customField;

  const AccountCustomFieldCreated({
    required String accountId,
    required this.customField,
  }) : super(accountId);

  @override
  List<Object> get props => [accountId, customField];
}

/// Custom field creation failed
class AccountCustomFieldCreationFailure extends AccountCustomFieldsState {
  final String message;

  const AccountCustomFieldCreationFailure({
    required String accountId,
    required this.message,
  }) : super(accountId);

  @override
  List<Object> get props => [accountId, message];
}

/// Multiple custom fields created successfully
class MultipleAccountCustomFieldsCreated extends AccountCustomFieldsState {
  final List<AccountCustomField> customFields;

  const MultipleAccountCustomFieldsCreated({
    required String accountId,
    required this.customFields,
  }) : super(accountId);

  @override
  List<Object> get props => [accountId, customFields];
}

/// Multiple custom fields creation failed
class MultipleAccountCustomFieldsCreationFailure
    extends AccountCustomFieldsState {
  final String message;

  const MultipleAccountCustomFieldsCreationFailure({
    required String accountId,
    required this.message,
  }) : super(accountId);

  @override
  List<Object> get props => [accountId, message];
}

/// Updating custom field state
class AccountCustomFieldUpdating extends AccountCustomFieldsState {
  const AccountCustomFieldUpdating(String accountId) : super(accountId);
}

/// Custom field updated successfully
class AccountCustomFieldUpdated extends AccountCustomFieldsState {
  final AccountCustomField customField;

  const AccountCustomFieldUpdated({
    required String accountId,
    required this.customField,
  }) : super(accountId);

  @override
  List<Object> get props => [accountId, customField];
}

/// Custom field update failed
class AccountCustomFieldUpdateFailure extends AccountCustomFieldsState {
  final String message;

  const AccountCustomFieldUpdateFailure({
    required String accountId,
    required this.message,
  }) : super(accountId);

  @override
  List<Object> get props => [accountId, message];
}

/// Multiple custom fields updated successfully
class MultipleAccountCustomFieldsUpdated extends AccountCustomFieldsState {
  final List<AccountCustomField> customFields;

  const MultipleAccountCustomFieldsUpdated({
    required String accountId,
    required this.customFields,
  }) : super(accountId);

  @override
  List<Object> get props => [accountId, customFields];
}

/// Multiple custom fields update failed
class MultipleAccountCustomFieldsUpdateFailure
    extends AccountCustomFieldsState {
  final String message;

  const MultipleAccountCustomFieldsUpdateFailure({
    required String accountId,
    required this.message,
  }) : super(accountId);

  @override
  List<Object> get props => [accountId, message];
}

/// Deleting custom field state
class AccountCustomFieldDeleting extends AccountCustomFieldsState {
  const AccountCustomFieldDeleting(String accountId) : super(accountId);
}

/// Custom field deleted successfully
class AccountCustomFieldDeleted extends AccountCustomFieldsState {
  final String customFieldId;

  const AccountCustomFieldDeleted({
    required String accountId,
    required this.customFieldId,
  }) : super(accountId);

  @override
  List<Object> get props => [accountId, customFieldId];
}

/// Custom field deletion failed
class AccountCustomFieldDeletionFailure extends AccountCustomFieldsState {
  final String message;

  const AccountCustomFieldDeletionFailure({
    required String accountId,
    required this.message,
  }) : super(accountId);

  @override
  List<Object> get props => [accountId, message];
}

/// Multiple custom fields deleted successfully
class MultipleAccountCustomFieldsDeleted extends AccountCustomFieldsState {
  final List<String> customFieldIds;

  const MultipleAccountCustomFieldsDeleted({
    required String accountId,
    required this.customFieldIds,
  }) : super(accountId);

  @override
  List<Object> get props => [accountId, customFieldIds];
}

/// Multiple custom fields deletion failed
class MultipleAccountCustomFieldsDeletionFailure
    extends AccountCustomFieldsState {
  final String message;

  const MultipleAccountCustomFieldsDeletionFailure({
    required String accountId,
    required this.message,
  }) : super(accountId);

  @override
  List<Object> get props => [accountId, message];
}

/// Searching custom fields state
class AccountCustomFieldsSearching extends AccountCustomFieldsState {
  const AccountCustomFieldsSearching(String accountId) : super(accountId);
}

/// Custom fields search results
class AccountCustomFieldsSearchResults extends AccountCustomFieldsState {
  final List<AccountCustomField> customFields;
  final String searchQuery;

  const AccountCustomFieldsSearchResults({
    required String accountId,
    required this.customFields,
    required this.searchQuery,
  }) : super(accountId);

  @override
  List<Object> get props => [accountId, customFields, searchQuery];
}

/// Custom fields search failed
class AccountCustomFieldsSearchFailure extends AccountCustomFieldsState {
  final String message;

  const AccountCustomFieldsSearchFailure({
    required String accountId,
    required this.message,
  }) : super(accountId);

  @override
  List<Object> get props => [accountId, message];
}

/// Syncing custom fields state
class AccountCustomFieldsSyncing extends AccountCustomFieldsState {
  const AccountCustomFieldsSyncing(String accountId) : super(accountId);
}

/// Custom fields synced successfully
class AccountCustomFieldsSynced extends AccountCustomFieldsState {
  final List<AccountCustomField> customFields;

  const AccountCustomFieldsSynced({
    required String accountId,
    required this.customFields,
  }) : super(accountId);

  @override
  List<Object> get props => [accountId, customFields];
}

/// Custom fields sync failed
class AccountCustomFieldsSyncFailure extends AccountCustomFieldsState {
  final String message;

  const AccountCustomFieldsSyncFailure({
    required String accountId,
    required this.message,
  }) : super(accountId);

  @override
  List<Object> get props => [accountId, message];
}
