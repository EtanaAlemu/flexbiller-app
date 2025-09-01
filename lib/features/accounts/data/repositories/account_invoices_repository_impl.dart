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
  Stream<List<AccountInvoice>> get accountInvoicesStream => _accountInvoicesController.stream;

  @override
  Future<List<AccountInvoice>> getInvoices(String accountId) async {
    try {
      // First, get data from local cache (immediate response)
      final cachedInvoices = await _localDataSource.getCachedAccountInvoices(accountId);
      
      // Emit cached data immediately for UI responsiveness
      if (cachedInvoices.isNotEmpty) {
        final entities = cachedInvoices.map((model) => model.toEntity()).toList();
        _accountInvoicesController.add(entities);
        _logger.d('Emitted ${entities.length} cached invoices for account: $accountId');
      }

      // Check if device is online for background synchronization
      if (await _networkInfo.isConnected) {
        try {
          // Fetch fresh data from remote source
          final remoteInvoices = await _remoteDataSource.getInvoices(accountId);
          
          // Cache the fresh data locally
          await _localDataSource.cacheAccountInvoices(accountId, remoteInvoices);
          _logger.d('Cached ${remoteInvoices.length} fresh invoices for account: $accountId');

          // Emit updated data for UI refresh
          final updatedEntities = remoteInvoices.map((model) => model.toEntity()).toList();
          _accountInvoicesController.add(updatedEntities);
          _logger.d('Emitted ${updatedEntities.length} fresh invoices for account: $accountId');

          return updatedEntities;
        } catch (e) {
          _logger.w('Remote fetch failed for account $accountId: $e');
          // Return cached data if remote fetch fails
          if (cachedInvoices.isNotEmpty) {
            return cachedInvoices.map((model) => model.toEntity()).toList();
          }
          rethrow;
        }
      } else {
        _logger.d('Device offline, returning cached invoices for account: $accountId');
        // Return cached data if offline
        if (cachedInvoices.isNotEmpty) {
          return cachedInvoices.map((model) => model.toEntity()).toList();
        }
        // Return empty list if no cached data
        return [];
      }
    } catch (e) {
      _logger.e('Error getting invoices for account $accountId: $e');
      rethrow;
    }
  }

  @override
  Future<List<AccountInvoice>> getPaginatedInvoices(String accountId) async {
    try {
      // First, get from local cache
      final cachedInvoices = await _localDataSource.getCachedPaginatedInvoices(accountId);
      
      if (cachedInvoices.isNotEmpty) {
        _logger.d('Found ${cachedInvoices.length} cached paginated invoices for account: $accountId');
        return cachedInvoices.map((model) => model.toEntity()).toList();
      }

      // If no cached results and online, fetch from remote
      if (await _networkInfo.isConnected) {
        try {
          final remoteInvoices = await _remoteDataSource.getPaginatedInvoices(accountId);
          
          // Cache the results locally
          await _localDataSource.cacheAccountInvoices(accountId, remoteInvoices);
          _logger.d('Cached ${remoteInvoices.length} paginated invoices for account: $accountId');

          return remoteInvoices.map((model) => model.toEntity()).toList();
        } catch (e) {
          _logger.w('Remote fetch failed for paginated invoices, account $accountId: $e');
          rethrow;
        }
      } else {
        _logger.d('Device offline, no cached results for paginated invoices, account $accountId');
        return [];
      }
    } catch (e) {
      _logger.e('Error getting paginated invoices for account $accountId: $e');
      rethrow;
    }
  }

  /// Dispose resources
  void dispose() {
    _accountInvoicesController.close();
    _logger.d('AccountInvoicesRepositoryImpl disposed');
  }
}
