import 'dart:async';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import '../../../../../core/network/network_info.dart';
import '../../domain/entities/account_invoice.dart';
import '../../domain/repositories/account_invoices_repository.dart';
import '../datasources/local/account_invoices_local_data_source.dart';
import '../datasources/remote/account_invoices_remote_data_source.dart';

@Injectable(as: AccountInvoicesRepository)
class AccountInvoicesRepositoryImpl implements AccountInvoicesRepository {
  final AccountInvoicesRemoteDataSource _remoteDataSource;
  final AccountInvoicesLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;
  final Logger _logger;

  // Stream controllers for reactive UI updates
  final StreamController<List<AccountInvoice>> _accountInvoicesController =
      StreamController<List<AccountInvoice>>.broadcast();

  AccountInvoicesRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
    this._networkInfo,
    this._logger,
  );

  @override
  Stream<List<AccountInvoice>> get accountInvoicesStream =>
      _accountInvoicesController.stream;

  @override
  Future<List<AccountInvoice>> getInvoices(String accountId) async {
    try {
      _logger.d(
        'Getting invoices for account: $accountId - Local-first approach',
      );

      // First, try to get from local cache
      final cachedInvoices = await _localDataSource.getCachedAccountInvoices(
        accountId,
      );
      if (cachedInvoices.isNotEmpty) {
        _logger.d(
          'Returning ${cachedInvoices.length} cached invoices for account $accountId',
        );

        // Emit cached data immediately for UI responsiveness
        final entities = cachedInvoices
            .map((model) => model.toEntity())
            .toList();
        _accountInvoicesController.add(entities);

        // If online, sync in background
        if (await _networkInfo.isConnected) {
          _syncInvoicesInBackground(accountId);
        }

        return entities;
      }

      // If no cached data and online, fetch from remote
      if (await _networkInfo.isConnected) {
        _logger.d(
          'No cached data, fetching invoices from remote for account $accountId',
        );
        final remoteInvoices = await _remoteDataSource.getInvoices(accountId);

        // Cache the fresh data locally
        await _localDataSource.cacheAccountInvoices(accountId, remoteInvoices);

        // Emit updated data for UI refresh
        final entities = remoteInvoices
            .map((model) => model.toEntity())
            .toList();
        _accountInvoicesController.add(entities);

        return entities;
      }

      // If offline and no cached data, return empty list
      _logger.w(
        'No cached data and offline, returning empty list for account $accountId',
      );
      return [];
    } catch (e) {
      _logger.e('Error getting invoices for account $accountId: $e');
      rethrow;
    }
  }

  @override
  Future<List<AccountInvoice>> getPaginatedInvoices(String accountId) async {
    try {
      _logger.d(
        'Getting paginated invoices for account: $accountId - Local-first approach',
      );

      // First, try to get from local cache
      final cachedInvoices = await _localDataSource.getCachedPaginatedInvoices(
        accountId,
      );
      if (cachedInvoices.isNotEmpty) {
        _logger.d(
          'Returning ${cachedInvoices.length} cached paginated invoices for account $accountId',
        );

        // If online, sync in background
        if (await _networkInfo.isConnected) {
          _syncPaginatedInvoicesInBackground(accountId);
        }

        return cachedInvoices.map((model) => model.toEntity()).toList();
      }

      // If no cached data and online, fetch from remote
      if (await _networkInfo.isConnected) {
        _logger.d(
          'No cached data, fetching paginated invoices from remote for account $accountId',
        );
        final remoteInvoices = await _remoteDataSource.getPaginatedInvoices(
          accountId,
        );

        // Cache the results locally
        await _localDataSource.cacheAccountInvoices(accountId, remoteInvoices);

        return remoteInvoices.map((model) => model.toEntity()).toList();
      }

      // If offline and no cached data, return empty list
      _logger.w(
        'No cached data and offline, returning empty list for paginated invoices, account $accountId',
      );
      return [];
    } catch (e) {
      _logger.e('Error getting paginated invoices for account $accountId: $e');
      rethrow;
    }
  }

  /// Background synchronization for invoices
  Future<void> _syncInvoicesInBackground(String accountId) async {
    try {
      _logger.d('Syncing invoices in background for account: $accountId');
      final remoteInvoices = await _remoteDataSource.getInvoices(accountId);
      await _localDataSource.cacheAccountInvoices(accountId, remoteInvoices);

      // Emit updated data for UI refresh
      final entities = remoteInvoices.map((model) => model.toEntity()).toList();
      _accountInvoicesController.add(entities);

      _logger.d('Background sync completed for invoices, account: $accountId');
    } catch (e) {
      _logger.e('Background sync failed for invoices, account $accountId: $e');
    }
  }

  /// Background synchronization for paginated invoices
  Future<void> _syncPaginatedInvoicesInBackground(String accountId) async {
    try {
      _logger.d(
        'Syncing paginated invoices in background for account: $accountId',
      );
      final remoteInvoices = await _remoteDataSource.getPaginatedInvoices(
        accountId,
      );
      await _localDataSource.cacheAccountInvoices(accountId, remoteInvoices);

      _logger.d(
        'Background sync completed for paginated invoices, account: $accountId',
      );
    } catch (e) {
      _logger.e(
        'Background sync failed for paginated invoices, account $accountId: $e',
      );
    }
  }

  /// Dispose resources
  void dispose() {
    _logger.d('🛑 [Account Invoices Repository] Disposing resources...');
    if (!_accountInvoicesController.isClosed) {
      _accountInvoicesController.close();
    }
    _logger.i('✅ [Account Invoices Repository] StreamController closed');
  }
}
