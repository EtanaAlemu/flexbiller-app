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
