import 'dart:async';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import '../../../../../core/network/network_info.dart';
import '../../domain/entities/account_email.dart';
import '../../domain/repositories/account_emails_repository.dart';
import '../datasources/local/account_emails_local_data_source.dart';
import '../datasources/remote/account_emails_remote_data_source.dart';
import '../models/account_email_model.dart';

@Injectable(as: AccountEmailsRepository)
class AccountEmailsRepositoryImpl implements AccountEmailsRepository {
  final AccountEmailsRemoteDataSource _remoteDataSource;
  final AccountEmailsLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;
  final Logger _logger;

  // Stream controllers for reactive UI updates
  final StreamController<List<AccountEmail>> _accountEmailsController =
      StreamController<List<AccountEmail>>.broadcast();

  AccountEmailsRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
    this._networkInfo,
    this._logger,
  );

  @override
  Stream<List<AccountEmail>> get accountEmailsStream =>
      _accountEmailsController.stream;

  @override
  Future<List<AccountEmail>> getAccountEmails(String accountId) async {
    try {
      // First, get data from local cache (immediate response)
      final cachedEmails = await _localDataSource.getCachedAccountEmails(
        accountId,
      );

      // Emit cached data immediately for UI responsiveness
      if (cachedEmails.isNotEmpty) {
        final entities = cachedEmails.map((model) => model.toEntity()).toList();
        _accountEmailsController.add(entities);
        _logger.d(
          'Emitted ${entities.length} cached emails for account: $accountId',
        );
      }

      // Check if device is online for background synchronization
      if (await _networkInfo.isConnected) {
        try {
          // Fetch fresh data from remote source
          final remoteEmails = await _remoteDataSource.getAccountEmails(
            accountId,
          );

          // Cache the fresh data locally
          await _localDataSource.cacheAccountEmails(accountId, remoteEmails);
          _logger.d(
            'Cached ${remoteEmails.length} fresh emails for account: $accountId',
          );

          // Emit updated data for UI refresh
          final updatedEntities = remoteEmails
              .map((model) => model.toEntity())
              .toList();
          _accountEmailsController.add(updatedEntities);
          _logger.d(
            'Emitted ${updatedEntities.length} fresh emails for account: $accountId',
          );

          return updatedEntities;
        } catch (e) {
          _logger.w('Remote fetch failed for account $accountId: $e');
          // Return cached data if remote fetch fails
          if (cachedEmails.isNotEmpty) {
            return cachedEmails.map((model) => model.toEntity()).toList();
          }
          rethrow;
        }
      } else {
        _logger.d(
          'Device offline, returning cached emails for account: $accountId',
        );
        // Return cached data if offline
        if (cachedEmails.isNotEmpty) {
          return cachedEmails.map((model) => model.toEntity()).toList();
        }
        // Return empty list if no cached data
        return [];
      }
    } catch (e) {
      _logger.e('Error getting account emails for account $accountId: $e');
      rethrow;
    }
  }

  @override
  Future<AccountEmail> getAccountEmail(String accountId, String emailId) async {
    try {
      // First, try to get from local cache
      final cachedEmail = await _localDataSource.getCachedAccountEmail(
        accountId,
        emailId,
      );
      if (cachedEmail != null) {
        _logger.d('Retrieved cached email: $emailId for account: $accountId');
        return cachedEmail.toEntity();
      }

      // If not in cache and online, fetch from remote
      if (await _networkInfo.isConnected) {
        try {
          final remoteEmail = await _remoteDataSource.getAccountEmail(
            accountId,
            emailId,
          );

          // Cache the email locally
          await _localDataSource.cacheAccountEmail(remoteEmail);
          _logger.d('Cached email: $emailId for account: $accountId');

          return remoteEmail.toEntity();
        } catch (e) {
          _logger.w('Remote fetch failed for email $emailId: $e');
          rethrow;
        }
      } else {
        _logger.d('Device offline and email not cached: $emailId');
        throw Exception('Email not found in cache and device is offline');
      }
    } catch (e) {
      _logger.e(
        'Error getting account email $emailId for account $accountId: $e',
      );
      rethrow;
    }
  }

  @override
  Future<AccountEmail> createAccountEmail(
    String accountId,
    String email,
  ) async {
    try {
      // Create email model
      final emailModel = AccountEmailModel(accountId: accountId, email: email);

      // Save to local cache first for immediate UI response
      await _localDataSource.cacheAccountEmail(emailModel);
      _logger.d('Cached new email locally for account: $accountId');

      // Emit updated list for UI refresh
      final updatedEmails = await _localDataSource.getCachedAccountEmails(
        accountId,
      );
      final entities = updatedEmails.map((model) => model.toEntity()).toList();
      _accountEmailsController.add(entities);

      // If online, send to remote server
      if (await _networkInfo.isConnected) {
        try {
          final remoteEmail = await _remoteDataSource.createAccountEmail(
            accountId,
            email,
          );

          // Update local cache with server response
          await _localDataSource.updateCachedAccountEmail(remoteEmail);
          _logger.d('Created email on remote server for account: $accountId');

          // Emit final updated list
          final finalEmails = await _localDataSource.getCachedAccountEmails(
            accountId,
          );
          final finalEntities = finalEmails
              .map((model) => model.toEntity())
              .toList();
          _accountEmailsController.add(finalEntities);

          return remoteEmail.toEntity();
        } catch (e) {
          _logger.w('Remote creation failed for account $accountId: $e');
          // Return locally cached email if remote creation fails
          return emailModel.toEntity();
        }
      } else {
        _logger.d(
          'Device offline, email created locally for account: $accountId',
        );
        return emailModel.toEntity();
      }
    } catch (e) {
      _logger.e('Error creating account email for account $accountId: $e');
      rethrow;
    }
  }

  @override
  Future<AccountEmail> updateAccountEmail(
    String accountId,
    String emailId,
    String email,
  ) async {
    try {
      // Get current email from cache
      final currentEmail = await _localDataSource.getCachedAccountEmail(
        accountId,
        emailId,
      );
      if (currentEmail == null) {
        throw Exception('Email not found in cache');
      }

      // Create updated email model
      final updatedEmail = AccountEmailModel(
        accountId: accountId,
        email: email,
      );

      // Update local cache first for immediate UI response
      await _localDataSource.updateCachedAccountEmail(updatedEmail);
      _logger.d('Updated email locally: $emailId for account: $accountId');

      // Emit updated list for UI refresh
      final updatedEmails = await _localDataSource.getCachedAccountEmails(
        accountId,
      );
      final entities = updatedEmails.map((model) => model.toEntity()).toList();
      _accountEmailsController.add(entities);

      // If online, send update to remote server
      if (await _networkInfo.isConnected) {
        try {
          final remoteEmail = await _remoteDataSource.updateAccountEmail(
            accountId,
            emailId,
            email,
          );

          // Update local cache with server response
          await _localDataSource.updateCachedAccountEmail(remoteEmail);
          _logger.d(
            'Updated email on remote server: $emailId for account: $accountId',
          );

          // Emit final updated list
          final finalEmails = await _localDataSource.getCachedAccountEmails(
            accountId,
          );
          final finalEntities = finalEmails
              .map((model) => model.toEntity())
              .toList();
          _accountEmailsController.add(finalEntities);

          return remoteEmail.toEntity();
        } catch (e) {
          _logger.w('Remote update failed for email $emailId: $e');
          // Return locally updated email if remote update fails
          return updatedEmail.toEntity();
        }
      } else {
        _logger.d(
          'Device offline, email updated locally: $emailId for account: $accountId',
        );
        return updatedEmail.toEntity();
      }
    } catch (e) {
      _logger.e(
        'Error updating account email $emailId for account $accountId: $e',
      );
      rethrow;
    }
  }

  @override
  Future<void> deleteAccountEmail(String accountId, String emailId) async {
    try {
      // Delete from local cache first for immediate UI response
      await _localDataSource.deleteCachedAccountEmail(accountId, emailId);
      _logger.d('Deleted email locally: $emailId for account: $accountId');

      // Emit updated list for UI refresh
      final updatedEmails = await _localDataSource.getCachedAccountEmails(
        accountId,
      );
      final entities = updatedEmails.map((model) => model.toEntity()).toList();
      _accountEmailsController.add(entities);

      // If online, delete from remote server
      if (await _networkInfo.isConnected) {
        try {
          await _remoteDataSource.deleteAccountEmail(accountId, emailId);
          _logger.d(
            'Deleted email on remote server: $emailId for account: $accountId',
          );
        } catch (e) {
          _logger.w('Remote deletion failed for email $emailId: $e');
          // Note: Email is already deleted locally, so we don't rethrow
        }
      } else {
        _logger.d(
          'Device offline, email deleted locally: $emailId for account: $accountId',
        );
      }
    } catch (e) {
      _logger.e(
        'Error deleting account email $emailId for account $accountId: $e',
      );
      rethrow;
    }
  }

  @override
  Future<List<AccountEmail>> searchEmailsByAddress(String emailAddress) async {
    try {
      // First, search in local cache
      final cachedEmails = await _localDataSource.searchCachedEmailsByAddress(
        emailAddress,
      );

      if (cachedEmails.isNotEmpty) {
        _logger.d(
          'Found ${cachedEmails.length} cached emails matching: $emailAddress',
        );
        return cachedEmails.map((model) => model.toEntity()).toList();
      }

      // If no cached results and online, search remote
      if (await _networkInfo.isConnected) {
        try {
          final remoteEmails = await _remoteDataSource.searchEmailsByAddress(
            emailAddress,
          );

          // Cache the search results locally
          for (final email in remoteEmails) {
            await _localDataSource.cacheAccountEmail(email);
          }
          _logger.d(
            'Cached ${remoteEmails.length} search results for: $emailAddress',
          );

          return remoteEmails.map((model) => model.toEntity()).toList();
        } catch (e) {
          _logger.w('Remote search failed for: $emailAddress');
          rethrow;
        }
      } else {
        _logger.d(
          'Device offline, no cached results for search: $emailAddress',
        );
        return [];
      }
    } catch (e) {
      _logger.e('Error searching emails by address: $emailAddress');
      rethrow;
    }
  }

  @override
  Future<List<AccountEmail>> getEmailsByDomain(String domain) async {
    try {
      // First, search in local cache
      final cachedEmails = await _localDataSource.getCachedEmailsByDomain(
        domain,
      );

      if (cachedEmails.isNotEmpty) {
        _logger.d(
          'Found ${cachedEmails.length} cached emails for domain: $domain',
        );
        return cachedEmails.map((model) => model.toEntity()).toList();
      }

      // If no cached results and online, fetch from remote
      if (await _networkInfo.isConnected) {
        try {
          final remoteEmails = await _remoteDataSource.getEmailsByDomain(
            domain,
          );

          // Cache the results locally
          for (final email in remoteEmails) {
            await _localDataSource.cacheAccountEmail(email);
          }
          _logger.d('Cached ${remoteEmails.length} emails for domain: $domain');

          return remoteEmails.map((model) => model.toEntity()).toList();
        } catch (e) {
          _logger.w('Remote fetch failed for domain: $domain');
          rethrow;
        }
      } else {
        _logger.d('Device offline, no cached results for domain: $domain');
        return [];
      }
    } catch (e) {
      _logger.e('Error getting emails by domain: $domain');
      rethrow;
    }
  }

  /// Dispose resources
  void dispose() {
    _accountEmailsController.close();
    _logger.d('AccountEmailsRepositoryImpl disposed');
  }
}
