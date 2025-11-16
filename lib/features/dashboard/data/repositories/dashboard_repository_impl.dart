import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/models/repository_response.dart';
import '../../domain/entities/dashboard_kpi.dart';
import '../../domain/entities/subscription_trend.dart';
import '../../domain/entities/payment_status_overview.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_kpis_local_data_source.dart';
import '../datasources/dashboard_kpis_remote_data_source.dart';
import '../datasources/subscription_trends_local_data_source.dart';
import '../datasources/subscription_trends_remote_data_source.dart';
import '../datasources/payment_status_overview_local_data_source.dart';
import '../datasources/payment_status_overview_remote_data_source.dart';

@LazySingleton(as: DashboardRepository)
class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardKPIsLocalDataSource dashboardKPIsLocalDataSource;
  final DashboardKPIsRemoteDataSource dashboardKPIsRemoteDataSource;
  final SubscriptionTrendsLocalDataSource subscriptionTrendsLocalDataSource;
  final SubscriptionTrendsRemoteDataSource subscriptionTrendsRemoteDataSource;
  final PaymentStatusOverviewLocalDataSource
  paymentStatusOverviewLocalDataSource;
  final PaymentStatusOverviewRemoteDataSource
  paymentStatusOverviewRemoteDataSource;
  final NetworkInfo networkInfo;
  final Logger _logger = Logger();

  // Stream controllers for reactive UI updates
  final StreamController<RepositoryResponse<DashboardKPI>>
  _kpisStreamController =
      StreamController<RepositoryResponse<DashboardKPI>>.broadcast();
  final Map<int, StreamController<RepositoryResponse<SubscriptionTrends>>>
  _trendsStreamControllers = {};
  final Map<int, StreamController<RepositoryResponse<PaymentStatusOverviews>>>
  _overviewStreamControllers = {};

  // Stream subscriptions for local data changes
  StreamSubscription? _localKPIsSubscription;
  final Map<int, StreamSubscription> _localTrendsSubscriptions = {};
  final Map<int, StreamSubscription> _localOverviewSubscriptions = {};

  // Track last sync times to prevent rapid successive syncs
  DateTime? _lastKPIsSyncTime;
  final Map<int, DateTime> _lastTrendsSyncTime = {};
  final Map<int, DateTime> _lastOverviewSyncTime = {};

  DashboardRepositoryImpl({
    required this.dashboardKPIsLocalDataSource,
    required this.dashboardKPIsRemoteDataSource,
    required this.subscriptionTrendsLocalDataSource,
    required this.subscriptionTrendsRemoteDataSource,
    required this.paymentStatusOverviewLocalDataSource,
    required this.paymentStatusOverviewRemoteDataSource,
    required this.networkInfo,
  }) {
    _initializeStreamSubscriptions();
  }

  /// Initialize stream subscriptions for reactive updates from local data source
  void _initializeStreamSubscriptions() {
    // Listen to local KPIs changes and emit to repository stream
    _localKPIsSubscription = dashboardKPIsLocalDataSource
        .watchDashboardKPIs()
        .listen(
          (kpiModel) {
            _kpisStreamController.add(
              RepositoryResponse.success(kpiModel.toEntity()),
            );
          },
          onError: (error) {
            _logger.e('Error in KPIs stream: $error');
            _kpisStreamController.add(
              RepositoryResponse.error(message: 'Failed to load KPIs: $error'),
            );
          },
        );
  }

  // Stream getters for reactive UI updates
  Stream<RepositoryResponse<DashboardKPI>> get kpisStream =>
      _kpisStreamController.stream;

  Stream<RepositoryResponse<SubscriptionTrends>> getSubscriptionTrendsStream(
    int year,
  ) {
    return _getOrCreateTrendsStreamController(year).stream;
  }

  Stream<RepositoryResponse<PaymentStatusOverviews>>
  getPaymentStatusOverviewStream(int year) {
    return _getOrCreateOverviewStreamController(year).stream;
  }

  @override
  Future<Either<Failure, DashboardKPI>> getDashboardKPIs() async {
    try {
      _logger.i(
        '🔄 [Dashboard Repository] Getting dashboard KPIs (Local-First)',
      );

      // Local-First: First, try to get cached KPIs from local storage
      _logger.d(
        '💾 [Dashboard Repository] Fetching cached KPIs from local storage',
      );
      final cachedKPIs = await dashboardKPIsLocalDataSource
          .getCachedDashboardKPIs();
      _logger.d('✅ [Dashboard Repository] Retrieved cached KPIs');

      // Emit cached data immediately to stream
      _kpisStreamController.add(
        RepositoryResponse.success(cachedKPIs.toEntity()),
      );

      // Check if device is online and sync in background
      final isConnected = await networkInfo.isConnected;
      _logger.d(
        '📡 [Dashboard Repository] Network status: ${isConnected ? "Connected" : "Offline"}',
      );

      if (isConnected) {
        // Sync in background (non-blocking)
        _syncKPIsInBackground();
      } else {
        _logger.d(
          '📴 [Dashboard Repository] Device is offline, using cached KPIs',
        );
      }

      // Return cached data immediately
      return Right(cachedKPIs.toEntity());
    } on CacheException catch (e) {
      _logger.e('❌ [Dashboard Repository] CacheException: ${e.message}');
      _kpisStreamController.add(
        RepositoryResponse.error(exception: e, message: e.message),
      );
      return Left(CacheFailure(e.message));
    } catch (e, stackTrace) {
      _logger.e('💥 [Dashboard Repository] Unexpected error: $e');
      _logger.e('📚 [Dashboard Repository] Stack trace: $stackTrace');
      _kpisStreamController.add(
        RepositoryResponse.error(message: 'Unexpected error: $e'),
      );
      return Left(ServerFailure(e.toString()));
    }
  }

  /// Sync KPIs from remote in background
  Future<void> _syncKPIsInBackground() async {
    // Prevent rapid successive syncs (throttle to once per 30 seconds)
    final now = DateTime.now();
    if (_lastKPIsSyncTime != null &&
        now.difference(_lastKPIsSyncTime!).inSeconds < 30) {
      _logger.d('⏸️ [Dashboard Repository] Skipping KPIs sync (throttled)');
      return;
    }
    _lastKPIsSyncTime = now;

    try {
      _logger.d(
        '🌐 [Dashboard Repository] Syncing KPIs from remote API (background)',
      );
      // Fetch latest KPIs from remote API
      final remoteKPIs = await dashboardKPIsRemoteDataSource.getDashboardKPIs();
      _logger.i(
        '✅ [Dashboard Repository] Successfully fetched KPIs from remote API',
      );

      // Cache the received data locally (Single Source of Truth)
      // This will automatically emit to stream via local data source
      _logger.d('💾 [Dashboard Repository] Caching remote KPIs locally');
      await dashboardKPIsLocalDataSource.cacheDashboardKPIs(remoteKPIs);
      _logger.i('✅ [Dashboard Repository] Background sync completed for KPIs');
    } on ServerException catch (e) {
      _logger.w(
        '⚠️ [Dashboard Repository] ServerException during sync: ${e.message}',
      );
      // Don't emit error to stream, just log it
    } on NetworkException catch (e) {
      _logger.w(
        '⚠️ [Dashboard Repository] NetworkException during sync: ${e.message}',
      );
      // Don't emit error to stream, just log it
    } on AuthException catch (e) {
      _logger.e(
        '🔒 [Dashboard Repository] AuthException during sync: ${e.message}',
      );
      _kpisStreamController.add(
        RepositoryResponse.error(exception: e, message: e.message),
      );
    } on ValidationException catch (e) {
      _logger.e(
        '❌ [Dashboard Repository] ValidationException during sync: ${e.message}',
      );
      _kpisStreamController.add(
        RepositoryResponse.error(exception: e, message: e.message),
      );
    } catch (e, stackTrace) {
      _logger.e('💥 [Dashboard Repository] Unexpected error during sync: $e');
      _logger.e('📚 [Dashboard Repository] Stack trace: $stackTrace');
      // Don't emit error to stream for unexpected errors during background sync
    }
  }

  @override
  Future<Either<Failure, SubscriptionTrends>> getSubscriptionTrends(
    int year,
  ) async {
    try {
      _logger.i(
        '🔄 [Dashboard Repository] Getting subscription trends (Local-First) for year: $year',
      );

      // Local-First: First, try to get cached trends from local storage
      _logger.d(
        '💾 [Dashboard Repository] Fetching cached trends from local storage',
      );
      final cachedTrends = await subscriptionTrendsLocalDataSource
          .getCachedSubscriptionTrends(year);
      _logger.d('✅ [Dashboard Repository] Retrieved cached trends');

      // Emit cached data immediately to stream
      final streamController = _getOrCreateTrendsStreamController(year);
      streamController.add(RepositoryResponse.success(cachedTrends.toEntity()));

      // Check if device is online and sync in background
      final isConnected = await networkInfo.isConnected;
      _logger.d(
        '📡 [Dashboard Repository] Network status: ${isConnected ? "Connected" : "Offline"}',
      );

      if (isConnected) {
        // Sync in background (non-blocking)
        _syncSubscriptionTrendsInBackground(year);
      } else {
        _logger.d(
          '📴 [Dashboard Repository] Device is offline, using cached trends',
        );
      }

      // Return cached data immediately
      return Right(cachedTrends.toEntity());
    } on CacheException catch (e) {
      _logger.e('❌ [Dashboard Repository] CacheException: ${e.message}');
      final streamController = _getOrCreateTrendsStreamController(year);
      streamController.add(
        RepositoryResponse.error(exception: e, message: e.message),
      );
      return Left(CacheFailure(e.message));
    } catch (e, stackTrace) {
      _logger.e('💥 [Dashboard Repository] Unexpected error: $e');
      _logger.e('📚 [Dashboard Repository] Stack trace: $stackTrace');
      final streamController = _getOrCreateTrendsStreamController(year);
      streamController.add(
        RepositoryResponse.error(message: 'Unexpected error: $e'),
      );
      return Left(ServerFailure(e.toString()));
    }
  }

  StreamController<RepositoryResponse<SubscriptionTrends>>
  _getOrCreateTrendsStreamController(int year) {
    if (!_trendsStreamControllers.containsKey(year)) {
      _trendsStreamControllers[year] =
          StreamController<RepositoryResponse<SubscriptionTrends>>.broadcast();

      // Listen to local trends changes for this year
      _localTrendsSubscriptions[year] = subscriptionTrendsLocalDataSource
          .watchSubscriptionTrends(year)
          .listen(
            (trendsModel) {
              _trendsStreamControllers[year]!.add(
                RepositoryResponse.success(trendsModel.toEntity()),
              );
            },
            onError: (error) {
              _logger.e('Error in trends stream for year $year: $error');
              _trendsStreamControllers[year]!.add(
                RepositoryResponse.error(
                  message: 'Failed to load trends: $error',
                ),
              );
            },
          );
    }
    return _trendsStreamControllers[year]!;
  }

  /// Sync subscription trends from remote in background
  Future<void> _syncSubscriptionTrendsInBackground(int year) async {
    // Prevent rapid successive syncs (throttle to once per 30 seconds)
    final now = DateTime.now();
    if (_lastTrendsSyncTime.containsKey(year) &&
        now.difference(_lastTrendsSyncTime[year]!).inSeconds < 30) {
      _logger.d(
        '⏸️ [Dashboard Repository] Skipping trends sync for year $year (throttled)',
      );
      return;
    }
    _lastTrendsSyncTime[year] = now;

    try {
      _logger.d(
        '🌐 [Dashboard Repository] Syncing trends from remote API (background) for year: $year',
      );
      // Fetch latest trends from remote API
      final remoteTrends = await subscriptionTrendsRemoteDataSource
          .getSubscriptionTrends(year);
      _logger.i(
        '✅ [Dashboard Repository] Successfully fetched trends from remote API',
      );

      // Cache the received data locally (Single Source of Truth)
      // This will automatically emit to stream via local data source
      _logger.d('💾 [Dashboard Repository] Caching remote trends locally');
      await subscriptionTrendsLocalDataSource.cacheSubscriptionTrends(
        remoteTrends,
      );
      _logger.i(
        '✅ [Dashboard Repository] Background sync completed for trends year $year',
      );
    } on ServerException catch (e) {
      _logger.w(
        '⚠️ [Dashboard Repository] ServerException during sync: ${e.message}',
      );
      // Don't emit error to stream, just log it
    } on NetworkException catch (e) {
      _logger.w(
        '⚠️ [Dashboard Repository] NetworkException during sync: ${e.message}',
      );
      // Don't emit error to stream, just log it
    } on AuthException catch (e) {
      _logger.e(
        '🔒 [Dashboard Repository] AuthException during sync: ${e.message}',
      );
      final streamController = _getOrCreateTrendsStreamController(year);
      streamController.add(
        RepositoryResponse.error(exception: e, message: e.message),
      );
    } on ValidationException catch (e) {
      _logger.e(
        '❌ [Dashboard Repository] ValidationException during sync: ${e.message}',
      );
      final streamController = _getOrCreateTrendsStreamController(year);
      streamController.add(
        RepositoryResponse.error(exception: e, message: e.message),
      );
    } catch (e, stackTrace) {
      _logger.e('💥 [Dashboard Repository] Unexpected error during sync: $e');
      _logger.e('📚 [Dashboard Repository] Stack trace: $stackTrace');
      // Don't emit error to stream for unexpected errors during background sync
    }
  }

  @override
  Future<Either<Failure, PaymentStatusOverviews>> getPaymentStatusOverview(
    int year,
  ) async {
    try {
      _logger.i(
        '🔄 [Dashboard Repository] Getting payment status overview (Local-First) for year: $year',
      );

      // Local-First: First, try to get cached overview from local storage
      _logger.d(
        '💾 [Dashboard Repository] Fetching cached overview from local storage',
      );
      final cachedOverview = await paymentStatusOverviewLocalDataSource
          .getCachedPaymentStatusOverview(year);
      _logger.d('✅ [Dashboard Repository] Retrieved cached overview');

      // Emit cached data immediately to stream
      final streamController = _getOrCreateOverviewStreamController(year);
      streamController.add(
        RepositoryResponse.success(cachedOverview.toEntity()),
      );

      // Check if device is online and sync in background
      final isConnected = await networkInfo.isConnected;
      _logger.d(
        '📡 [Dashboard Repository] Network status: ${isConnected ? "Connected" : "Offline"}',
      );

      if (isConnected) {
        // Sync in background (non-blocking)
        _syncPaymentStatusOverviewInBackground(year);
      } else {
        _logger.d(
          '📴 [Dashboard Repository] Device is offline, using cached overview',
        );
      }

      // Return cached data immediately
      return Right(cachedOverview.toEntity());
    } on CacheException catch (e) {
      _logger.e('❌ [Dashboard Repository] CacheException: ${e.message}');
      final streamController = _getOrCreateOverviewStreamController(year);
      streamController.add(
        RepositoryResponse.error(exception: e, message: e.message),
      );
      return Left(CacheFailure(e.message));
    } catch (e, stackTrace) {
      _logger.e('💥 [Dashboard Repository] Unexpected error: $e');
      _logger.e('📚 [Dashboard Repository] Stack trace: $stackTrace');
      final streamController = _getOrCreateOverviewStreamController(year);
      streamController.add(
        RepositoryResponse.error(message: 'Unexpected error: $e'),
      );
      return Left(ServerFailure(e.toString()));
    }
  }

  StreamController<RepositoryResponse<PaymentStatusOverviews>>
  _getOrCreateOverviewStreamController(int year) {
    if (!_overviewStreamControllers.containsKey(year)) {
      _overviewStreamControllers[year] =
          StreamController<
            RepositoryResponse<PaymentStatusOverviews>
          >.broadcast();

      // Listen to local overview changes for this year
      _localOverviewSubscriptions[year] = paymentStatusOverviewLocalDataSource
          .watchPaymentStatusOverview(year)
          .listen(
            (overviewModel) {
              _overviewStreamControllers[year]!.add(
                RepositoryResponse.success(overviewModel.toEntity()),
              );
            },
            onError: (error) {
              _logger.e('Error in overview stream for year $year: $error');
              _overviewStreamControllers[year]!.add(
                RepositoryResponse.error(
                  message: 'Failed to load overview: $error',
                ),
              );
            },
          );
    }
    return _overviewStreamControllers[year]!;
  }

  /// Sync payment status overview from remote in background
  Future<void> _syncPaymentStatusOverviewInBackground(int year) async {
    // Prevent rapid successive syncs (throttle to once per 30 seconds)
    final now = DateTime.now();
    if (_lastOverviewSyncTime.containsKey(year) &&
        now.difference(_lastOverviewSyncTime[year]!).inSeconds < 30) {
      _logger.d(
        '⏸️ [Dashboard Repository] Skipping overview sync for year $year (throttled)',
      );
      return;
    }
    _lastOverviewSyncTime[year] = now;

    try {
      _logger.d(
        '🌐 [Dashboard Repository] Syncing overview from remote API (background) for year: $year',
      );
      // Fetch latest overview from remote API
      final remoteOverview = await paymentStatusOverviewRemoteDataSource
          .getPaymentStatusOverview(year);
      _logger.i(
        '✅ [Dashboard Repository] Successfully fetched overview from remote API',
      );

      // Cache the received data locally (Single Source of Truth)
      // This will automatically emit to stream via local data source
      _logger.d('💾 [Dashboard Repository] Caching remote overview locally');
      await paymentStatusOverviewLocalDataSource.cachePaymentStatusOverview(
        remoteOverview,
      );
      _logger.i(
        '✅ [Dashboard Repository] Background sync completed for overview year $year',
      );
    } on ServerException catch (e) {
      _logger.w(
        '⚠️ [Dashboard Repository] ServerException during sync: ${e.message}',
      );
      // Don't emit error to stream, just log it
    } on NetworkException catch (e) {
      _logger.w(
        '⚠️ [Dashboard Repository] NetworkException during sync: ${e.message}',
      );
      // Don't emit error to stream, just log it
    } on AuthException catch (e) {
      _logger.e(
        '🔒 [Dashboard Repository] AuthException during sync: ${e.message}',
      );
      final streamController = _getOrCreateOverviewStreamController(year);
      streamController.add(
        RepositoryResponse.error(exception: e, message: e.message),
      );
    } on ValidationException catch (e) {
      _logger.e(
        '❌ [Dashboard Repository] ValidationException during sync: ${e.message}',
      );
      final streamController = _getOrCreateOverviewStreamController(year);
      streamController.add(
        RepositoryResponse.error(exception: e, message: e.message),
      );
    } catch (e, stackTrace) {
      _logger.e('💥 [Dashboard Repository] Unexpected error during sync: $e');
      _logger.e('📚 [Dashboard Repository] Stack trace: $stackTrace');
      // Don't emit error to stream for unexpected errors during background sync
    }
  }

  /// Dispose resources and close all stream controllers and subscriptions
  void dispose() {
    _logger.d('🛑 [Dashboard Repository] Disposing resources...');

    // Cancel local KPIs subscription
    _localKPIsSubscription?.cancel();
    _localKPIsSubscription = null;

    // Close KPIs stream controller
    if (!_kpisStreamController.isClosed) {
      _kpisStreamController.close();
    }

    // Cancel and close all trends stream controllers and subscriptions
    for (final subscription in _localTrendsSubscriptions.values) {
      subscription.cancel();
    }
    _localTrendsSubscriptions.clear();

    for (final controller in _trendsStreamControllers.values) {
      if (!controller.isClosed) {
        controller.close();
      }
    }
    _trendsStreamControllers.clear();

    // Cancel and close all overview stream controllers and subscriptions
    for (final subscription in _localOverviewSubscriptions.values) {
      subscription.cancel();
    }
    _localOverviewSubscriptions.clear();

    for (final controller in _overviewStreamControllers.values) {
      if (!controller.isClosed) {
        controller.close();
      }
    }
    _overviewStreamControllers.clear();

    // Clear sync time tracking
    _lastKPIsSyncTime = null;
    _lastTrendsSyncTime.clear();
    _lastOverviewSyncTime.clear();

    _logger.i('✅ [Dashboard Repository] All resources disposed');
  }
}
