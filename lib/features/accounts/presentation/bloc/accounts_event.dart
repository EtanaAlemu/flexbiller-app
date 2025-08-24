import 'package:equatable/equatable.dart';
import '../../domain/entities/accounts_query_params.dart';
import '../../domain/entities/account.dart';

abstract class AccountsEvent extends Equatable {
  const AccountsEvent();

  @override
  List<Object?> get props => [];
}

class LoadAccounts extends AccountsEvent {
  final AccountsQueryParams params;

  const LoadAccounts(this.params);

  @override
  List<Object?> get props => [params];
}

class RefreshAccounts extends AccountsEvent {
  final AccountsQueryParams params;

  const RefreshAccounts({this.params = const AccountsQueryParams()});

  @override
  List<Object?> get props => [params];
}

class LoadMoreAccounts extends AccountsEvent {
  final int offset;
  final int limit;

  const LoadMoreAccounts({required this.offset, this.limit = 20});

  @override
  List<Object?> get props => [offset, limit];
}

class SearchAccounts extends AccountsEvent {
  final String searchKey;

  const SearchAccounts(this.searchKey);

  @override
  List<Object?> get props => [searchKey];
}

class FilterAccountsByCompany extends AccountsEvent {
  final String company;

  const FilterAccountsByCompany(this.company);

  @override
  List<Object?> get props => [company];
}

class FilterAccountsByBalance extends AccountsEvent {
  final double minBalance;

  const FilterAccountsByBalance(this.minBalance);

  @override
  List<Object?> get props => [minBalance];
}

class ClearFilters extends AccountsEvent {}

class LoadAccountDetails extends AccountsEvent {
  final String accountId;

  const LoadAccountDetails(this.accountId);

  @override
  List<Object?> get props => [accountId];
}

class CreateAccount extends AccountsEvent {
  final Account account;

  const CreateAccount(this.account);

  @override
  List<Object?> get props => [account];
}

class UpdateAccount extends AccountsEvent {
  final Account account;

  const UpdateAccount(this.account);

  @override
  List<Object?> get props => [account];
}

class DeleteAccount extends AccountsEvent {
  final String accountId;

  const DeleteAccount(this.accountId);

  @override
  List<Object?> get props => [accountId];
}

class LoadAccountTimeline extends AccountsEvent {
  final String accountId;

  const LoadAccountTimeline(this.accountId);

  @override
  List<Object?> get props => [accountId];
}

class RefreshAccountTimeline extends AccountsEvent {
  final String accountId;

  const RefreshAccountTimeline(this.accountId);

  @override
  List<Object?> get props => [accountId];
}

class LoadAccountTags extends AccountsEvent {
  final String accountId;

  const LoadAccountTags(this.accountId);

  @override
  List<Object?> get props => [accountId];
}

class RefreshAccountTags extends AccountsEvent {
  final String accountId;

  const RefreshAccountTags(this.accountId);

  @override
  List<Object?> get props => [accountId];
}

class AssignTagToAccount extends AccountsEvent {
  final String accountId;
  final String tagId;

  const AssignTagToAccount(this.accountId, this.tagId);

  @override
  List<Object?> get props => [accountId, tagId];
}

class RemoveTagFromAccount extends AccountsEvent {
  final String accountId;
  final String tagId;

  const RemoveTagFromAccount(this.accountId, this.tagId);

  @override
  List<Object?> get props => [accountId, tagId];
}

class RemoveMultipleTagsFromAccount extends AccountsEvent {
  final String accountId;
  final List<String> tagIds;

  const RemoveMultipleTagsFromAccount(this.accountId, this.tagIds);

  @override
  List<Object?> get props => [accountId, tagIds];
}

class RemoveAllTagsFromAccount extends AccountsEvent {
  final String accountId;

  const RemoveAllTagsFromAccount(this.accountId);

  @override
  List<Object?> get props => [accountId];
}

class AssignMultipleTagsToAccount extends AccountsEvent {
  final String accountId;
  final List<String> tagIds;

  const AssignMultipleTagsToAccount(this.accountId, this.tagIds);

  @override
  List<Object?> get props => [accountId, tagIds];
}

class LoadAllTagsForAccount extends AccountsEvent {
  final String accountId;

  const LoadAllTagsForAccount(this.accountId);

  @override
  List<Object?> get props => [accountId];
}

class RefreshAllTagsForAccount extends AccountsEvent {
  final String accountId;

  const RefreshAllTagsForAccount(this.accountId);

  @override
  List<Object?> get props => [accountId];
}

class LoadAccountCustomFields extends AccountsEvent {
  final String accountId;

  const LoadAccountCustomFields(this.accountId);

  @override
  List<Object?> get props => [accountId];
}

class RefreshAccountCustomFields extends AccountsEvent {
  final String accountId;

  const RefreshAccountCustomFields(this.accountId);

  @override
  List<Object?> get props => [accountId];
}

class CreateAccountCustomField extends AccountsEvent {
  final String accountId;
  final String name;
  final String value;

  const CreateAccountCustomField(this.accountId, this.name, this.value);

  @override
  List<Object?> get props => [accountId, name, value];
}

class CreateMultipleAccountCustomFields extends AccountsEvent {
  final String accountId;
  final List<Map<String, String>> customFields;

  const CreateMultipleAccountCustomFields(this.accountId, this.customFields);

  @override
  List<Object?> get props => [accountId, customFields];
}

class UpdateAccountCustomField extends AccountsEvent {
  final String accountId;
  final String customFieldId;
  final String name;
  final String value;

  const UpdateAccountCustomField(this.accountId, this.customFieldId, this.name, this.value);

  @override
  List<Object?> get props => [accountId, customFieldId, name, value];
}

class UpdateMultipleAccountCustomFields extends AccountsEvent {
  final String accountId;
  final List<Map<String, dynamic>> customFields;

  const UpdateMultipleAccountCustomFields(this.accountId, this.customFields);

  @override
  List<Object?> get props => [accountId, customFields];
}

class DeleteAccountCustomField extends AccountsEvent {
  final String accountId;
  final String customFieldId;

  const DeleteAccountCustomField(this.accountId, this.customFieldId);

  @override
  List<Object?> get props => [accountId, customFieldId];
}

class DeleteMultipleAccountCustomFields extends AccountsEvent {
  final String accountId;
  final List<String> customFieldIds;

  const DeleteMultipleAccountCustomFields(this.accountId, this.customFieldIds);

  @override
  List<Object?> get props => [accountId, customFieldIds];
}

class LoadAccountEmails extends AccountsEvent {
  final String accountId;

  const LoadAccountEmails(this.accountId);

  @override
  List<Object?> get props => [accountId];
}

class RefreshAccountEmails extends AccountsEvent {
  final String accountId;

  const RefreshAccountEmails(this.accountId);

  @override
  List<Object?> get props => [accountId];
}

class CreateAccountEmail extends AccountsEvent {
  final String accountId;
  final String email;

  const CreateAccountEmail(this.accountId, this.email);

  @override
  List<Object?> get props => [accountId, email];
}

class UpdateAccountEmail extends AccountsEvent {
  final String accountId;
  final String emailId;
  final String email;

  const UpdateAccountEmail(this.accountId, this.emailId, this.email);

  @override
  List<Object?> get props => [accountId, emailId, email];
}

class DeleteAccountEmail extends AccountsEvent {
  final String accountId;
  final String emailId;

  const DeleteAccountEmail(this.accountId, this.emailId);

  @override
  List<Object?> get props => [accountId, emailId];
}

class LoadAccountBlockingStates extends AccountsEvent {
  final String accountId;

  const LoadAccountBlockingStates(this.accountId);

  @override
  List<Object?> get props => [accountId];
}

class RefreshAccountBlockingStates extends AccountsEvent {
  final String accountId;

  const RefreshAccountBlockingStates(this.accountId);

  @override
  List<Object?> get props => [accountId];
}

class LoadAccountInvoicePayments extends AccountsEvent {
  final String accountId;

  const LoadAccountInvoicePayments(this.accountId);

  @override
  List<Object?> get props => [accountId];
}

class RefreshAccountInvoicePayments extends AccountsEvent {
  final String accountId;

  const RefreshAccountInvoicePayments(this.accountId);

  @override
  List<Object?> get props => [accountId];
}

class CreateInvoicePayment extends AccountsEvent {
  final String accountId;
  final double paymentAmount;
  final String currency;
  final String paymentMethod;
  final String? notes;

  const CreateInvoicePayment({
    required this.accountId,
    required this.paymentAmount,
    required this.currency,
    required this.paymentMethod,
    this.notes,
  });

  @override
  List<Object?> get props => [accountId, paymentAmount, currency, paymentMethod, notes];
}

class LoadAccountAuditLogs extends AccountsEvent {
  final String accountId;

  const LoadAccountAuditLogs(this.accountId);

  @override
  List<Object?> get props => [accountId];
}

class RefreshAccountAuditLogs extends AccountsEvent {
  final String accountId;

  const RefreshAccountAuditLogs(this.accountId);

  @override
  List<Object?> get props => [accountId];
}

class LoadAccountPaymentMethods extends AccountsEvent {
  final String accountId;

  const LoadAccountPaymentMethods(this.accountId);

  @override
  List<Object?> get props => [accountId];
}

class RefreshAccountPaymentMethods extends AccountsEvent {
  final String accountId;

  const RefreshAccountPaymentMethods(this.accountId);

  @override
  List<Object?> get props => [accountId];
}

class SetDefaultPaymentMethod extends AccountsEvent {
  final String accountId;
  final String paymentMethodId;
  final bool payAllUnpaidInvoices;

  const SetDefaultPaymentMethod({
    required this.accountId,
    required this.paymentMethodId,
    required this.payAllUnpaidInvoices,
  });

  @override
  List<Object?> get props => [accountId, paymentMethodId, payAllUnpaidInvoices];
}
