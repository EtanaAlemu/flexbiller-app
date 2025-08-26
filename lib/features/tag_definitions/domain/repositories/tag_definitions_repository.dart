import '../entities/tag_definition.dart';

abstract class TagDefinitionsRepository {
  Future<List<TagDefinition>> getTagDefinitions();
  Future<TagDefinition> createTagDefinition({
    required String name,
    required String description,
    required bool isControlTag,
    required List<String> applicableObjectTypes,
  });
}
