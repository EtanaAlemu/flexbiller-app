import '../entities/account_export.dart';

abstract class AccountExportRepository {
  Future<AccountExport> exportAccountData(String accountId, {String? format});
}
