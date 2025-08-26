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
