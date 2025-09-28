import 'package:equatable/equatable.dart';
import '../../domain/entities/tag.dart';

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

// Selection events
class EnableMultiSelectMode extends TagsEvent {}

class EnableMultiSelectModeAndSelect extends TagsEvent {
  final Tag tag;

  const EnableMultiSelectModeAndSelect(this.tag);

  @override
  List<Object?> get props => [tag];
}

class DisableMultiSelectMode extends TagsEvent {}

class SelectTag extends TagsEvent {
  final Tag tag;

  const SelectTag(this.tag);

  @override
  List<Object?> get props => [tag];
}

class DeselectTag extends TagsEvent {
  final Tag tag;

  const DeselectTag(this.tag);

  @override
  List<Object?> get props => [tag];
}

class SelectAllTags extends TagsEvent {
  final List<Tag> tags;

  const SelectAllTags({required this.tags});

  @override
  List<Object?> get props => [tags];
}

class DeselectAllTags extends TagsEvent {}

// Export events
class ExportAllTags extends TagsEvent {
  final String format;

  const ExportAllTags({required this.format});

  @override
  List<Object?> get props => [format];
}

class ExportSelectedTags extends TagsEvent {
  final List<Tag> tags;
  final String format;

  const ExportSelectedTags({required this.tags, required this.format});

  @override
  List<Object?> get props => [tags, format];
}

// Delete events
class DeleteSelectedTags extends TagsEvent {
  final List<Tag> tags;

  const DeleteSelectedTags({required this.tags});

  @override
  List<Object?> get props => [tags];
}

class BulkDeleteTags extends TagsEvent {
  final List<Tag> tags;

  const BulkDeleteTags({required this.tags});

  @override
  List<Object?> get props => [tags];
}
