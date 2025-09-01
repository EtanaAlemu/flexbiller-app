import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import '../../../../../core/services/database_service.dart';
import '../../../../../core/dao/account_email_dao.dart';
import '../../models/account_email_model.dart';

abstract class AccountEmailsLocalDataSource {
  Future<void> cacheAccountEmails(
    String accountId,
    List<AccountEmailModel> accountEmails,
  );
  Future<void> cacheAccountEmail(AccountEmailModel accountEmail);
  Future<List<AccountEmailModel>> getCachedAccountEmails(String accountId);
  Future<AccountEmailModel?> getCachedAccountEmail(
    String accountId,
    String email,
  );
  Future<List<AccountEmailModel>> getAllCachedAccountEmails();
  Future<List<AccountEmailModel>> searchCachedEmailsByAddress(
    String emailAddress,
  );
  Future<List<AccountEmailModel>> getCachedEmailsByDomain(String domain);
  Future<void> updateCachedAccountEmail(AccountEmailModel accountEmail);
  Future<void> deleteCachedAccountEmail(String accountId, String email);
  Future<void> deleteCachedAccountEmails(String accountId);
  Future<void> clearAllCachedAccountEmails();
  Future<int> getCachedAccountEmailsCount(String accountId);
  Future<int> getTotalCachedAccountEmailsCount();
  Future<bool> hasCachedAccountEmails(String accountId);
}

@Injectable(as: AccountEmailsLocalDataSource)
class AccountEmailsLocalDataSourceImpl implements AccountEmailsLocalDataSource {
  final DatabaseService _databaseService;
  final Logger _logger;

  AccountEmailsLocalDataSourceImpl(this._databaseService, this._logger);

  @override
  Future<void> cacheAccountEmails(
    String accountId,
    List<AccountEmailModel> accountEmails,
  ) async {
    try {
      final db = await _databaseService.database;
      await AccountEmailDao.insertMultiple(db, accountEmails);
      _logger.d(
        'Cached ${accountEmails.length} account emails for account: $accountId',
      );
    } catch (e) {
      _logger.e('Error caching account emails for account $accountId: $e');
      rethrow;
    }
  }

  @override
  Future<void> cacheAccountEmail(AccountEmailModel accountEmail) async {
    try {
      final db = await _databaseService.database;
      await AccountEmailDao.insertOrUpdate(db, accountEmail);
      _logger.d(
        'Cached account email: ${accountEmail.email} for account: ${accountEmail.accountId}',
      );
    } catch (e) {
      _logger.e('Error caching account email ${accountEmail.email}: $e');
      rethrow;
    }
  }

  @override
  Future<List<AccountEmailModel>> getCachedAccountEmails(
    String accountId,
  ) async {
    try {
      final db = await _databaseService.database;
      final accountEmails = await AccountEmailDao.getByAccountId(db, accountId);
      _logger.d(
        'Retrieved ${accountEmails.length} cached account emails for account: $accountId',
      );
      return accountEmails;
    } catch (e) {
      _logger.e(
        'Error retrieving cached account emails for account $accountId: $e',
      );
      rethrow;
    }
  }

  @override
  Future<AccountEmailModel?> getCachedAccountEmail(
    String accountId,
    String email,
  ) async {
    try {
      final db = await _databaseService.database;
      final accountEmail = await AccountEmailDao.getByAccountIdAndEmail(
        db,
        accountId,
        email,
      );
      if (accountEmail != null) {
        _logger.d(
          'Retrieved cached account email: $email for account: $accountId',
        );
      } else {
        _logger.d(
          'No cached account email found: $email for account: $accountId',
        );
      }
      return accountEmail;
    } catch (e) {
      _logger.e(
        'Error retrieving cached account email $email for account $accountId: $e',
      );
      rethrow;
    }
  }

  @override
  Future<List<AccountEmailModel>> getAllCachedAccountEmails() async {
    try {
      final db = await _databaseService.database;
      final accountEmails = await AccountEmailDao.getAll(db);
      _logger.d(
        'Retrieved ${accountEmails.length} total cached account emails',
      );
      return accountEmails;
    } catch (e) {
      _logger.e('Error retrieving all cached account emails: $e');
      rethrow;
    }
  }

  @override
  Future<List<AccountEmailModel>> searchCachedEmailsByAddress(
    String emailAddress,
  ) async {
    try {
      final db = await _databaseService.database;
      final accountEmails = await AccountEmailDao.searchByEmail(
        db,
        emailAddress,
      );
      _logger.d(
        'Searched cached account emails by address: $emailAddress, found ${accountEmails.length} results',
      );
      return accountEmails;
    } catch (e) {
      _logger.e(
        'Error searching cached account emails by address $emailAddress: $e',
      );
      rethrow;
    }
  }

  @override
  Future<List<AccountEmailModel>> getCachedEmailsByDomain(String domain) async {
    try {
      final db = await _databaseService.database;
      final accountEmails = await AccountEmailDao.getByDomain(db, domain);
      _logger.d(
        'Retrieved cached account emails by domain: $domain, found ${accountEmails.length} results',
      );
      return accountEmails;
    } catch (e) {
      _logger.e('Error retrieving cached account emails by domain $domain: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateCachedAccountEmail(AccountEmailModel accountEmail) async {
    try {
      final db = await _databaseService.database;
      await AccountEmailDao.update(db, accountEmail);
      _logger.d(
        'Updated cached account email: ${accountEmail.email} for account: ${accountEmail.accountId}',
      );
    } catch (e) {
      _logger.e(
        'Error updating cached account email ${accountEmail.email}: $e',
      );
      rethrow;
    }
  }

  @override
  Future<void> deleteCachedAccountEmail(String accountId, String email) async {
    try {
      final db = await _databaseService.database;
      await AccountEmailDao.deleteByAccountIdAndEmail(db, accountId, email);
      _logger.d('Deleted cached account email: $email for account: $accountId');
    } catch (e) {
      _logger.e(
        'Error deleting cached account email $email for account $accountId: $e',
      );
      rethrow;
    }
  }

  @override
  Future<void> deleteCachedAccountEmails(String accountId) async {
    try {
      final db = await _databaseService.database;
      await AccountEmailDao.deleteByAccountId(db, accountId);
      _logger.d('Deleted all cached account emails for account: $accountId');
    } catch (e) {
      _logger.e(
        'Error deleting cached account emails for account $accountId: $e',
      );
      rethrow;
    }
  }

  @override
  Future<void> clearAllCachedAccountEmails() async {
    try {
      final db = await _databaseService.database;
      await AccountEmailDao.deleteAll(db);
      _logger.d('Cleared all cached account emails');
    } catch (e) {
      _logger.e('Error clearing all cached account emails: $e');
      rethrow;
    }
  }

  @override
  Future<int> getCachedAccountEmailsCount(String accountId) async {
    try {
      final db = await _databaseService.database;
      final count = await AccountEmailDao.getCountByAccountId(db, accountId);
      _logger.d(
        'Retrieved cached account emails count for account $accountId: $count',
      );
      return count;
    } catch (e) {
      _logger.e(
        'Error retrieving cached account emails count for account $accountId: $e',
      );
      rethrow;
    }
  }

  @override
  Future<int> getTotalCachedAccountEmailsCount() async {
    try {
      final db = await _databaseService.database;
      final count = await AccountEmailDao.getTotalCount(db);
      _logger.d('Retrieved total cached account emails count: $count');
      return count;
    } catch (e) {
      _logger.e('Error retrieving total cached account emails count: $e');
      rethrow;
    }
  }

  @override
  Future<bool> hasCachedAccountEmails(String accountId) async {
    try {
      final count = await getCachedAccountEmailsCount(accountId);
      final hasEmails = count > 0;
      _logger.d('Account $accountId has cached emails: $hasEmails');
      return hasEmails;
    } catch (e) {
      _logger.e('Error checking if account $accountId has cached emails: $e');
      rethrow;
    }
  }
}
