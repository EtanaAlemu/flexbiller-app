import 'package:equatable/equatable.dart';
import '../../../domain/entities/account_tag.dart';

abstract class AccountTagsState extends Equatable {
  final String accountId;

  const AccountTagsState(this.accountId);

  @override
  List<Object> get props => [accountId];
}

class AccountTagsInitial extends AccountTagsState {
  const AccountTagsInitial(String accountId) : super(accountId);
}

class AccountTagsLoading extends AccountTagsState {
  const AccountTagsLoading(String accountId) : super(accountId);
}

class AccountTagsLoaded extends AccountTagsState {
  final List<AccountTagAssignment> tags;

  const AccountTagsLoaded({required String accountId, required this.tags})
    : super(accountId);

  @override
  List<Object> get props => [accountId, tags];
}

class AccountTagsFailure extends AccountTagsState {
  final String message;

  const AccountTagsFailure({required String accountId, required this.message})
    : super(accountId);

  @override
  List<Object> get props => [accountId, message];
}

class AllTagsForAccountLoading extends AccountTagsState {
  const AllTagsForAccountLoading(String accountId) : super(accountId);
}

class AllTagsForAccountLoaded extends AccountTagsState {
  final List<AccountTag> allTags;

  const AllTagsForAccountLoaded({
    required String accountId,
    required this.allTags,
  }) : super(accountId);

  @override
  List<Object> get props => [accountId, allTags];
}

class AllTagsForAccountFailure extends AccountTagsState {
  final String message;

  const AllTagsForAccountFailure({
    required String accountId,
    required this.message,
  }) : super(accountId);

  @override
  List<Object> get props => [accountId, message];
}

class CreatingTag extends AccountTagsState {
  const CreatingTag(String accountId) : super(accountId);
}

class TagCreated extends AccountTagsState {
  final AccountTag tag;

  const TagCreated({required String accountId, required this.tag})
    : super(accountId);

  @override
  List<Object> get props => [accountId, tag];
}

class TagCreationFailure extends AccountTagsState {
  final String message;

  const TagCreationFailure({required String accountId, required this.message})
    : super(accountId);

  @override
  List<Object> get props => [accountId, message];
}

class UpdatingTag extends AccountTagsState {
  final String tagId;

  const UpdatingTag({required String accountId, required this.tagId})
    : super(accountId);

  @override
  List<Object> get props => [accountId, tagId];
}

class TagUpdated extends AccountTagsState {
  final AccountTag tag;

  const TagUpdated({required String accountId, required this.tag})
    : super(accountId);

  @override
  List<Object> get props => [accountId, tag];
}

class TagUpdateFailure extends AccountTagsState {
  final String tagId;
  final String message;

  const TagUpdateFailure({
    required String accountId,
    required this.tagId,
    required this.message,
  }) : super(accountId);

  @override
  List<Object> get props => [accountId, tagId, message];
}

class DeletingTag extends AccountTagsState {
  final String tagId;

  const DeletingTag({required String accountId, required this.tagId})
    : super(accountId);

  @override
  List<Object> get props => [accountId, tagId];
}

class TagDeleted extends AccountTagsState {
  final String tagId;

  const TagDeleted({required String accountId, required this.tagId})
    : super(accountId);

  @override
  List<Object> get props => [accountId, tagId];
}

class TagDeletionFailure extends AccountTagsState {
  final String tagId;
  final String message;

  const TagDeletionFailure({
    required String accountId,
    required this.tagId,
    required this.message,
  }) : super(accountId);

  @override
  List<Object> get props => [accountId, tagId, message];
}

class AssigningTag extends AccountTagsState {
  final String tagId;

  const AssigningTag({required String accountId, required this.tagId})
    : super(accountId);

  @override
  List<Object> get props => [accountId, tagId];
}

class TagAssigned extends AccountTagsState {
  final AccountTagAssignment tagAssignment;

  const TagAssigned({required String accountId, required this.tagAssignment})
    : super(accountId);

  @override
  List<Object> get props => [accountId, tagAssignment];
}

class TagAssignmentFailure extends AccountTagsState {
  final String tagId;
  final String message;

  const TagAssignmentFailure({
    required String accountId,
    required this.tagId,
    required this.message,
  }) : super(accountId);

  @override
  List<Object> get props => [accountId, tagId, message];
}

class AssigningMultipleTags extends AccountTagsState {
  final List<String> tagIds;

  const AssigningMultipleTags({required String accountId, required this.tagIds})
    : super(accountId);

  @override
  List<Object> get props => [accountId, tagIds];
}

class MultipleTagsAssigned extends AccountTagsState {
  final List<AccountTagAssignment> tagAssignments;

  const MultipleTagsAssigned({
    required String accountId,
    required this.tagAssignments,
  }) : super(accountId);

  @override
  List<Object> get props => [accountId, tagAssignments];
}

class MultipleTagsAssignmentFailure extends AccountTagsState {
  final List<String> tagIds;
  final String message;

  const MultipleTagsAssignmentFailure({
    required String accountId,
    required this.tagIds,
    required this.message,
  }) : super(accountId);

  @override
  List<Object> get props => [accountId, tagIds, message];
}

class RemovingTag extends AccountTagsState {
  final String tagId;

  const RemovingTag({required String accountId, required this.tagId})
    : super(accountId);

  @override
  List<Object> get props => [accountId, tagId];
}

class TagRemoved extends AccountTagsState {
  final String tagId;

  const TagRemoved({required String accountId, required this.tagId})
    : super(accountId);

  @override
  List<Object> get props => [accountId, tagId];
}

class TagRemovalFailure extends AccountTagsState {
  final String tagId;
  final String message;

  const TagRemovalFailure({
    required String accountId,
    required this.tagId,
    required this.message,
  }) : super(accountId);

  @override
  List<Object> get props => [accountId, tagId, message];
}

class RemovingMultipleTags extends AccountTagsState {
  final List<String> tagIds;

  const RemovingMultipleTags({required String accountId, required this.tagIds})
    : super(accountId);

  @override
  List<Object> get props => [accountId, tagIds];
}

class MultipleTagsRemoved extends AccountTagsState {
  final List<String> tagIds;

  const MultipleTagsRemoved({required String accountId, required this.tagIds})
    : super(accountId);

  @override
  List<Object> get props => [accountId, tagIds];
}

class MultipleTagsRemovalFailure extends AccountTagsState {
  final List<String> tagIds;
  final String message;

  const MultipleTagsRemovalFailure({
    required String accountId,
    required this.tagIds,
    required this.message,
  }) : super(accountId);

  @override
  List<Object> get props => [accountId, tagIds, message];
}

class SyncingAccountTags extends AccountTagsState {
  const SyncingAccountTags(String accountId) : super(accountId);
}

class AccountTagsSynced extends AccountTagsState {
  final List<AccountTagAssignment> tags;

  const AccountTagsSynced({required String accountId, required this.tags})
    : super(accountId);

  @override
  List<Object> get props => [accountId, tags];
}

class AccountTagsSyncFailure extends AccountTagsState {
  final String message;

  const AccountTagsSyncFailure({
    required String accountId,
    required this.message,
  }) : super(accountId);

  @override
  List<Object> get props => [accountId, message];
}

