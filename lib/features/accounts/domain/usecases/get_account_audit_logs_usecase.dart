import 'package:injectable/injectable.dart';
import '../entities/account_audit_log.dart';
import '../repositories/account_audit_logs_repository.dart';

@injectable
class GetAccountAuditLogsUseCase {
  final AccountAuditLogsRepository _auditLogsRepository;

  GetAccountAuditLogsUseCase(this._auditLogsRepository);

  Future<List<AccountAuditLog>> call(String accountId) async {
    return await _auditLogsRepository.getAccountAuditLogs(accountId);
  }
}
