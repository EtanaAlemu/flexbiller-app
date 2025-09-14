import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import '../../../../../core/services/database_service.dart';
import '../../../../../core/services/user_session_service.dart';
import '../../../../../core/dao/account_timeline_dao.dart';
import '../../models/account_timeline_model.dart';

abstract class AccountTimelineLocalDataSource {
  Future<void> cacheAccountTimeline(AccountTimelineModel timeline);
  Future<AccountTimelineModel?> getCachedAccountTimeline(String accountId);
  Future<void> deleteCachedAccountTimeline(String accountId);
  Future<void> clearAllCachedAccountTimelines();
  Future<bool> hasCachedAccountTimeline(String accountId);
  Future<int> getCachedAccountTimelinesCount();
}

@Injectable(as: AccountTimelineLocalDataSource)
class AccountTimelineLocalDataSourceImpl
    implements AccountTimelineLocalDataSource {
  final DatabaseService _databaseService;
  final UserSessionService _userSessionService;
  final Logger _logger = Logger();

  AccountTimelineLocalDataSourceImpl(
    this._databaseService,
    this._userSessionService,
  );

  @override
  Future<void> cacheAccountTimeline(AccountTimelineModel timeline) async {
    try {
      // Check for user context and restore if needed
      var currentUserId = _userSessionService.getCurrentUserIdOrNull();
      if (currentUserId == null) {
        _logger.w('No active user context, attempting to restore user context');
        try {
          await _userSessionService.restoreCurrentUserContext();
          currentUserId = _userSessionService.getCurrentUserIdOrNull();
          if (currentUserId == null) {
            _logger.w(
              'Failed to restore user context, skipping timeline caching',
            );
            return;
          } else {
            _logger.i('User context restored successfully: $currentUserId');
          }
        } catch (e) {
          _logger.e('Error restoring user context: $e');
          return;
        }
      }
      // If we have a user ID, proceed even if hasActiveUser is false
      if (currentUserId != null) {
        _logger.d('Using restored user ID: $currentUserId');
      }

      final db = await _databaseService.database;
      await AccountTimelineDao.insertOrUpdate(db, timeline);
      _logger.d(
        'Account timeline cached successfully: ${timeline.account.accountId}',
      );
    } catch (e) {
      _logger.e('Error caching account timeline: $e');
      rethrow;
    }
  }

  @override
  Future<AccountTimelineModel?> getCachedAccountTimeline(
    String accountId,
  ) async {
    try {
      // Check for user context and restore if needed
      var currentUserId = _userSessionService.getCurrentUserIdOrNull();
      if (currentUserId == null) {
        _logger.w('No active user context, attempting to restore user context');
        try {
          await _userSessionService.restoreCurrentUserContext();
          currentUserId = _userSessionService.getCurrentUserIdOrNull();
          if (currentUserId == null) {
            _logger.w(
              'Failed to restore user context, returning null timeline',
            );
            return null;
          } else {
            _logger.i('User context restored successfully: $currentUserId');
          }
        } catch (e) {
          _logger.e('Error restoring user context: $e');
          return null;
        }
      }
      // If we have a user ID, proceed even if hasActiveUser is false
      if (currentUserId != null) {
        _logger.d('Using restored user ID: $currentUserId');
      }

      final db = await _databaseService.database;
      final timelineData = await AccountTimelineDao.getByAccountId(
        db,
        accountId,
      );

      if (timelineData != null) {
        // Use the DAO's fromMap method to properly parse the timeline data
        final timeline = AccountTimelineDao.fromMap(timelineData);
        if (timeline != null) {
          _logger.d('Retrieved cached timeline for account: $accountId');
          return timeline;
        } else {
          _logger.w('Failed to parse cached timeline for account: $accountId');
          return null;
        }
      }
      return null;
    } catch (e) {
      _logger.e('Error getting cached account timeline: $e');
      // If table doesn't exist, return null instead of throwing
      if (e.toString().contains('no such table: account_timelines')) {
        _logger.w('Account timelines table does not exist yet, returning null');
        return null;
      }
      rethrow;
    }
  }

  @override
  Future<void> deleteCachedAccountTimeline(String accountId) async {
    try {
      final db = await _databaseService.database;
      await AccountTimelineDao.deleteByAccountId(db, accountId);
      _logger.d('Account timeline deleted from cache: $accountId');
    } catch (e) {
      _logger.e('Error deleting cached account timeline: $e');
      rethrow;
    }
  }

  @override
  Future<void> clearAllCachedAccountTimelines() async {
    try {
      final db = await _databaseService.database;
      await AccountTimelineDao.clearAll(db);
      _logger.d('All cached account timelines cleared');
    } catch (e) {
      _logger.e('Error clearing cached account timelines: $e');
      rethrow;
    }
  }

  @override
  Future<bool> hasCachedAccountTimeline(String accountId) async {
    try {
      final db = await _databaseService.database;
      return await AccountTimelineDao.hasTimelineForAccount(db, accountId);
    } catch (e) {
      _logger.e('Error checking if cached account timeline exists: $e');
      // If table doesn't exist, return false instead of throwing
      if (e.toString().contains('no such table: account_timelines')) {
        _logger.w(
          'Account timelines table does not exist yet, returning false',
        );
        return false;
      }
      rethrow;
    }
  }

  @override
  Future<int> getCachedAccountTimelinesCount() async {
    try {
      final db = await _databaseService.database;
      return await AccountTimelineDao.getCount(db);
    } catch (e) {
      _logger.e('Error getting cached account timelines count: $e');
      // If table doesn't exist, return 0 instead of throwing
      if (e.toString().contains('no such table: account_timelines')) {
        _logger.w('Account timelines table does not exist yet, returning 0');
        return 0;
      }
      rethrow;
    }
  }
}
