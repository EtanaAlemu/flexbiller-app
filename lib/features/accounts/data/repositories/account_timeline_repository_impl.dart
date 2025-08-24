import 'package:injectable/injectable.dart';
import '../../domain/entities/account_timeline.dart';
import '../../domain/repositories/account_timeline_repository.dart';
import '../datasources/account_timeline_remote_data_source.dart';

@Injectable(as: AccountTimelineRepository)
class AccountTimelineRepositoryImpl implements AccountTimelineRepository {
  final AccountTimelineRemoteDataSource _remoteDataSource;

  AccountTimelineRepositoryImpl(this._remoteDataSource);

  @override
  Future<AccountTimeline> getAccountTimeline(String accountId) async {
    try {
      final timelineModel = await _remoteDataSource.getAccountTimeline(accountId);
      return timelineModel.toEntity();
    } catch (e) {
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
      final timelineModel = await _remoteDataSource.getAccountTimelinePaginated(
        accountId,
        offset: offset,
        limit: limit,
      );
      return timelineModel.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<AccountTimeline> getAccountTimelineByEventType(
    String accountId,
    String eventType,
  ) async {
    try {
      // For now, get all timeline and filter by event type
      // In the future, this could be implemented as a separate API endpoint
      final timeline = await getAccountTimeline(accountId);
      final filteredEvents = timeline.events
          .where((event) => event.eventType.toLowerCase() == eventType.toLowerCase())
          .toList();
      
      return timeline.copyWith(events: filteredEvents);
    } catch (e) {
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
      // For now, get all timeline and filter by date range
      // In the future, this could be implemented as a separate API endpoint
      final timeline = await getAccountTimeline(accountId);
      final filteredEvents = timeline.events
          .where((event) => 
              event.timestamp.isAfter(startDate) && 
              event.timestamp.isBefore(endDate))
          .toList();
      
      return timeline.copyWith(events: filteredEvents);
    } catch (e) {
      rethrow;
    }
  }
}
