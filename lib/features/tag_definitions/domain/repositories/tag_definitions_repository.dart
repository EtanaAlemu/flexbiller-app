import '../entities/tag_definition.dart';

abstract class TagDefinitionsRepository {
  Future<List<TagDefinition>> getTagDefinitions();
}
