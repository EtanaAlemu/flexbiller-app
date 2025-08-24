import 'package:equatable/equatable.dart';
import '../../domain/entities/account.dart';
import '../../domain/entities/account_timeline.dart';
import '../../domain/entities/account_tag.dart';
import '../../domain/entities/account_custom_field.dart';

abstract class AccountsState extends Equatable {
  const AccountsState();

  @override
  List<Object?> get props => [];
}

class AccountsInitial extends AccountsState {}

class AccountsLoading extends AccountsState {}

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
  final List<Account> accounts;
  final String query;

  const AccountsSearching(this.accounts, this.query);

  @override
  List<Object?> get props => [accounts, query];
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
