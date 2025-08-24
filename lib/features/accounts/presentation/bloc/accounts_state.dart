import 'package:equatable/equatable.dart';
import '../../domain/entities/account.dart';
import '../../domain/entities/accounts_query_params.dart';
import '../../domain/entities/account_timeline.dart';
import '../../domain/entities/account_tag.dart';
import '../../domain/entities/account_custom_field.dart';
import '../../domain/entities/account_email.dart';
import '../../domain/entities/account_blocking_state.dart';
import '../../domain/entities/account_invoice_payment.dart';
import '../../domain/entities/account_audit_log.dart';
import '../../domain/entities/account_payment_method.dart';
import '../../domain/entities/account_payment.dart';

abstract class AccountsState extends Equatable {
  const AccountsState();

  @override
  List<Object?> get props => [];
}

class AccountsInitial extends AccountsState {}

class AccountsLoading extends AccountsState {
  final AccountsQueryParams params;

  const AccountsLoading(this.params);

  @override
  List<Object?> get props => [params];
}

class AccountsLoaded extends AccountsState {
  final List<Account> accounts;
  final bool hasReachedMax;
  final int currentOffset;
  final int totalCount;

  const AccountsLoaded({
    required this.accounts,
    this.hasReachedMax = false,
    this.currentOffset = 0,
    this.totalCount = 0,
  });

  AccountsLoaded copyWith({
    List<Account>? accounts,
    bool? hasReachedMax,
    int? currentOffset,
    int? totalCount,
  }) {
    return AccountsLoaded(
      accounts: accounts ?? this.accounts,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentOffset: currentOffset ?? this.currentOffset,
      totalCount: totalCount ?? this.totalCount,
    );
  }

  @override
  List<Object?> get props => [
    accounts,
    hasReachedMax,
    currentOffset,
    totalCount,
  ];
}

class AccountsRefreshing extends AccountsState {
  final List<Account> accounts;

  const AccountsRefreshing(this.accounts);

  @override
  List<Object?> get props => [accounts];
}

class AccountsLoadingMore extends AccountsState {
  final List<Account> accounts;

  const AccountsLoadingMore(this.accounts);

  @override
  List<Object?> get props => [accounts];
}

class AccountsSearching extends AccountsState {
  final String searchKey;

  const AccountsSearching(this.searchKey);

  @override
  List<Object?> get props => [searchKey];
}

class AccountsSearchResults extends AccountsState {
  final List<Account> accounts;
  final String searchKey;

  const AccountsSearchResults(this.accounts, this.searchKey);

  @override
  List<Object?> get props => [accounts, searchKey];
}

class AccountsFiltered extends AccountsState {
  final List<Account> accounts;
  final String filterType;
  final String filterValue;

  const AccountsFiltered(this.accounts, this.filterType, this.filterValue);

  @override
  List<Object?> get props => [accounts, filterType, filterValue];
}

class AccountsFailure extends AccountsState {
  final String message;
  final List<Account>? previousAccounts;

  const AccountsFailure(this.message, {this.previousAccounts});

  @override
  List<Object?> get props => [message, previousAccounts];
}

class AccountDetailsLoading extends AccountsState {
  final String accountId;

  const AccountDetailsLoading(this.accountId);

  @override
  List<Object?> get props => [accountId];
}

class AccountDetailsLoaded extends AccountsState {
  final Account account;

  const AccountDetailsLoaded(this.account);

  @override
  List<Object?> get props => [account];
}

class AccountDetailsFailure extends AccountsState {
  final String message;
  final String accountId;

  const AccountDetailsFailure(this.message, this.accountId);

  @override
  List<Object?> get props => [message, accountId];
}

class AccountCreating extends AccountsState {}

class AccountCreated extends AccountsState {
  final Account account;

  const AccountCreated(this.account);

  @override
  List<Object?> get props => [account];
}

class AccountCreationFailure extends AccountsState {
  final String message;

  const AccountCreationFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class AccountUpdating extends AccountsState {}

class AccountUpdated extends AccountsState {
  final Account account;

  const AccountUpdated(this.account);

  @override
  List<Object?> get props => [account];
}

class AccountUpdateFailure extends AccountsState {
  final String message;

  const AccountUpdateFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class AccountDeleting extends AccountsState {}

class AccountDeleted extends AccountsState {
  final String accountId;

  const AccountDeleted(this.accountId);

  @override
  List<Object?> get props => [accountId];
}

class AccountDeletionFailure extends AccountsState {
  final String message;
  final String accountId;

  const AccountDeletionFailure(this.message, this.accountId);

  @override
  List<Object?> get props => [message, accountId];
}

class AccountTimelineLoading extends AccountsState {
  final String accountId;

  const AccountTimelineLoading(this.accountId);

  @override
  List<Object?> get props => [accountId];
}

class AccountTimelineLoaded extends AccountsState {
  final String accountId;
  final List<TimelineEvent> events;

  const AccountTimelineLoaded(this.accountId, this.events);

  @override
  List<Object?> get props => [accountId, events];
}

class AccountTimelineFailure extends AccountsState {
  final String message;
  final String accountId;

  const AccountTimelineFailure(this.message, this.accountId);

  @override
  List<Object?> get props => [message, accountId];
}

class AccountTagsLoading extends AccountsState {
  final String accountId;

  const AccountTagsLoading(this.accountId);

  @override
  List<Object?> get props => [accountId];
}

class AccountTagsLoaded extends AccountsState {
  final String accountId;
  final List<AccountTagAssignment> tags;

  const AccountTagsLoaded(this.accountId, this.tags);

  @override
  List<Object?> get props => [accountId, tags];
}

class AccountTagsFailure extends AccountsState {
  final String message;
  final String accountId;

  const AccountTagsFailure(this.message, this.accountId);

  @override
  List<Object?> get props => [message, accountId];
}

class TagAssigning extends AccountsState {
  final String accountId;
  final String tagId;

  const TagAssigning(this.accountId, this.tagId);

  @override
  List<Object?> get props => [accountId, tagId];
}

class TagAssigned extends AccountsState {
  final String accountId;
  final AccountTagAssignment tag;

  const TagAssigned(this.accountId, this.tag);

  @override
  List<Object?> get props => [accountId, tag];
}

class TagAssignmentFailure extends AccountsState {
  final String message;
  final String accountId;
  final String tagId;

  const TagAssignmentFailure(this.message, this.accountId, this.tagId);

  @override
  List<Object?> get props => [message, accountId, tagId];
}

class TagRemoving extends AccountsState {
  final String accountId;
  final String tagId;

  const TagRemoving(this.accountId, this.tagId);

  @override
  List<Object?> get props => [accountId, tagId];
}

class TagRemoved extends AccountsState {
  final String accountId;
  final String tagId;

  const TagRemoved(this.accountId, this.tagId);

  @override
  List<Object?> get props => [accountId, tagId];
}

class TagRemovalFailure extends AccountsState {
  final String message;
  final String accountId;
  final String tagId;

  const TagRemovalFailure(this.message, this.accountId, this.tagId);

  @override
  List<Object?> get props => [message, accountId, tagId];
}

class MultipleTagsAssigning extends AccountsState {
  final String accountId;
  final List<String> tagIds;

  const MultipleTagsAssigning(this.accountId, this.tagIds);

  @override
  List<Object?> get props => [accountId, tagIds];
}

class MultipleTagsAssigned extends AccountsState {
  final String accountId;
  final List<AccountTagAssignment> tags;

  const MultipleTagsAssigned(this.accountId, this.tags);

  @override
  List<Object?> get props => [accountId, tags];
}

class MultipleTagsAssignmentFailure extends AccountsState {
  final String message;
  final String accountId;
  final List<String> tagIds;

  const MultipleTagsAssignmentFailure(
    this.message,
    this.accountId,
    this.tagIds,
  );

  @override
  List<Object?> get props => [message, accountId, tagIds];
}

class MultipleTagsRemoving extends AccountsState {
  final String accountId;
  final List<String> tagIds;

  const MultipleTagsRemoving(this.accountId, this.tagIds);

  @override
  List<Object?> get props => [accountId, tagIds];
}

class MultipleTagsRemoved extends AccountsState {
  final String accountId;
  final List<String> tagIds;

  const MultipleTagsRemoved(this.accountId, this.tagIds);

  @override
  List<Object?> get props => [accountId, tagIds];
}

class MultipleTagsRemovalFailure extends AccountsState {
  final String message;
  final String accountId;
  final List<String> tagIds;

  const MultipleTagsRemovalFailure(this.message, this.accountId, this.tagIds);

  @override
  List<Object?> get props => [message, accountId, tagIds];
}

class AllTagsForAccountLoading extends AccountsState {
  final String accountId;

  const AllTagsForAccountLoading(this.accountId);

  @override
  List<Object?> get props => [accountId];
}

class AllTagsForAccountLoaded extends AccountsState {
  final String accountId;
  final List<AccountTag> tags;

  const AllTagsForAccountLoaded(this.accountId, this.tags);

  @override
  List<Object?> get props => [accountId, tags];
}

class AllTagsForAccountFailure extends AccountsState {
  final String message;
  final String accountId;

  const AllTagsForAccountFailure(this.message, this.accountId);

  @override
  List<Object?> get props => [message, accountId];
}

class AllTagsRemoving extends AccountsState {
  final String accountId;

  const AllTagsRemoving(this.accountId);

  @override
  List<Object?> get props => [accountId];
}

class AllTagsRemoved extends AccountsState {
  final String accountId;

  const AllTagsRemoved(this.accountId);

  @override
  List<Object?> get props => [accountId];
}

class AllTagsRemovalFailure extends AccountsState {
  final String message;
  final String accountId;

  const AllTagsRemovalFailure(this.message, this.accountId);

  @override
  List<Object?> get props => [message, accountId];
}

class AccountCustomFieldsLoading extends AccountsState {
  final String accountId;

  const AccountCustomFieldsLoading(this.accountId);

  @override
  List<Object?> get props => [accountId];
}

class AccountCustomFieldsLoaded extends AccountsState {
  final String accountId;
  final List<AccountCustomField> customFields;

  const AccountCustomFieldsLoaded(this.accountId, this.customFields);

  @override
  List<Object?> get props => [accountId, customFields];
}

class AccountCustomFieldsFailure extends AccountsState {
  final String message;
  final String accountId;

  const AccountCustomFieldsFailure(this.message, this.accountId);

  @override
  List<Object?> get props => [message, accountId];
}

class CustomFieldCreating extends AccountsState {
  final String accountId;
  final String name;
  final String value;

  const CustomFieldCreating(this.accountId, this.name, this.value);

  @override
  List<Object?> get props => [accountId, name, value];
}

class CustomFieldCreated extends AccountsState {
  final String accountId;
  final AccountCustomField customField;

  const CustomFieldCreated(this.accountId, this.customField);

  @override
  List<Object?> get props => [accountId, customField];
}

class CustomFieldCreationFailure extends AccountsState {
  final String message;
  final String accountId;
  final String name;
  final String value;

  const CustomFieldCreationFailure(
    this.message,
    this.accountId,
    this.name,
    this.value,
  );

  @override
  List<Object?> get props => [message, accountId, name, value];
}

class MultipleCustomFieldsCreating extends AccountsState {
  final String accountId;
  final List<Map<String, String>> customFields;

  const MultipleCustomFieldsCreating(this.accountId, this.customFields);

  @override
  List<Object?> get props => [accountId, customFields];
}

class MultipleCustomFieldsCreated extends AccountsState {
  final String accountId;
  final List<AccountCustomField> customFields;

  const MultipleCustomFieldsCreated(this.accountId, this.customFields);

  @override
  List<Object?> get props => [accountId, customFields];
}

class MultipleCustomFieldsCreationFailure extends AccountsState {
  final String message;
  final String accountId;
  final List<Map<String, String>> customFields;

  const MultipleCustomFieldsCreationFailure(
    this.message,
    this.accountId,
    this.customFields,
  );

  @override
  List<Object?> get props => [message, accountId, customFields];
}

class CustomFieldUpdating extends AccountsState {
  final String accountId;
  final String customFieldId;
  final String name;
  final String value;

  const CustomFieldUpdating(
    this.accountId,
    this.customFieldId,
    this.name,
    this.value,
  );

  @override
  List<Object?> get props => [accountId, customFieldId, name, value];
}

class CustomFieldUpdated extends AccountsState {
  final String accountId;
  final AccountCustomField customField;

  const CustomFieldUpdated(this.accountId, this.customField);

  @override
  List<Object?> get props => [accountId, customField];
}

class CustomFieldUpdateFailure extends AccountsState {
  final String message;
  final String accountId;
  final String customFieldId;
  final String name;
  final String value;

  const CustomFieldUpdateFailure(
    this.message,
    this.accountId,
    this.customFieldId,
    this.name,
    this.value,
  );

  @override
  List<Object?> get props => [message, accountId, customFieldId, name, value];
}

class MultipleCustomFieldsUpdating extends AccountsState {
  final String accountId;
  final List<Map<String, dynamic>> customFields;

  const MultipleCustomFieldsUpdating(this.accountId, this.customFields);

  @override
  List<Object?> get props => [accountId, customFields];
}

class MultipleCustomFieldsUpdated extends AccountsState {
  final String accountId;
  final List<AccountCustomField> customFields;

  const MultipleCustomFieldsUpdated(this.accountId, this.customFields);

  @override
  List<Object?> get props => [accountId, customFields];
}

class MultipleCustomFieldsUpdateFailure extends AccountsState {
  final String message;
  final String accountId;
  final List<Map<String, dynamic>> customFields;

  const MultipleCustomFieldsUpdateFailure(
    this.message,
    this.accountId,
    this.customFields,
  );

  @override
  List<Object?> get props => [message, accountId, customFields];
}

class CustomFieldDeleting extends AccountsState {
  final String accountId;
  final String customFieldId;

  const CustomFieldDeleting(this.accountId, this.customFieldId);

  @override
  List<Object?> get props => [accountId, customFieldId];
}

class CustomFieldDeleted extends AccountsState {
  final String accountId;
  final String customFieldId;

  const CustomFieldDeleted(this.accountId, this.customFieldId);

  @override
  List<Object?> get props => [accountId, customFieldId];
}

class CustomFieldDeletionFailure extends AccountsState {
  final String message;
  final String accountId;
  final String customFieldId;

  const CustomFieldDeletionFailure(
    this.message,
    this.accountId,
    this.customFieldId,
  );

  @override
  List<Object?> get props => [message, accountId, customFieldId];
}

class MultipleCustomFieldsDeleting extends AccountsState {
  final String accountId;
  final List<String> customFieldIds;

  const MultipleCustomFieldsDeleting(this.accountId, this.customFieldIds);

  @override
  List<Object?> get props => [accountId, customFieldIds];
}

class MultipleCustomFieldsDeleted extends AccountsState {
  final String accountId;
  final List<String> customFieldIds;

  const MultipleCustomFieldsDeleted(this.accountId, this.customFieldIds);

  @override
  List<Object?> get props => [accountId, customFieldIds];
}

class MultipleCustomFieldsDeletionFailure extends AccountsState {
  final String message;
  final String accountId;
  final List<String> customFieldIds;

  const MultipleCustomFieldsDeletionFailure(
    this.message,
    this.accountId,
    this.customFieldIds,
  );

  @override
  List<Object?> get props => [message, accountId, customFieldIds];
}

class AccountEmailsLoading extends AccountsState {
  final String accountId;

  const AccountEmailsLoading(this.accountId);

  @override
  List<Object?> get props => [accountId];
}

class AccountEmailsLoaded extends AccountsState {
  final String accountId;
  final List<AccountEmail> emails;

  const AccountEmailsLoaded(this.accountId, this.emails);

  @override
  List<Object?> get props => [accountId, emails];
}

class AccountEmailsFailure extends AccountsState {
  final String message;
  final String accountId;

  const AccountEmailsFailure(this.message, this.accountId);

  @override
  List<Object?> get props => [message, accountId];
}

class AccountEmailCreating extends AccountsState {
  final String accountId;
  final String email;

  const AccountEmailCreating(this.accountId, this.email);

  @override
  List<Object?> get props => [accountId, email];
}

class AccountEmailCreated extends AccountsState {
  final String accountId;
  final AccountEmail email;

  const AccountEmailCreated(this.accountId, this.email);

  @override
  List<Object?> get props => [accountId, email];
}

class AccountEmailCreationFailure extends AccountsState {
  final String message;
  final String accountId;
  final String email;

  const AccountEmailCreationFailure(this.message, this.accountId, this.email);

  @override
  List<Object?> get props => [message, accountId, email];
}

class AccountEmailUpdating extends AccountsState {
  final String accountId;
  final String emailId;
  final String email;

  const AccountEmailUpdating(this.accountId, this.emailId, this.email);

  @override
  List<Object?> get props => [accountId, emailId, email];
}

class AccountEmailUpdated extends AccountsState {
  final String accountId;
  final AccountEmail email;

  const AccountEmailUpdated(this.accountId, this.email);

  @override
  List<Object?> get props => [accountId, email];
}

class AccountEmailUpdateFailure extends AccountsState {
  final String message;
  final String accountId;
  final String emailId;
  final String email;

  const AccountEmailUpdateFailure(
    this.message,
    this.accountId,
    this.emailId,
    this.email,
  );

  @override
  List<Object?> get props => [message, accountId, emailId, email];
}

class AccountEmailDeleting extends AccountsState {
  final String accountId;
  final String emailId;

  const AccountEmailDeleting(this.accountId, this.emailId);

  @override
  List<Object?> get props => [accountId, emailId];
}

class AccountEmailDeleted extends AccountsState {
  final String accountId;
  final String emailId;

  const AccountEmailDeleted(this.accountId, this.emailId);

  @override
  List<Object?> get props => [accountId, emailId];
}

class AccountEmailDeletionFailure extends AccountsState {
  final String message;
  final String accountId;
  final String emailId;

  const AccountEmailDeletionFailure(this.message, this.accountId, this.emailId);

  @override
  List<Object?> get props => [message, accountId, emailId];
}

class AccountBlockingStatesLoading extends AccountsState {
  final String accountId;

  const AccountBlockingStatesLoading(this.accountId);

  @override
  List<Object?> get props => [accountId];
}

class AccountBlockingStatesLoaded extends AccountsState {
  final String accountId;
  final List<AccountBlockingState> blockingStates;

  const AccountBlockingStatesLoaded(this.accountId, this.blockingStates);

  @override
  List<Object?> get props => [accountId, blockingStates];
}

class AccountBlockingStatesFailure extends AccountsState {
  final String message;
  final String accountId;

  const AccountBlockingStatesFailure(this.message, this.accountId);

  @override
  List<Object?> get props => [message, accountId];
}

class AccountInvoicePaymentsLoading extends AccountsState {
  final String accountId;

  const AccountInvoicePaymentsLoading(this.accountId);

  @override
  List<Object?> get props => [accountId];
}

class AccountInvoicePaymentsLoaded extends AccountsState {
  final String accountId;
  final List<AccountInvoicePayment> invoicePayments;

  const AccountInvoicePaymentsLoaded(this.accountId, this.invoicePayments);

  @override
  List<Object?> get props => [accountId, invoicePayments];
}

class AccountInvoicePaymentsFailure extends AccountsState {
  final String message;
  final String accountId;

  const AccountInvoicePaymentsFailure(this.message, this.accountId);

  @override
  List<Object?> get props => [message, accountId];
}

class CreatingInvoicePayment extends AccountsState {
  final String accountId;

  const CreatingInvoicePayment(this.accountId);

  @override
  List<Object?> get props => [accountId];
}

class InvoicePaymentCreated extends AccountsState {
  final String accountId;
  final AccountInvoicePayment invoicePayment;

  const InvoicePaymentCreated(this.accountId, this.invoicePayment);

  @override
  List<Object?> get props => [accountId, invoicePayment];
}

class CreateInvoicePaymentFailure extends AccountsState {
  final String message;
  final String accountId;

  const CreateInvoicePaymentFailure(this.message, this.accountId);

  @override
  List<Object?> get props => [message, accountId];
}

class AccountAuditLogsLoading extends AccountsState {
  final String accountId;

  const AccountAuditLogsLoading(this.accountId);

  @override
  List<Object?> get props => [accountId];
}

class AccountAuditLogsLoaded extends AccountsState {
  final String accountId;
  final List<AccountAuditLog> auditLogs;

  const AccountAuditLogsLoaded(this.accountId, this.auditLogs);

  @override
  List<Object?> get props => [accountId, auditLogs];
}

class AccountAuditLogsFailure extends AccountsState {
  final String message;
  final String accountId;

  const AccountAuditLogsFailure(this.message, this.accountId);

  @override
  List<Object?> get props => [message, accountId];
}

class AccountPaymentMethodsLoading extends AccountsState {
  final String accountId;

  const AccountPaymentMethodsLoading(this.accountId);

  @override
  List<Object?> get props => [accountId];
}

class AccountPaymentMethodsLoaded extends AccountsState {
  final String accountId;
  final List<AccountPaymentMethod> paymentMethods;

  const AccountPaymentMethodsLoaded(this.accountId, this.paymentMethods);

  @override
  List<Object?> get props => [accountId, paymentMethods];
}

class AccountPaymentMethodsFailure extends AccountsState {
  final String message;
  final String accountId;

  const AccountPaymentMethodsFailure(this.message, this.accountId);

  @override
  List<Object?> get props => [message, accountId];
}

class SettingDefaultPaymentMethod extends AccountsState {
  final String accountId;
  final String paymentMethodId;

  const SettingDefaultPaymentMethod(this.accountId, this.paymentMethodId);

  @override
  List<Object?> get props => [accountId, paymentMethodId];
}

class DefaultPaymentMethodSet extends AccountsState {
  final String accountId;
  final AccountPaymentMethod paymentMethod;

  const DefaultPaymentMethodSet(this.accountId, this.paymentMethod);

  @override
  List<Object?> get props => [accountId, paymentMethod];
}

class SetDefaultPaymentMethodFailure extends AccountsState {
  final String message;
  final String accountId;
  final String paymentMethodId;

  const SetDefaultPaymentMethodFailure(this.message, this.accountId, this.paymentMethodId);

  @override
  List<Object?> get props => [message, accountId, paymentMethodId];
}

class RefreshingPaymentMethods extends AccountsState {
  final String accountId;

  const RefreshingPaymentMethods(this.accountId);

  @override
  List<Object?> get props => [accountId];
}

class PaymentMethodsRefreshed extends AccountsState {
  final String accountId;
  final List<AccountPaymentMethod> paymentMethods;

  const PaymentMethodsRefreshed(this.accountId, this.paymentMethods);

  @override
  List<Object?> get props => [accountId, paymentMethods];
}

class RefreshPaymentMethodsFailure extends AccountsState {
  final String message;
  final String accountId;

  const RefreshPaymentMethodsFailure(this.message, this.accountId);

  @override
  List<Object?> get props => [message, accountId];
}

class AccountPaymentsLoading extends AccountsState {
  final String accountId;

  const AccountPaymentsLoading(this.accountId);

  @override
  List<Object?> get props => [accountId];
}

class AccountPaymentsLoaded extends AccountsState {
  final String accountId;
  final List<AccountPayment> payments;

  const AccountPaymentsLoaded(this.accountId, this.payments);

  @override
  List<Object?> get props => [accountId, payments];
}

class AccountPaymentsFailure extends AccountsState {
  final String message;
  final String accountId;

  const AccountPaymentsFailure(this.message, this.accountId);

  @override
  List<Object?> get props => [message, accountId];
}
