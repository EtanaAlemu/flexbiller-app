import '../entities/tag.dart';

abstract class TagsRepository {
  Future<List<Tag>> getAllTags();
}
