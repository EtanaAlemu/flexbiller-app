import '../entities/tag.dart';

abstract class TagsRepository {
  Future<List<Tag>> getAllTags();
  Future<List<Tag>> searchTags(String tagDefinitionName, {int offset = 0, int limit = 100, String audit = 'NONE'});
}
