import 'package:equatable/equatable.dart';
import '../../domain/entities/tag_definition.dart';

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
