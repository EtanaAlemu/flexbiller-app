import 'package:equatable/equatable.dart';

abstract class TagsEvent extends Equatable {
  const TagsEvent();

  @override
  List<Object?> get props => [];
}

class LoadAllTags extends TagsEvent {}

class RefreshTags extends TagsEvent {}

class SearchTags extends TagsEvent {
  final String tagDefinitionName;
  final int offset;
  final int limit;
  final String audit;

  const SearchTags({
    required this.tagDefinitionName,
    this.offset = 0,
    this.limit = 100,
    this.audit = 'NONE',
  });

  @override
  List<Object?> get props => [tagDefinitionName, offset, limit, audit];
}

class ClearSearch extends TagsEvent {}
