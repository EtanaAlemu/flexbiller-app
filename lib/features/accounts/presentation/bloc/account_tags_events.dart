import 'package:equatable/equatable.dart';
import '../../domain/entities/account_tag.dart';

abstract class AccountTagsEvent extends Equatable {
  final String accountId;

  const AccountTagsEvent(this.accountId);

  @override
  List<Object> get props => [accountId];
}

class LoadAccountTags extends AccountTagsEvent {
  const LoadAccountTags(String accountId) : super(accountId);
}

class RefreshAccountTags extends AccountTagsEvent {
  const RefreshAccountTags(String accountId) : super(accountId);
}

class LoadAllTagsForAccount extends AccountTagsEvent {
  const LoadAllTagsForAccount(String accountId) : super(accountId);
}

class CreateTag extends AccountTagsEvent {
  final String name;
  final String? description;
  final String? color;
  final String? icon;

  const CreateTag({
    required String accountId,
    required this.name,
    this.description,
    this.color,
    this.icon,
  }) : super(accountId);

  @override
  List<Object> get props => [
    accountId,
    name,
    description ?? '',
    color ?? '',
    icon ?? '',
  ];
}

class UpdateTag extends AccountTagsEvent {
  final String tagId;
  final String name;
  final String? description;
  final String? color;
  final String? icon;

  const UpdateTag({
    required String accountId,
    required this.tagId,
    required this.name,
    this.description,
    this.color,
    this.icon,
  }) : super(accountId);

  @override
  List<Object> get props => [
    accountId,
    tagId,
    name,
    description ?? '',
    color ?? '',
    icon ?? '',
  ];
}

class DeleteTag extends AccountTagsEvent {
  final String tagId;

  const DeleteTag({required String accountId, required this.tagId})
    : super(accountId);

  @override
  List<Object> get props => [accountId, tagId];
}

class AssignTagToAccount extends AccountTagsEvent {
  final String tagId;

  const AssignTagToAccount({required String accountId, required this.tagId})
    : super(accountId);

  @override
  List<Object> get props => [accountId, tagId];
}

class AssignMultipleTagsToAccount extends AccountTagsEvent {
  final List<String> tagIds;

  const AssignMultipleTagsToAccount({
    required String accountId,
    required this.tagIds,
  }) : super(accountId);

  @override
  List<Object> get props => [accountId, tagIds];
}

class RemoveTagFromAccount extends AccountTagsEvent {
  final String tagId;

  const RemoveTagFromAccount({required String accountId, required this.tagId})
    : super(accountId);

  @override
  List<Object> get props => [accountId, tagId];
}

class RemoveMultipleTagsFromAccount extends AccountTagsEvent {
  final List<String> tagIds;

  const RemoveMultipleTagsFromAccount({
    required String accountId,
    required this.tagIds,
  }) : super(accountId);

  @override
  List<Object> get props => [accountId, tagIds];
}

class SyncAccountTags extends AccountTagsEvent {
  const SyncAccountTags(String accountId) : super(accountId);
}

class ClearAccountTags extends AccountTagsEvent {
  const ClearAccountTags(String accountId) : super(accountId);
}
