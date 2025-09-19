import 'package:equatable/equatable.dart';
import 'package:flexbiller_app/features/tags/domain/entities/tag.dart';
import '../../../domain/entities/account.dart';
import '../../../domain/entities/account_audit_log.dart';
import '../../../domain/entities/account_blocking_state.dart';
import '../../../domain/entities/account_custom_field.dart';
import '../../../domain/entities/account_payment.dart';
import '../../../domain/entities/account_payment_method.dart';
import '../../../domain/entities/account_timeline.dart';

/// Base class for account detail states
abstract class AccountDetailState extends Equatable {
  const AccountDetailState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class AccountDetailInitial extends AccountDetailState {
  const AccountDetailInitial();
}

/// Loading state for account details
class AccountDetailsLoading extends AccountDetailState {
  final String accountId;

  const AccountDetailsLoading(this.accountId);

  @override
  List<Object?> get props => [accountId];
}

/// Loaded state for account details
class AccountDetailsLoaded extends AccountDetailState {
  final Account account;

  const AccountDetailsLoaded(this.account);

  @override
  List<Object?> get props => [account];
}

/// Failure state for account details
class AccountDetailsFailure extends AccountDetailState {
  final String message;
  final String accountId;

  const AccountDetailsFailure(this.message, this.accountId);

  @override
  List<Object?> get props => [message, accountId];
}

/// Creating state for account
class AccountCreating extends AccountDetailState {
  const AccountCreating();
}

/// Created state for account
class AccountCreated extends AccountDetailState {
  final Account account;

  const AccountCreated(this.account);

  @override
  List<Object?> get props => [account];
}

/// Creation failure state for account
class AccountCreationFailure extends AccountDetailState {
  final String message;

  const AccountCreationFailure(this.message);

  @override
  List<Object?> get props => [message];
}

/// Updating state for account
class AccountUpdating extends AccountDetailState {
  const AccountUpdating();
}

/// Updated state for account
class AccountUpdated extends AccountDetailState {
  final Account account;

  const AccountUpdated(this.account);

  @override
  List<Object?> get props => [account];
}

/// Update failure state for account
class AccountUpdateFailure extends AccountDetailState {
  final String message;

  const AccountUpdateFailure(this.message);

  @override
  List<Object?> get props => [message];
}

/// Deleting state for account
class AccountDeleting extends AccountDetailState {
  final String accountId;

  const AccountDeleting(this.accountId);

  @override
  List<Object?> get props => [accountId];
}

/// Deleted state for account
class AccountDeleted extends AccountDetailState {
  final String accountId;

  const AccountDeleted(this.accountId);

  @override
  List<Object?> get props => [accountId];
}

/// Delete failure state for account
class AccountDeleteFailure extends AccountDetailState {
  final String message;
  final String accountId;

  const AccountDeleteFailure(this.message, this.accountId);

  @override
  List<Object?> get props => [message, accountId];
}

/// Loading state for account timeline
class AccountTimelineLoading extends AccountDetailState {
  final String accountId;

  const AccountTimelineLoading(this.accountId);

  @override
  List<Object?> get props => [accountId];
}

/// Loaded state for account timeline
class AccountTimelineLoaded extends AccountDetailState {
  final String accountId;
  final List<AccountTimeline> timeline;

  const AccountTimelineLoaded(this.accountId, this.timeline);

  @override
  List<Object?> get props => [accountId, timeline];
}

/// Failure state for account timeline
class AccountTimelineFailure extends AccountDetailState {
  final String message;
  final String accountId;

  const AccountTimelineFailure(this.message, this.accountId);

  @override
  List<Object?> get props => [message, accountId];
}

/// Loading state for account tags
class AccountTagsLoading extends AccountDetailState {
  final String accountId;

  const AccountTagsLoading(this.accountId);

  @override
  List<Object?> get props => [accountId];
}

/// Loaded state for account tags
class AccountTagsLoaded extends AccountDetailState {
  final String accountId;
  final List<Tag> tags;

  const AccountTagsLoaded(this.accountId, this.tags);

  @override
  List<Object?> get props => [accountId, tags];
}

/// Failure state for account tags
class AccountTagsFailure extends AccountDetailState {
  final String message;
  final String accountId;

  const AccountTagsFailure(this.message, this.accountId);

  @override
  List<Object?> get props => [message, accountId];
}

/// Tag assigned state
class TagAssigned extends AccountDetailState {
  final String accountId;
  final String tagId;

  const TagAssigned(this.accountId, this.tagId);

  @override
  List<Object?> get props => [accountId, tagId];
}

/// Tag removed state
class TagRemoved extends AccountDetailState {
  final String accountId;
  final String tagId;

  const TagRemoved(this.accountId, this.tagId);

  @override
  List<Object?> get props => [accountId, tagId];
}

/// Loading state for account custom fields
class AccountCustomFieldsLoading extends AccountDetailState {
  final String accountId;

  const AccountCustomFieldsLoading(this.accountId);

  @override
  List<Object?> get props => [accountId];
}

/// Loaded state for account custom fields
class AccountCustomFieldsLoaded extends AccountDetailState {
  final String accountId;
  final List<AccountCustomField> customFields;

  const AccountCustomFieldsLoaded(this.accountId, this.customFields);

  @override
  List<Object?> get props => [accountId, customFields];
}

/// Failure state for account custom fields
class AccountCustomFieldsFailure extends AccountDetailState {
  final String message;
  final String accountId;

  const AccountCustomFieldsFailure(this.message, this.accountId);

  @override
  List<Object?> get props => [message, accountId];
}

/// Loading state for account emails
class AccountEmailsLoading extends AccountDetailState {
  final String accountId;

  const AccountEmailsLoading(this.accountId);

  @override
  List<Object?> get props => [accountId];
}

/// Loaded state for account emails
class AccountEmailsLoaded extends AccountDetailState {
  final String accountId;
  final List<String> emails;

  const AccountEmailsLoaded(this.accountId, this.emails);

  @override
  List<Object?> get props => [accountId, emails];
}

/// Failure state for account emails
class AccountEmailsFailure extends AccountDetailState {
  final String message;
  final String accountId;

  const AccountEmailsFailure(this.message, this.accountId);

  @override
  List<Object?> get props => [message, accountId];
}

/// Loading state for account blocking states
class AccountBlockingStatesLoading extends AccountDetailState {
  final String accountId;

  const AccountBlockingStatesLoading(this.accountId);

  @override
  List<Object?> get props => [accountId];
}

/// Loaded state for account blocking states
class AccountBlockingStatesLoaded extends AccountDetailState {
  final String accountId;
  final List<AccountBlockingState> blockingStates;

  const AccountBlockingStatesLoaded(this.accountId, this.blockingStates);

  @override
  List<Object?> get props => [accountId, blockingStates];
}

/// Failure state for account blocking states
class AccountBlockingStatesFailure extends AccountDetailState {
  final String message;
  final String accountId;

  const AccountBlockingStatesFailure(this.message, this.accountId);

  @override
  List<Object?> get props => [message, accountId];
}

/// Loading state for account invoice payments
class AccountInvoicePaymentsLoading extends AccountDetailState {
  final String accountId;

  const AccountInvoicePaymentsLoading(this.accountId);

  @override
  List<Object?> get props => [accountId];
}

/// Loaded state for account invoice payments
class AccountInvoicePaymentsLoaded extends AccountDetailState {
  final String accountId;
  final List<AccountPayment> payments;

  const AccountInvoicePaymentsLoaded(this.accountId, this.payments);

  @override
  List<Object?> get props => [accountId, payments];
}

/// Failure state for account invoice payments
class AccountInvoicePaymentsFailure extends AccountDetailState {
  final String message;
  final String accountId;

  const AccountInvoicePaymentsFailure(this.message, this.accountId);

  @override
  List<Object?> get props => [message, accountId];
}

/// Loading state for account audit logs
class AccountAuditLogsLoading extends AccountDetailState {
  final String accountId;

  const AccountAuditLogsLoading(this.accountId);

  @override
  List<Object?> get props => [accountId];
}

/// Loaded state for account audit logs
class AccountAuditLogsLoaded extends AccountDetailState {
  final String accountId;
  final List<AccountAuditLog> auditLogs;

  const AccountAuditLogsLoaded(this.accountId, this.auditLogs);

  @override
  List<Object?> get props => [accountId, auditLogs];
}

/// Failure state for account audit logs
class AccountAuditLogsFailure extends AccountDetailState {
  final String message;
  final String accountId;

  const AccountAuditLogsFailure(this.message, this.accountId);

  @override
  List<Object?> get props => [message, accountId];
}

/// Loading state for account payment methods
class AccountPaymentMethodsLoading extends AccountDetailState {
  final String accountId;

  const AccountPaymentMethodsLoading(this.accountId);

  @override
  List<Object?> get props => [accountId];
}

/// Loaded state for account payment methods
class AccountPaymentMethodsLoaded extends AccountDetailState {
  final String accountId;
  final List<AccountPaymentMethod> paymentMethods;

  const AccountPaymentMethodsLoaded(this.accountId, this.paymentMethods);

  @override
  List<Object?> get props => [accountId, paymentMethods];
}

/// Failure state for account payment methods
class AccountPaymentMethodsFailure extends AccountDetailState {
  final String message;
  final String accountId;

  const AccountPaymentMethodsFailure(this.message, this.accountId);

  @override
  List<Object?> get props => [message, accountId];
}

/// Loading state for account payments
class AccountPaymentsLoading extends AccountDetailState {
  final String accountId;

  const AccountPaymentsLoading(this.accountId);

  @override
  List<Object?> get props => [accountId];
}

/// Loaded state for account payments
class AccountPaymentsLoaded extends AccountDetailState {
  final String accountId;
  final List<AccountPayment> payments;

  const AccountPaymentsLoaded(this.accountId, this.payments);

  @override
  List<Object?> get props => [accountId, payments];
}

/// Failure state for account payments
class AccountPaymentsFailure extends AccountDetailState {
  final String message;
  final String accountId;

  const AccountPaymentsFailure(this.message, this.accountId);

  @override
  List<Object?> get props => [message, accountId];
}
