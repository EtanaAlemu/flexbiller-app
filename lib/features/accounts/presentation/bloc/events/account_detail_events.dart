import 'package:equatable/equatable.dart';
import '../../../domain/entities/account.dart';

/// Base class for account detail events
abstract class AccountDetailEvent extends Equatable {
  const AccountDetailEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load account details
class LoadAccountDetails extends AccountDetailEvent {
  final String accountId;

  const LoadAccountDetails(this.accountId);

  @override
  List<Object?> get props => [accountId];
}

/// Event to create a new account
class CreateAccount extends AccountDetailEvent {
  final Account account;

  const CreateAccount(this.account);

  @override
  List<Object?> get props => [account];
}

/// Event to update an existing account
class UpdateAccount extends AccountDetailEvent {
  final Account account;

  const UpdateAccount(this.account);

  @override
  List<Object?> get props => [account];
}

/// Event to delete an account
class DeleteAccount extends AccountDetailEvent {
  final String accountId;

  const DeleteAccount(this.accountId);

  @override
  List<Object?> get props => [accountId];
}

/// Event to load account timeline
class LoadAccountTimeline extends AccountDetailEvent {
  final String accountId;

  const LoadAccountTimeline(this.accountId);

  @override
  List<Object?> get props => [accountId];
}

/// Event to refresh account timeline
class RefreshAccountTimeline extends AccountDetailEvent {
  final String accountId;

  const RefreshAccountTimeline(this.accountId);

  @override
  List<Object?> get props => [accountId];
}

/// Event to load account tags
class LoadAccountTags extends AccountDetailEvent {
  final String accountId;

  const LoadAccountTags(this.accountId);

  @override
  List<Object?> get props => [accountId];
}

/// Event to refresh account tags
class RefreshAccountTags extends AccountDetailEvent {
  final String accountId;

  const RefreshAccountTags(this.accountId);

  @override
  List<Object?> get props => [accountId];
}

/// Event to assign a tag to an account
class AssignTagToAccount extends AccountDetailEvent {
  final String accountId;
  final String tagId;

  const AssignTagToAccount(this.accountId, this.tagId);

  @override
  List<Object?> get props => [accountId, tagId];
}

/// Event to remove a tag from an account
class RemoveTagFromAccount extends AccountDetailEvent {
  final String accountId;
  final String tagId;

  const RemoveTagFromAccount(this.accountId, this.tagId);

  @override
  List<Object?> get props => [accountId, tagId];
}

/// Event to remove multiple tags from an account
class RemoveMultipleTagsFromAccount extends AccountDetailEvent {
  final String accountId;
  final List<String> tagIds;

  const RemoveMultipleTagsFromAccount(this.accountId, this.tagIds);

  @override
  List<Object?> get props => [accountId, tagIds];
}

/// Event to assign multiple tags to an account
class AssignMultipleTagsToAccount extends AccountDetailEvent {
  final String accountId;
  final List<String> tagIds;

  const AssignMultipleTagsToAccount(this.accountId, this.tagIds);

  @override
  List<Object?> get props => [accountId, tagIds];
}

/// Event to load all tags for an account
class LoadAllTagsForAccount extends AccountDetailEvent {
  final String accountId;

  const LoadAllTagsForAccount(this.accountId);

  @override
  List<Object?> get props => [accountId];
}

/// Event to load account custom fields
class LoadAccountCustomFields extends AccountDetailEvent {
  final String accountId;

  const LoadAccountCustomFields(this.accountId);

  @override
  List<Object?> get props => [accountId];
}

/// Event to create account custom field
class CreateAccountCustomField extends AccountDetailEvent {
  final String accountId;
  final Map<String, dynamic> customField;

  const CreateAccountCustomField(this.accountId, this.customField);

  @override
  List<Object?> get props => [accountId, customField];
}

/// Event to update account custom field
class UpdateAccountCustomField extends AccountDetailEvent {
  final String accountId;
  final String customFieldId;
  final Map<String, dynamic> customField;

  const UpdateAccountCustomField(
    this.accountId,
    this.customFieldId,
    this.customField,
  );

  @override
  List<Object?> get props => [accountId, customFieldId, customField];
}

/// Event to delete account custom field
class DeleteAccountCustomField extends AccountDetailEvent {
  final String accountId;
  final String customFieldId;

  const DeleteAccountCustomField(this.accountId, this.customFieldId);

  @override
  List<Object?> get props => [accountId, customFieldId];
}

/// Event to load account emails
class LoadAccountEmails extends AccountDetailEvent {
  final String accountId;

  const LoadAccountEmails(this.accountId);

  @override
  List<Object?> get props => [accountId];
}

/// Event to load account blocking states
class LoadAccountBlockingStates extends AccountDetailEvent {
  final String accountId;

  const LoadAccountBlockingStates(this.accountId);

  @override
  List<Object?> get props => [accountId];
}

/// Event to load account invoice payments
class LoadAccountInvoicePayments extends AccountDetailEvent {
  final String accountId;

  const LoadAccountInvoicePayments(this.accountId);

  @override
  List<Object?> get props => [accountId];
}

/// Event to load account audit logs
class LoadAccountAuditLogs extends AccountDetailEvent {
  final String accountId;

  const LoadAccountAuditLogs(this.accountId);

  @override
  List<Object?> get props => [accountId];
}

/// Event to load account payment methods
class LoadAccountPaymentMethods extends AccountDetailEvent {
  final String accountId;

  const LoadAccountPaymentMethods(this.accountId);

  @override
  List<Object?> get props => [accountId];
}

/// Event to load account payments
class LoadAccountPayments extends AccountDetailEvent {
  final String accountId;

  const LoadAccountPayments(this.accountId);

  @override
  List<Object?> get props => [accountId];
}

/// Event to refresh account payments
class RefreshAccountPayments extends AccountDetailEvent {
  final String accountId;

  const RefreshAccountPayments(this.accountId);

  @override
  List<Object?> get props => [accountId];
}

/// Event to create account payment
class CreateAccountPayment extends AccountDetailEvent {
  final String accountId;
  final Map<String, dynamic> paymentData;

  const CreateAccountPayment(this.accountId, this.paymentData);

  @override
  List<Object?> get props => [accountId, paymentData];
}
