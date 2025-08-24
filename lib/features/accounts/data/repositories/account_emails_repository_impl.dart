import 'package:injectable/injectable.dart';
import '../../domain/entities/account_email.dart';
import '../../domain/repositories/account_emails_repository.dart';
import '../datasources/account_emails_remote_data_source.dart';

@Injectable(as: AccountEmailsRepository)
class AccountEmailsRepositoryImpl implements AccountEmailsRepository {
  final AccountEmailsRemoteDataSource _remoteDataSource;

  AccountEmailsRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<AccountEmail>> getAccountEmails(String accountId) async {
    try {
      final emailModels = await _remoteDataSource.getAccountEmails(accountId);
      return emailModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<AccountEmail> getAccountEmail(String accountId, String emailId) async {
    try {
      final emailModel = await _remoteDataSource.getAccountEmail(accountId, emailId);
      return emailModel.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<AccountEmail> createAccountEmail(String accountId, String email) async {
    try {
      final emailModel = await _remoteDataSource.createAccountEmail(accountId, email);
      return emailModel.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<AccountEmail> updateAccountEmail(String accountId, String emailId, String email) async {
    try {
      final emailModel = await _remoteDataSource.updateAccountEmail(accountId, emailId, email);
      return emailModel.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteAccountEmail(String accountId, String emailId) async {
    try {
      await _remoteDataSource.deleteAccountEmail(accountId, emailId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<AccountEmail>> searchEmailsByAddress(String emailAddress) async {
    try {
      final emailModels = await _remoteDataSource.searchEmailsByAddress(emailAddress);
      return emailModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<AccountEmail>> getEmailsByDomain(String domain) async {
    try {
      final emailModels = await _remoteDataSource.getEmailsByDomain(domain);
      return emailModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      rethrow;
    }
  }
}
