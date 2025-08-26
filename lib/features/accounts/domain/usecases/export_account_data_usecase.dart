import 'package:injectable/injectable.dart';
import '../entities/account_export.dart';
import '../repositories/account_export_repository.dart';

@injectable
class ExportAccountDataUseCase {
  final AccountExportRepository _exportRepository;

  ExportAccountDataUseCase(this._exportRepository);

  Future<AccountExport> call(String accountId, {String? format}) async {
    return await _exportRepository.exportAccountData(accountId, format: format);
  }
}
