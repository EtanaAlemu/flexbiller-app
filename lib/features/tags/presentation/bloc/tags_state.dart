import 'package:equatable/equatable.dart';
import '../../domain/entities/tag.dart';

abstract class TagsState extends Equatable {
  const TagsState();

  @override
  List<Object?> get props => [];
}

class TagsInitial extends TagsState {}

class TagsLoading extends TagsState {}

class TagsLoaded extends TagsState {
  final List<Tag> tags;

  const TagsLoaded(this.tags);

  @override
  List<Object?> get props => [tags];
}

class TagsError extends TagsState {
  final String message;

  const TagsError(this.message);

  @override
  List<Object?> get props => [message];
}

class TagsSearchLoading extends TagsState {}

class TagsSearchLoaded extends TagsState {
  final List<Tag> tags;
  final String searchQuery;
  final int offset;
  final int limit;
  final String audit;

  const TagsSearchLoaded({
    required this.tags,
    required this.searchQuery,
    required this.offset,
    required this.limit,
    required this.audit,
  });

  @override
  List<Object?> get props => [tags, searchQuery, offset, limit, audit];
}

class TagsSearchError extends TagsState {
  final String message;
  final String searchQuery;

  const TagsSearchError(this.message, this.searchQuery);

  @override
  List<Object?> get props => [message, searchQuery];
}

// Selection states
class MultiSelectModeEnabled extends TagsState {
  final List<Tag> selectedTags;

  const MultiSelectModeEnabled({required this.selectedTags});

  @override
  List<Object?> get props => [selectedTags];
}

class MultiSelectModeDisabled extends TagsState {}

class TagSelected extends TagsState {
  final List<Tag> selectedTags;
  final Tag selectedTag;

  const TagSelected({required this.selectedTags, required this.selectedTag});

  @override
  List<Object?> get props => [selectedTags, selectedTag];
}

class TagDeselected extends TagsState {
  final List<Tag> selectedTags;
  final Tag deselectedTag;

  const TagDeselected({
    required this.selectedTags,
    required this.deselectedTag,
  });

  @override
  List<Object?> get props => [selectedTags, deselectedTag];
}

class AllTagsSelected extends TagsState {
  final List<Tag> selectedTags;

  const AllTagsSelected({required this.selectedTags});

  @override
  List<Object?> get props => [selectedTags];
}

class AllTagsDeselected extends TagsState {}

// Export states
class TagsExporting extends TagsState {
  final int totalTags;
  final String format;

  const TagsExporting({required this.totalTags, required this.format});

  @override
  List<Object?> get props => [totalTags, format];
}

class TagsExportSuccess extends TagsState {
  final String filePath;
  final String fileName;
  final int exportedCount;

  const TagsExportSuccess({
    required this.filePath,
    required this.fileName,
    required this.exportedCount,
  });

  @override
  List<Object?> get props => [filePath, fileName, exportedCount];
}

class TagsExportFailure extends TagsState {
  final String message;

  const TagsExportFailure(this.message);

  @override
  List<Object?> get props => [message];
}

// Delete states
class TagsDeleting extends TagsState {
  final List<Tag> tagsToDelete;

  const TagsDeleting({required this.tagsToDelete});

  @override
  List<Object?> get props => [tagsToDelete];
}

class TagsDeleteSuccess extends TagsState {
  final int deletedCount;

  const TagsDeleteSuccess({required this.deletedCount});

  @override
  List<Object?> get props => [deletedCount];
}

class TagsDeleteFailure extends TagsState {
  final String message;
  final List<Tag> tagsToDelete;

  const TagsDeleteFailure({required this.message, required this.tagsToDelete});

  @override
  List<Object?> get props => [message, tagsToDelete];
}

class TagsWithSelection extends TagsState {
  final List<Tag> tags;
  final List<Tag> selectedTags;
  final bool isMultiSelectMode;

  const TagsWithSelection({
    required this.tags,
    required this.selectedTags,
    required this.isMultiSelectMode,
  });

  @override
  List<Object?> get props => [tags, selectedTags, isMultiSelectMode];
}
