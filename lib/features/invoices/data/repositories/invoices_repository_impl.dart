import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';

import '../../../../../core/errors/failures.dart';
import '../../../../../core/errors/exceptions.dart';
import '../../../../../core/network/network_info.dart';
import '../../domain/entities/invoice.dart';
import '../../domain/entities/invoice_audit_log.dart';
import '../../domain/repositories/invoices_repository.dart';
import '../datasources/local/invoices_local_data_source.dart';
import '../datasources/remote/invoices_remote_data_source.dart';
import '../models/adjust_invoice_item_request_model.dart';

@LazySingleton(as: InvoicesRepository)
class InvoicesRepositoryImpl implements InvoicesRepository {
  final InvoicesRemoteDataSource _remoteDataSource;
  final InvoicesLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;
  final Logger _logger;

  InvoicesRepositoryImpl({
    required InvoicesRemoteDataSource remoteDataSource,
    required InvoicesLocalDataSource localDataSource,
    required NetworkInfo networkInfo,
    required Logger logger,
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource,
       _networkInfo = networkInfo,
       _logger = logger;

  @override
  Future<Either<Failure, List<Invoice>>> getInvoices() async {
    try {
      _logger.d('InvoicesRepository: Starting getInvoices()');

      // First, try to get cached invoices immediately (local-first approach)
      _logger.d('InvoicesRepository: Attempting to get cached invoices');
      final cachedInvoices = await _localDataSource.getCachedInvoices();
      _logger.d(
        'InvoicesRepository: Retrieved ${cachedInvoices.length} cached invoices',
      );

      if (cachedInvoices.isNotEmpty) {
        _logger.d(
          'InvoicesRepository: Found cached invoices, returning immediately',
        );
        // Return cached data immediately
        final invoices = cachedInvoices
            .map((model) => model.toEntity())
            .toList();

        // Then sync with remote in background if online
        _logger.d(
          'InvoicesRepository: Checking network connectivity for background sync',
        );
        if (await _networkInfo.isConnected) {
          _logger.d(
            'InvoicesRepository: Network connected, starting background sync',
          );
          _syncInvoicesInBackground();
        } else {
          _logger.d(
            'InvoicesRepository: No network connection, skipping background sync',
          );
        }

        _logger.d(
          'InvoicesRepository: Returning ${invoices.length} cached invoices',
        );
        return Right(invoices);
      }

      _logger.d(
        'InvoicesRepository: No cached invoices found, attempting remote fetch',
      );
      // If no cached data, try to fetch from remote
      if (await _networkInfo.isConnected) {
        _logger.d(
          'InvoicesRepository: Network connected, fetching from remote',
        );
        try {
          final remoteInvoices = await _remoteDataSource.getInvoices();
          _logger.d(
            'InvoicesRepository: Retrieved ${remoteInvoices.length} invoices from remote',
          );

          // Cache the remote data
          _logger.d('InvoicesRepository: Caching remote invoices');
          await _localDataSource.cacheInvoices(remoteInvoices);

          // Return the data
          final invoices = remoteInvoices
              .map((model) => model.toEntity())
              .toList();
          _logger.d(
            'InvoicesRepository: Returning ${invoices.length} remote invoices',
          );
          return Right(invoices);
        } catch (e, stackTrace) {
          _logger.e(
            'InvoicesRepository: Error fetching invoices from remote: $e',
          );
          _logger.e('InvoicesRepository: Stack trace: $stackTrace');
          return Left(ServerFailure('Failed to fetch invoices: $e'));
        }
      } else {
        _logger.w(
          'InvoicesRepository: No internet connection and no cached data',
        );
        return Left(
          NetworkFailure('No internet connection and no cached data'),
        );
      }
    } catch (e, stackTrace) {
      _logger.e('InvoicesRepository: Unexpected error in getInvoices: $e');
      _logger.e('InvoicesRepository: Stack trace: $stackTrace');
      return Left(CacheFailure('Error accessing local storage: $e'));
    }
  }

  @override
  Future<Either<Failure, Invoice>> getInvoiceById(String invoiceId) async {
    try {
      // First, try to get cached invoice immediately (local-first approach)
      final cachedInvoice = await _localDataSource.getCachedInvoiceById(
        invoiceId,
      );
      if (cachedInvoice != null) {
        // Return cached data immediately
        final invoice = cachedInvoice.toEntity();

        // Then sync with remote in background if online
        if (await _networkInfo.isConnected) {
          _syncInvoiceByIdInBackground(invoiceId);
        }

        return Right(invoice);
      }

      // If no cached data, try to fetch from remote
      if (await _networkInfo.isConnected) {
        try {
          final remoteInvoice = await _remoteDataSource.getInvoiceById(
            invoiceId,
          );

          // Cache the remote data
          await _localDataSource.cacheInvoice(remoteInvoice);

          // Return the data
          final invoice = remoteInvoice.toEntity();
          return Right(invoice);
        } catch (e) {
          return Left(ServerFailure('Failed to fetch invoice: $e'));
        }
      } else {
        return Left(
          NetworkFailure('No internet connection and no cached data'),
        );
      }
    } catch (e) {
      return Left(CacheFailure('Error accessing local storage: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Invoice>>> getInvoicesByAccountId(
    String accountId,
  ) async {
    try {
      // First, try to get cached invoices immediately (local-first approach)
      final cachedInvoices = await _localDataSource
          .getCachedInvoicesByAccountId(accountId);
      if (cachedInvoices.isNotEmpty) {
        // Return cached data immediately
        final invoices = cachedInvoices
            .map((model) => model.toEntity())
            .toList();

        // Then sync with remote in background if online
        if (await _networkInfo.isConnected) {
          _syncInvoicesByAccountIdInBackground(accountId);
        }

        return Right(invoices);
      }

      // If no cached data, try to fetch from remote
      if (await _networkInfo.isConnected) {
        try {
          final remoteInvoices = await _remoteDataSource.getInvoicesByAccountId(
            accountId,
          );

          // Cache the remote data
          await _localDataSource.cacheInvoices(remoteInvoices);

          // Return the data
          final invoices = remoteInvoices
              .map((model) => model.toEntity())
              .toList();
          return Right(invoices);
        } catch (e) {
          return Left(ServerFailure('Failed to fetch invoices by account: $e'));
        }
      } else {
        return Left(
          NetworkFailure('No internet connection and no cached data'),
        );
      }
    } catch (e) {
      return Left(CacheFailure('Error accessing local storage: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Invoice>>> getCachedInvoices() async {
    try {
      final cachedInvoices = await _localDataSource.getCachedInvoices();
      final invoices = cachedInvoices.map((model) => model.toEntity()).toList();
      return Right(invoices);
    } catch (e) {
      return Left(CacheFailure('Error retrieving cached invoices: $e'));
    }
  }

  @override
  Future<Either<Failure, Invoice>> getCachedInvoiceById(
    String invoiceId,
  ) async {
    try {
      final cachedInvoice = await _localDataSource.getCachedInvoiceById(
        invoiceId,
      );
      if (cachedInvoice != null) {
        final invoice = cachedInvoice.toEntity();
        return Right(invoice);
      } else {
        return Left(CacheFailure('Invoice not found in cache'));
      }
    } catch (e) {
      return Left(CacheFailure('Error retrieving cached invoice: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Invoice>>> searchInvoices(
    String searchKey,
  ) async {
    try {
      _logger.d(
        'InvoicesRepository: Starting searchInvoices with key: $searchKey',
      );

      // Only search in local cache - no remote calls for search
      final cachedResults = await _localDataSource.searchCachedInvoices(
        searchKey,
      );

      _logger.d(
        'InvoicesRepository: Found ${cachedResults.length} cached search results',
      );

      final invoices = cachedResults.map((model) => model.toEntity()).toList();
      return Right(invoices);
    } catch (e, stackTrace) {
      _logger.e('InvoicesRepository: Error searching invoices: $e');
      _logger.e('InvoicesRepository: Stack trace: $stackTrace');
      return Left(CacheFailure('Error searching invoices: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Invoice>>> getCachedInvoicesByAccountId(
    String accountId,
  ) async {
    try {
      final cachedInvoices = await _localDataSource
          .getCachedInvoicesByAccountId(accountId);
      final invoices = cachedInvoices.map((model) => model.toEntity()).toList();
      return Right(invoices);
    } catch (e) {
      return Left(
        CacheFailure('Error retrieving cached invoices by account: $e'),
      );
    }
  }

  /// Sync invoices with remote server in background
  Future<void> _syncInvoicesInBackground() async {
    try {
      _logger.d('InvoicesRepository: Starting background sync for invoices');
      final remoteInvoices = await _remoteDataSource.getInvoices();
      _logger.d(
        'InvoicesRepository: Retrieved ${remoteInvoices.length} invoices for background sync',
      );
      await _localDataSource.cacheInvoices(remoteInvoices);
      _logger.d('InvoicesRepository: Background sync completed successfully');
    } catch (e, stackTrace) {
      // Log error but don't throw - this is background sync
      _logger.e('InvoicesRepository: Background sync failed: $e');
      _logger.e('InvoicesRepository: Background sync stack trace: $stackTrace');
    }
  }

  /// Sync specific invoice with remote server in background
  Future<void> _syncInvoiceByIdInBackground(String invoiceId) async {
    try {
      final remoteInvoice = await _remoteDataSource.getInvoiceById(invoiceId);
      await _localDataSource.cacheInvoice(remoteInvoice);
    } catch (e) {
      // Log error but don't throw - this is background sync
      _logger.e(
        'InvoicesRepository: Background sync failed for invoice $invoiceId: $e',
      );
    }
  }

  /// Sync invoices by account with remote server in background
  Future<void> _syncInvoicesByAccountIdInBackground(String accountId) async {
    try {
      final remoteInvoices = await _remoteDataSource.getInvoicesByAccountId(
        accountId,
      );
      await _localDataSource.cacheInvoices(remoteInvoices);
    } catch (e) {
      // Log error but don't throw - this is background sync
      _logger.e(
        'InvoicesRepository: Background sync failed for account $accountId: $e',
      );
    }
  }

  @override
  Future<Either<Failure, List<InvoiceAuditLog>>> getInvoiceAuditLogsWithHistory(
    String invoiceId,
  ) async {
    try {
      _logger.d(
        'InvoicesRepository: Starting getInvoiceAuditLogsWithHistory for invoice: $invoiceId',
      );

      // Try to get cached audit logs first
      try {
        final cachedAuditLogs = await _localDataSource
            .getCachedInvoiceAuditLogsWithHistory(invoiceId);
        _logger.d(
          'InvoicesRepository: Found ${cachedAuditLogs.length} cached audit logs',
        );

        // Convert to domain entities
        final auditLogs = cachedAuditLogs
            .map((model) => model.toEntity())
            .toList();

        // Sync with remote in background
        _syncInvoiceAuditLogsInBackground(invoiceId);

        return Right(auditLogs);
      } on Exception catch (e) {
        _logger.w('InvoicesRepository: Failed to get cached audit logs: $e');
        // Continue to remote fetch
      }

      // If cached data is not available, fetch from remote
      if (await _networkInfo.isConnected) {
        try {
          _logger.d(
            'InvoicesRepository: Fetching audit logs from remote server',
          );
          final remoteAuditLogs = await _remoteDataSource
              .getInvoiceAuditLogsWithHistory(invoiceId);

          // Cache the audit logs locally
          // Note: We don't have a cacheAuditLogs method yet, so we'll skip caching for now

          final auditLogs = remoteAuditLogs
              .map((model) => model.toEntity())
              .toList();
          return Right(auditLogs);
        } on ServerException catch (e) {
          _logger.e(
            'InvoicesRepository: Server error fetching audit logs: ${e.message}',
          );
          return Left(ServerFailure(e.message));
        }
      } else {
        _logger.w(
          'InvoicesRepository: No network connection and no cached audit logs available',
        );
        return Left(NetworkFailure('No network connection'));
      }
    } catch (e, stackTrace) {
      _logger.e(
        'InvoicesRepository: Unexpected error in getInvoiceAuditLogsWithHistory: $e',
      );
      _logger.e('InvoicesRepository: Stack trace: $stackTrace');
      return Left(ServerFailure('Unexpected error occurred: $e'));
    }
  }

  /// Sync invoice audit logs with remote server in background
  Future<void> _syncInvoiceAuditLogsInBackground(String invoiceId) async {
    try {
      await _remoteDataSource.getInvoiceAuditLogsWithHistory(invoiceId);
      // Note: We don't have a cacheAuditLogs method yet, so we'll skip caching for now
      _logger.d(
        'InvoicesRepository: Background sync completed for invoice audit logs: $invoiceId',
      );
    } catch (e) {
      // Log error but don't throw - this is background sync
      _logger.e(
        'InvoicesRepository: Background sync failed for invoice audit logs $invoiceId: $e',
      );
    }
  }

  @override
  Future<Either<Failure, void>> adjustInvoiceItem(
    String invoiceId,
    String invoiceItemId,
    String accountId,
    double amount,
    String currency,
    String description,
  ) async {
    try {
      _logger.d(
        'InvoicesRepository: Starting adjustInvoiceItem for invoice: $invoiceId, item: $invoiceItemId',
      );

      if (!await _networkInfo.isConnected) {
        _logger.w(
          'InvoicesRepository: No network connection for invoice adjustment',
        );
        return Left(NetworkFailure('No network connection'));
      }

      final request = AdjustInvoiceItemRequestModel(
        invoiceItemId: invoiceItemId,
        accountId: accountId,
        amount: amount,
        currency: currency,
        description: description,
      );

      final response = await _remoteDataSource.adjustInvoiceItem(
        invoiceId,
        request,
      );

      if (response.success) {
        _logger.d(
          'InvoicesRepository: Successfully adjusted invoice item: $invoiceItemId',
        );

        // Sync the updated invoice in background
        _syncInvoiceByIdInBackground(invoiceId);

        return const Right(null);
      } else {
        _logger.e(
          'InvoicesRepository: Failed to adjust invoice item: ${response.message ?? response.error}',
        );
        return Left(
          ServerFailure(response.message ?? response.error ?? 'Unknown error'),
        );
      }
    } catch (e, stackTrace) {
      _logger.e(
        'InvoicesRepository: Unexpected error in adjustInvoiceItem: $e',
      );
      _logger.e('InvoicesRepository: Stack trace: $stackTrace');
      return Left(ServerFailure('Unexpected error occurred: $e'));
    }
  }
}
