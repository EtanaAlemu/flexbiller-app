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
  List<Object?> get props => [
    name,
    description,
    isControlTag,
    applicableObjectTypes,
  ];
}

class GetTagDefinitionById extends TagDefinitionsEvent {
  final String id;

  const GetTagDefinitionById(this.id);

  @override
  List<Object?> get props => [id];
}

class GetTagDefinitionAuditLogsWithHistory extends TagDefinitionsEvent {
  final String id;

  const GetTagDefinitionAuditLogsWithHistory(this.id);

  @override
  List<Object?> get props => [id];
}

class DeleteTagDefinition extends TagDefinitionsEvent {
  final String id;

  const DeleteTagDefinition(this.id);

  @override
  List<Object?> get props => [id];
}

// Multi-select events
class EnableMultiSelectMode extends TagDefinitionsEvent {}

class DisableMultiSelectMode extends TagDefinitionsEvent {}

class EnableMultiSelectModeAndSelect extends TagDefinitionsEvent {
  final dynamic tagDefinition;
  const EnableMultiSelectModeAndSelect(this.tagDefinition);
  @override
  List<Object?> get props => [tagDefinition];
}

class SelectTagDefinition extends TagDefinitionsEvent {
  final dynamic tagDefinition;
  const SelectTagDefinition(this.tagDefinition);
  @override
  List<Object?> get props => [tagDefinition];
}

class DeselectTagDefinition extends TagDefinitionsEvent {
  final dynamic tagDefinition;
  const DeselectTagDefinition(this.tagDefinition);
  @override
  List<Object?> get props => [tagDefinition];
}

class SelectAllTagDefinitions extends TagDefinitionsEvent {}

class DeselectAllTagDefinitions extends TagDefinitionsEvent {}

class ExportSelectedTagDefinitions extends TagDefinitionsEvent {
  final String format;

  const ExportSelectedTagDefinitions(this.format);

  @override
  List<Object?> get props => [format];
}

class DeleteSelectedTagDefinitions extends TagDefinitionsEvent {}

class SearchTagDefinitions extends TagDefinitionsEvent {
  final String searchQuery;

  const SearchTagDefinitions(this.searchQuery);

  @override
  List<Object?> get props => [searchQuery];
}
