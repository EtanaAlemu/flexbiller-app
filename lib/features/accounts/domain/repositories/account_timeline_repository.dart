import '../entities/account_timeline.dart';

abstract class AccountTimelineRepository {
  /// Get timeline for a specific account
  Future<AccountTimeline> getAccountTimeline(String accountId);
  
  /// Get timeline with pagination
  Future<AccountTimeline> getAccountTimelinePaginated(
    String accountId, {
    int offset = 0,
    int limit = 50,
  });
  
  /// Get timeline filtered by event type
  Future<AccountTimeline> getAccountTimelineByEventType(
    String accountId,
    String eventType,
  );
  
  /// Get timeline filtered by date range
  Future<AccountTimeline> getAccountTimelineByDateRange(
    String accountId,
    DateTime startDate,
    DateTime endDate,
  );
}
