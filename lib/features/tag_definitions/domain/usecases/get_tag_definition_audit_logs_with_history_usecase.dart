import 'package:injectable/injectable.dart';
import '../entities/tag_definition_audit_log.dart';
import '../repositories/tag_definitions_repository.dart';

@injectable
class GetTagDefinitionAuditLogsWithHistoryUseCase {
  final TagDefinitionsRepository _repository;

  GetTagDefinitionAuditLogsWithHistoryUseCase(this._repository);

  Future<List<TagDefinitionAuditLog>> call(String id) async {
    return await _repository.getTagDefinitionAuditLogsWithHistory(id);
  }
}
