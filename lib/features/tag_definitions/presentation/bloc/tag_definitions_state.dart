import 'package:equatable/equatable.dart';
import '../../domain/entities/tag_definition.dart';
import '../../domain/entities/tag_definition_audit_log.dart';

abstract class TagDefinitionsState extends Equatable {
  const TagDefinitionsState();

  @override
  List<Object?> get props => [];
}

class TagDefinitionsInitial extends TagDefinitionsState {}

class TagDefinitionsLoading extends TagDefinitionsState {}

class TagDefinitionsLoaded extends TagDefinitionsState {
  final List<TagDefinition> tagDefinitions;

  const TagDefinitionsLoaded(this.tagDefinitions);

  @override
  List<Object?> get props => [tagDefinitions];
}

class TagDefinitionsError extends TagDefinitionsState {
  final String message;

  const TagDefinitionsError(this.message);

  @override
  List<Object?> get props => [message];
}

class CreateTagDefinitionLoading extends TagDefinitionsState {}

class CreateTagDefinitionSuccess extends TagDefinitionsState {
  final TagDefinition tagDefinition;

  const CreateTagDefinitionSuccess(this.tagDefinition);

  @override
  List<Object?> get props => [tagDefinition];
}

class CreateTagDefinitionError extends TagDefinitionsState {
  final String message;

  const CreateTagDefinitionError(this.message);

  @override
  List<Object?> get props => [message];
}

class SingleTagDefinitionLoading extends TagDefinitionsState {}

class SingleTagDefinitionLoaded extends TagDefinitionsState {
  final TagDefinition tagDefinition;

  const SingleTagDefinitionLoaded(this.tagDefinition);

  @override
  List<Object?> get props => [tagDefinition];
}

class SingleTagDefinitionError extends TagDefinitionsState {
  final String message;
  final String id;

  const SingleTagDefinitionError(this.message, this.id);

  @override
  List<Object?> get props => [message, id];
}

class AuditLogsWithHistoryLoading extends TagDefinitionsState {}

class AuditLogsWithHistoryLoaded extends TagDefinitionsState {
  final List<TagDefinitionAuditLog> auditLogs;
  final String tagDefinitionId;

  const AuditLogsWithHistoryLoaded(this.auditLogs, this.tagDefinitionId);

  @override
  List<Object?> get props => [auditLogs, tagDefinitionId];
}

class AuditLogsWithHistoryError extends TagDefinitionsState {
  final String message;
  final String tagDefinitionId;

  const AuditLogsWithHistoryError(this.message, this.tagDefinitionId);

  @override
  List<Object?> get props => [message, tagDefinitionId];
}

class DeleteTagDefinitionLoading extends TagDefinitionsState {}

class DeleteTagDefinitionSuccess extends TagDefinitionsState {
  final String deletedId;

  const DeleteTagDefinitionSuccess(this.deletedId);

  @override
  List<Object?> get props => [deletedId];
}

class DeleteTagDefinitionError extends TagDefinitionsState {
  final String message;
  final String id;

  const DeleteTagDefinitionError(this.message, this.id);

  @override
  List<Object?> get props => [message, id];
}

// Multi-select states
class TagDefinitionsWithSelection extends TagDefinitionsState {
  final List<TagDefinition> tagDefinitions;
  final List<TagDefinition> selectedTagDefinitions;
  final bool isMultiSelectMode;

  const TagDefinitionsWithSelection({
    required this.tagDefinitions,
    required this.selectedTagDefinitions,
    required this.isMultiSelectMode,
  });

  @override
  List<Object?> get props => [
    tagDefinitions,
    selectedTagDefinitions,
    isMultiSelectMode,
  ];
}

class ExportTagDefinitionsLoading extends TagDefinitionsState {}

class ExportTagDefinitionsSuccess extends TagDefinitionsState {
  final String message;

  const ExportTagDefinitionsSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class ExportTagDefinitionsError extends TagDefinitionsState {
  final String message;

  const ExportTagDefinitionsError(this.message);

  @override
  List<Object?> get props => [message];
}

class DeleteSelectedTagDefinitionsLoading extends TagDefinitionsState {}

class DeleteSelectedTagDefinitionsSuccess extends TagDefinitionsState {
  final String message;
  final int deletedCount;

  const DeleteSelectedTagDefinitionsSuccess(this.message, this.deletedCount);

  @override
  List<Object?> get props => [message, deletedCount];
}

class DeleteSelectedTagDefinitionsError extends TagDefinitionsState {
  final String message;

  const DeleteSelectedTagDefinitionsError(this.message);

  @override
  List<Object?> get props => [message];
}

class TagDefinitionsSearching extends TagDefinitionsState {
  final String searchQuery;

  const TagDefinitionsSearching(this.searchQuery);

  @override
  List<Object?> get props => [searchQuery];
}

class TagDefinitionsSearchResults extends TagDefinitionsState {
  final List<TagDefinition> searchResults;
  final String searchQuery;

  const TagDefinitionsSearchResults(this.searchResults, this.searchQuery);

  @override
  List<Object?> get props => [searchResults, searchQuery];
}
