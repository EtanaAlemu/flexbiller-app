import '../entities/tag_definition.dart';
import '../entities/tag_definition_audit_log.dart';

abstract class TagDefinitionsRepository {
  Future<List<TagDefinition>> getTagDefinitions();
  Future<TagDefinition> createTagDefinition({
    required String name,
    required String description,
    required bool isControlTag,
    required List<String> applicableObjectTypes,
  });
  Future<TagDefinition> getTagDefinitionById(String id);
  Future<List<TagDefinitionAuditLog>> getTagDefinitionAuditLogsWithHistory(String id);
  Future<void> deleteTagDefinition(String id);
}
