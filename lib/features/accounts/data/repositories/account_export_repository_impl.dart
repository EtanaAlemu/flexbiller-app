import 'package:injectable/injectable.dart';
import '../../domain/entities/account_export.dart';
import '../../domain/repositories/account_export_repository.dart';
import '../datasources/remote/account_export_remote_data_source.dart';

@Injectable(as: AccountExportRepository)
class AccountExportRepositoryImpl implements AccountExportRepository {
  final AccountExportRemoteDataSource _remoteDataSource;

  AccountExportRepositoryImpl(this._remoteDataSource);

  @override
  Future<AccountExport> exportAccountData(
    String accountId, {
    String? format,
  }) async {
    try {
      final exportModel = await _remoteDataSource.exportAccountData(
        accountId,
        format: format,
      );
      return exportModel.toEntity();
    } catch (e) {
      rethrow;
    }
  }
}
