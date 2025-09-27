import 'package:equatable/equatable.dart';

abstract class AccountCustomFieldsEvent extends Equatable {
  final String accountId;

  const AccountCustomFieldsEvent(this.accountId);

  @override
  List<Object> get props => [accountId];
}

/// Event to load account custom fields
class LoadAccountCustomFields extends AccountCustomFieldsEvent {
  const LoadAccountCustomFields(String accountId) : super(accountId);
}

/// Event to refresh account custom fields
class RefreshAccountCustomFields extends AccountCustomFieldsEvent {
  const RefreshAccountCustomFields(String accountId) : super(accountId);
}

/// Event to create a single custom field
class CreateAccountCustomField extends AccountCustomFieldsEvent {
  final String name;
  final String value;

  const CreateAccountCustomField({
    required String accountId,
    required this.name,
    required this.value,
  }) : super(accountId);

  @override
  List<Object> get props => [accountId, name, value];
}

/// Event to create multiple custom fields
class CreateMultipleAccountCustomFields extends AccountCustomFieldsEvent {
  final List<Map<String, String>> customFields;

  const CreateMultipleAccountCustomFields({
    required String accountId,
    required this.customFields,
  }) : super(accountId);

  @override
  List<Object> get props => [accountId, customFields];
}

/// Event to update a custom field
class UpdateAccountCustomField extends AccountCustomFieldsEvent {
  final String customFieldId;
  final String name;
  final String value;

  const UpdateAccountCustomField({
    required String accountId,
    required this.customFieldId,
    required this.name,
    required this.value,
  }) : super(accountId);

  @override
  List<Object> get props => [accountId, customFieldId, name, value];
}

/// Event to update multiple custom fields
class UpdateMultipleAccountCustomFields extends AccountCustomFieldsEvent {
  final List<Map<String, dynamic>> customFields;

  const UpdateMultipleAccountCustomFields({
    required String accountId,
    required this.customFields,
  }) : super(accountId);

  @override
  List<Object> get props => [accountId, customFields];
}

/// Event to delete a custom field
class DeleteAccountCustomField extends AccountCustomFieldsEvent {
  final String customFieldId;

  const DeleteAccountCustomField({
    required String accountId,
    required this.customFieldId,
  }) : super(accountId);

  @override
  List<Object> get props => [accountId, customFieldId];
}

/// Event to delete multiple custom fields
class DeleteMultipleAccountCustomFields extends AccountCustomFieldsEvent {
  final List<String> customFieldIds;

  const DeleteMultipleAccountCustomFields({
    required String accountId,
    required this.customFieldIds,
  }) : super(accountId);

  @override
  List<Object> get props => [accountId, customFieldIds];
}

/// Event to search custom fields by name
class SearchCustomFieldsByName extends AccountCustomFieldsEvent {
  final String name;

  const SearchCustomFieldsByName({
    required String accountId,
    required this.name,
  }) : super(accountId);

  @override
  List<Object> get props => [accountId, name];
}

/// Event to search custom fields by value
class SearchCustomFieldsByValue extends AccountCustomFieldsEvent {
  final String value;

  const SearchCustomFieldsByValue({
    required String accountId,
    required this.value,
  }) : super(accountId);

  @override
  List<Object> get props => [accountId, value];
}

/// Event to sync custom fields with remote
class SyncAccountCustomFields extends AccountCustomFieldsEvent {
  const SyncAccountCustomFields(String accountId) : super(accountId);
}

/// Event to clear custom fields state
class ClearAccountCustomFields extends AccountCustomFieldsEvent {
  const ClearAccountCustomFields(String accountId) : super(accountId);
}
