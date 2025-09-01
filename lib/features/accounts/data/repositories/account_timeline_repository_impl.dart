import 'dart:async';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/account_timeline.dart';
import '../../domain/repositories/account_timeline_repository.dart';
import '../datasources/local/account_timeline_local_data_source.dart';
import '../datasources/remote/account_timeline_remote_data_source.dart';

@LazySingleton(as: AccountTimelineRepository)
class AccountTimelineRepositoryImpl implements AccountTimelineRepository {
  final AccountTimelineRemoteDataSource _remoteDataSource;
  final AccountTimelineLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;
  final Logger _logger = Logger();

  // Stream controllers for reactive UI updates
  final StreamController<AccountTimeline> _accountTimelineStreamController = 
      StreamController<AccountTimeline>.broadcast();
  final StreamController<AccountTimeline> _accountTimelinePaginatedStreamController = 
      StreamController<AccountTimeline>.broadcast();

  AccountTimelineRepositoryImpl({
    required AccountTimelineRemoteDataSource remoteDataSource,
    required AccountTimelineLocalDataSource localDataSource,
    required NetworkInfo networkInfo,
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource,
       _networkInfo = networkInfo;

  @override
  Stream<AccountTimeline> get accountTimelineStream => _accountTimelineStreamController.stream;

  @override
  Stream<AccountTimeline> get accountTimelinePaginatedStream => _accountTimelinePaginatedStreamController.stream;

  @override
  Future<AccountTimeline> getAccountTimeline(String accountId) async {
    try {
      // 1. First, try to get data from local cache
      final cachedTimeline = await _localDataSource.getCachedAccountTimeline(accountId);
      if (cachedTimeline != null) {
        _logger.d('Returning cached account timeline for account: $accountId');
        
        // 2. Start background sync to get fresh data
        _syncAccountTimelineInBackground(accountId);
        
        return cachedTimeline.toEntity();
      }

      // 3. If no cached data, check network and fetch from remote
      if (await _networkInfo.isConnected) {
        _logger.d('No cached data, fetching from remote for account: $accountId');
        final remoteTimeline = await _remoteDataSource.getAccountTimeline(accountId);
        
        // 4. Cache the remote data
        await _localDataSource.cacheAccountTimeline(remoteTimeline);
        
        // 5. Add to stream for UI update
        final freshTimeline = remoteTimeline.toEntity();
        _accountTimelineStreamController.add(freshTimeline);
        
        return freshTimeline;
      } else {
        // 6. Offline and no cached data
        _logger.w('No cached data and offline for account: $accountId');
        throw Exception('No data available offline');
      }
    } catch (e) {
      _logger.e('Error getting account timeline for account: $accountId - $e');
      rethrow;
    }
  }

  @override
  Future<AccountTimeline> getAccountTimelinePaginated(
    String accountId, {
    int offset = 0,
    int limit = 50,
  }) async {
    try {
      // 1. First, try to get data from local cache
      final cachedTimeline = await _localDataSource.getCachedAccountTimeline(accountId);
      if (cachedTimeline != null) {
        _logger.d('Returning cached paginated timeline for account: $accountId (offset: $offset, limit: $limit)');
        
        // 2. Start background sync to get fresh data
        _syncAccountTimelinePaginatedInBackground(accountId, offset: offset, limit: limit);
        
        return cachedTimeline.toEntity();
      }

      // 3. If no cached data, check network and fetch from remote
      if (await _networkInfo.isConnected) {
        _logger.d('No cached data, fetching paginated from remote for account: $accountId');
        final remoteTimeline = await _remoteDataSource.getAccountTimelinePaginated(
          accountId,
          offset: offset,
          limit: limit,
        );
        
        // 4. Cache the remote data
        await _localDataSource.cacheAccountTimeline(remoteTimeline);
        
        // 5. Add to stream for UI update
        final freshTimeline = remoteTimeline.toEntity();
        _accountTimelinePaginatedStreamController.add(freshTimeline);
        
        return freshTimeline;
      } else {
        // 6. Offline and no cached data
        _logger.w('No cached data and offline for paginated timeline for account: $accountId');
        throw Exception('No data available offline');
      }
    } catch (e) {
      _logger.e('Error getting paginated account timeline for account: $accountId - $e');
      rethrow;
    }
  }

  @override
  Future<AccountTimeline> getAccountTimelineByEventType(
    String accountId,
    String eventType,
  ) async {
    try {
      // 1. First, try to get data from local cache
      final cachedTimeline = await _localDataSource.getCachedAccountTimeline(accountId);
      if (cachedTimeline != null) {
        _logger.d('Returning cached timeline filtered by event type for account: $accountId, type: $eventType');
        
        // 2. Start background sync to get fresh data
        _syncAccountTimelineInBackground(accountId);
        
        final timeline = cachedTimeline.toEntity();
        final filteredEvents = timeline.events
            .where((event) => event.eventType.toLowerCase() == eventType.toLowerCase())
            .toList();
        
        return timeline.copyWith(events: filteredEvents);
      }

      // 3. If no cached data, check network and fetch from remote
      if (await _networkInfo.isConnected) {
        _logger.d('No cached data, fetching from remote for event type filter for account: $accountId');
        final remoteTimeline = await _remoteDataSource.getAccountTimeline(accountId);
        
        // 4. Cache the remote data
        await _localDataSource.cacheAccountTimeline(remoteTimeline);
        
        // 5. Add to stream for UI update
        final freshTimeline = remoteTimeline.toEntity();
        _accountTimelineStreamController.add(freshTimeline);
        
        final filteredEvents = freshTimeline.events
            .where((event) => event.eventType.toLowerCase() == eventType.toLowerCase())
            .toList();
        
        return freshTimeline.copyWith(events: filteredEvents);
      } else {
        // 6. Offline and no cached data
        _logger.w('No cached data and offline for event type filter for account: $accountId');
        throw Exception('No data available offline');
      }
    } catch (e) {
      _logger.e('Error getting account timeline by event type for account: $accountId, type: $eventType - $e');
      rethrow;
    }
  }

  @override
  Future<AccountTimeline> getAccountTimelineByDateRange(
    String accountId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      // 1. First, try to get data from local cache
      final cachedTimeline = await _localDataSource.getCachedAccountTimeline(accountId);
      if (cachedTimeline != null) {
        _logger.d('Returning cached timeline filtered by date range for account: $accountId');
        
        // 2. Start background sync to get fresh data
        _syncAccountTimelineInBackground(accountId);
        
        final timeline = cachedTimeline.toEntity();
        final filteredEvents = timeline.events
            .where((event) => 
                event.timestamp.isAfter(startDate) && 
                event.timestamp.isBefore(endDate))
            .toList();
        
        return timeline.copyWith(events: filteredEvents);
      }

      // 3. If no cached data, check network and fetch from remote
      if (await _networkInfo.isConnected) {
        _logger.d('No cached data, fetching from remote for date range filter for account: $accountId');
        final remoteTimeline = await _remoteDataSource.getAccountTimeline(accountId);
        
        // 4. Cache the remote data
        await _localDataSource.cacheAccountTimeline(remoteTimeline);
        
        // 5. Add to stream for UI update
        final freshTimeline = remoteTimeline.toEntity();
        _accountTimelineStreamController.add(freshTimeline);
        
        final filteredEvents = freshTimeline.events
            .where((event) => 
                event.timestamp.isAfter(startDate) && 
                event.timestamp.isBefore(endDate))
            .toList();
        
        return freshTimeline.copyWith(events: filteredEvents);
      } else {
        // 6. Offline and no cached data
        _logger.w('No cached data and offline for date range filter for account: $accountId');
        throw Exception('No data available offline');
      }
    } catch (e) {
      _logger.e('Error getting account timeline by date range for account: $accountId - $e');
      rethrow;
    }
  }

  /// Background synchronization for account timeline
  Future<void> _syncAccountTimelineInBackground(String accountId) async {
    try {
      if (await _networkInfo.isConnected) {
        _logger.d('Starting background sync for account timeline: $accountId');
        final remoteTimeline = await _remoteDataSource.getAccountTimeline(accountId);
        
        // Update local cache
        await _localDataSource.cacheAccountTimeline(remoteTimeline);
        
        // Add fresh data to stream for UI update
        final freshTimeline = remoteTimeline.toEntity();
        _accountTimelineStreamController.add(freshTimeline);
        
        _logger.d('Background sync completed for account timeline: $accountId - UI updated with fresh data');
      }
    } catch (e) {
      _logger.w('Background sync failed for account timeline: $accountId - $e');
    }
  }

  /// Background synchronization for paginated account timeline
  Future<void> _syncAccountTimelinePaginatedInBackground(
    String accountId, {
    int offset = 0,
    int limit = 50,
  }) async {
    try {
      if (await _networkInfo.isConnected) {
        _logger.d('Starting background sync for paginated account timeline: $accountId');
        final remoteTimeline = await _remoteDataSource.getAccountTimelinePaginated(
          accountId,
          offset: offset,
          limit: limit,
        );
        
        // Update local cache
        await _localDataSource.cacheAccountTimeline(remoteTimeline);
        
        // Add fresh data to stream for UI update
        final freshTimeline = remoteTimeline.toEntity();
        _accountTimelinePaginatedStreamController.add(freshTimeline);
        
        _logger.d('Background sync completed for paginated account timeline: $accountId - UI updated with fresh data');
      }
    } catch (e) {
      _logger.w('Background sync failed for paginated account timeline: $accountId - $e');
    }
  }

  /// Dispose method to close stream controllers
  void dispose() {
    _accountTimelineStreamController.close();
    _accountTimelinePaginatedStreamController.close();
  }
}
