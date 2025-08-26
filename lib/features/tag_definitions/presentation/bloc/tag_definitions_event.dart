import 'package:equatable/equatable.dart';

abstract class TagDefinitionsEvent extends Equatable {
  const TagDefinitionsEvent();

  @override
  List<Object?> get props => [];
}

class LoadTagDefinitions extends TagDefinitionsEvent {}

class RefreshTagDefinitions extends TagDefinitionsEvent {}

class CreateTagDefinition extends TagDefinitionsEvent {
  final String name;
  final String description;
  final bool isControlTag;
  final List<String> applicableObjectTypes;

  const CreateTagDefinition({
    required this.name,
    required this.description,
    required this.isControlTag,
    required this.applicableObjectTypes,
  });

  @override
  List<Object?> get props => [name, description, isControlTag, applicableObjectTypes];
}

class GetTagDefinitionById extends TagDefinitionsEvent {
  final String id;

  const GetTagDefinitionById(this.id);

  @override
  List<Object?> get props => [id];
}
