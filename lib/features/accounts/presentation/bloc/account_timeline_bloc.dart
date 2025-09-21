import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import '../../domain/entities/account_timeline.dart';
import '../../domain/repositories/account_timeline_repository.dart';
import '../../domain/usecases/get_account_timeline_usecase.dart';
import 'account_timeline_events.dart';
import 'account_timeline_states.dart';

@injectable
class AccountTimelineBloc
    extends Bloc<AccountTimelineEvent, AccountTimelineState> {
  final GetAccountTimelineUseCase _getAccountTimelineUseCase;
  final AccountTimelineRepository _accountTimelineRepository;
  final Logger _logger = Logger();

  StreamSubscription<AccountTimeline>? _accountTimelineSubscription;
  String? _currentAccountId;

  AccountTimelineBloc(
    this._getAccountTimelineUseCase,
    this._accountTimelineRepository,
  ) : super(const AccountTimelineInitial('')) {
    on<LoadAccountTimeline>(_onLoadAccountTimeline);
    on<RefreshAccountTimeline>(_onRefreshAccountTimeline);
    on<LoadAccountTimelinePaginated>(_onLoadAccountTimelinePaginated);
    on<LoadAccountTimelineByEventType>(_onLoadAccountTimelineByEventType);
    on<LoadAccountTimelineByDateRange>(_onLoadAccountTimelineByDateRange);
    on<SearchAccountTimeline>(_onSearchAccountTimeline);
    on<FilterAccountTimelineByEventType>(_onFilterAccountTimelineByEventType);
    on<FilterAccountTimelineByDateRange>(_onFilterAccountTimelineByDateRange);
    on<ClearAccountTimelineFilters>(_onClearAccountTimelineFilters);
    on<SyncAccountTimeline>(_onSyncAccountTimeline);
    on<ClearAccountTimeline>(_onClearAccountTimeline);
  }

  void _initializeStreamSubscriptions() {
    _logger.d('Initializing stream subscriptions for account timeline');
    _accountTimelineSubscription?.cancel();
    _accountTimelineSubscription =
        _accountTimelineRepository.accountTimelineStream.listen(
      (updatedTimeline) {
        _logger.d(
          'Stream update received for timeline, currentAccountId: $_currentAccountId',
        );
        if (_currentAccountId != null &&
            updatedTimeline.accountId == _currentAccountId) {
          final currentState = state;
          if (currentState is AccountTimelineLoaded) {
            emit(
              AccountTimelineLoaded(
                accountId: _currentAccountId!,
                timeline: updatedTimeline,
              ),
            );
          } else if (currentState is AccountTimelineLoading) {
            emit(
              AccountTimelineLoaded(
                accountId: _currentAccountId!,
                timeline: updatedTimeline,
              ),
            );
          }
        }
      },
      onError: (error) {
        _logger.e('Stream error for account timeline: $error');
        if (_currentAccountId != null) {
          emit(
            AccountTimelineFailure(
              accountId: _currentAccountId!,
              message: 'Stream error: $error',
            ),
          );
        }
      },
    );
  }

  Future<void> _onLoadAccountTimeline(
    LoadAccountTimeline event,
    Emitter<AccountTimelineState> emit,
  ) async {
    _logger.d(
      'LoadAccountTimeline called for accountId: ${event.accountId}',
    );
    _currentAccountId = event.accountId;

    if (_accountTimelineSubscription == null) {
      _initializeStreamSubscriptions();
    }

    emit(AccountTimelineLoading(event.accountId));
    try {
      final timeline = await _getAccountTimelineUseCase(event.accountId);
      emit(
        AccountTimelineLoaded(
          accountId: event.accountId,
          timeline: timeline,
        ),
      );
    } catch (e) {
      _logger.e('Error loading account timeline: $e');
      emit(
        AccountTimelineFailure(
          accountId: event.accountId,
          message: 'Failed to load timeline: $e',
        ),
      );
    }
  }

  Future<void> _onRefreshAccountTimeline(
    RefreshAccountTimeline event,
    Emitter<AccountTimelineState> emit,
  ) async {
    _logger.d(
      'RefreshAccountTimeline called for accountId: ${event.accountId}',
    );
    _currentAccountId = event.accountId;
    emit(AccountTimelineRefreshing(event.accountId));
    try {
      final timeline = await _getAccountTimelineUseCase(event.accountId);
      emit(
        AccountTimelineRefreshed(
          accountId: event.accountId,
          timeline: timeline,
        ),
      );
    } catch (e) {
      _logger.e('Error refreshing account timeline: $e');
      emit(
        AccountTimelineRefreshFailure(
          accountId: event.accountId,
          message: 'Failed to refresh timeline: $e',
        ),
      );
    }
  }

  Future<void> _onLoadAccountTimelinePaginated(
    LoadAccountTimelinePaginated event,
    Emitter<AccountTimelineState> emit,
  ) async {
    _logger.d(
      'LoadAccountTimelinePaginated called for accountId: ${event.accountId}',
    );
    _currentAccountId = event.accountId;
    emit(AccountTimelinePaginatedLoading(event.accountId));
    try {
      final timeline = await _accountTimelineRepository.getAccountTimelinePaginated(
        event.accountId,
        offset: event.offset,
        limit: event.limit,
      );
      emit(
        AccountTimelinePaginatedLoaded(
          accountId: event.accountId,
          timeline: timeline,
          offset: event.offset,
          limit: event.limit,
          hasMore: timeline.events.length == event.limit,
        ),
      );
    } catch (e) {
      _logger.e('Error loading paginated account timeline: $e');
      emit(
        AccountTimelinePaginatedFailure(
          accountId: event.accountId,
          message: 'Failed to load paginated timeline: $e',
        ),
      );
    }
  }

  Future<void> _onLoadAccountTimelineByEventType(
    LoadAccountTimelineByEventType event,
    Emitter<AccountTimelineState> emit,
  ) async {
    _logger.d(
      'LoadAccountTimelineByEventType called for accountId: ${event.accountId}, eventType: ${event.eventType}',
    );
    _currentAccountId = event.accountId;
    emit(AccountTimelineFilteredLoading(event.accountId));
    try {
      final timeline = await _accountTimelineRepository.getAccountTimelineByEventType(
        event.accountId,
        event.eventType,
      );
      emit(
        AccountTimelineFilteredLoaded(
          accountId: event.accountId,
          timeline: timeline,
          filterType: 'eventType',
          filterParams: {'eventType': event.eventType},
        ),
      );
    } catch (e) {
      _logger.e('Error loading account timeline by event type: $e');
      emit(
        AccountTimelineFilteredFailure(
          accountId: event.accountId,
          message: 'Failed to load timeline by event type: $e',
        ),
      );
    }
  }

  Future<void> _onLoadAccountTimelineByDateRange(
    LoadAccountTimelineByDateRange event,
    Emitter<AccountTimelineState> emit,
  ) async {
    _logger.d(
      'LoadAccountTimelineByDateRange called for accountId: ${event.accountId}',
    );
    _currentAccountId = event.accountId;
    emit(AccountTimelineFilteredLoading(event.accountId));
    try {
      final timeline = await _accountTimelineRepository.getAccountTimelineByDateRange(
        event.accountId,
        event.startDate,
        event.endDate,
      );
      emit(
        AccountTimelineFilteredLoaded(
          accountId: event.accountId,
          timeline: timeline,
          filterType: 'dateRange',
          filterParams: {
            'startDate': event.startDate.toIso8601String(),
            'endDate': event.endDate.toIso8601String(),
          },
        ),
      );
    } catch (e) {
      _logger.e('Error loading account timeline by date range: $e');
      emit(
        AccountTimelineFilteredFailure(
          accountId: event.accountId,
          message: 'Failed to load timeline by date range: $e',
        ),
      );
    }
  }

  Future<void> _onSearchAccountTimeline(
    SearchAccountTimeline event,
    Emitter<AccountTimelineState> emit,
  ) async {
    _logger.d(
      'SearchAccountTimeline called for accountId: ${event.accountId}, query: ${event.query}',
    );
    _currentAccountId = event.accountId;
    emit(AccountTimelineSearching(event.accountId));
    try {
      // For now, we'll use the basic timeline and filter client-side
      // In a real implementation, you might want to add search to the repository
      final timeline = await _getAccountTimelineUseCase(event.accountId);
      
      // Filter events based on search query
      final filteredEvents = timeline.events.where((timelineEvent) {
        return timelineEvent.title.toLowerCase().contains(event.query.toLowerCase()) ||
               timelineEvent.description.toLowerCase().contains(event.query.toLowerCase()) ||
               timelineEvent.eventType.toLowerCase().contains(event.query.toLowerCase());
      }).toList();
      
      final filteredTimeline = timeline.copyWith(events: filteredEvents);
      
      emit(
        AccountTimelineSearchLoaded(
          accountId: event.accountId,
          timeline: filteredTimeline,
          query: event.query,
        ),
      );
    } catch (e) {
      _logger.e('Error searching account timeline: $e');
      emit(
        AccountTimelineSearchFailure(
          accountId: event.accountId,
          message: 'Failed to search timeline: $e',
        ),
      );
    }
  }

  Future<void> _onFilterAccountTimelineByEventType(
    FilterAccountTimelineByEventType event,
    Emitter<AccountTimelineState> emit,
  ) async {
    _logger.d(
      'FilterAccountTimelineByEventType called for accountId: ${event.accountId}, eventType: ${event.eventType}',
    );
    _currentAccountId = event.accountId;
    emit(AccountTimelineFilteredLoading(event.accountId));
    try {
      final timeline = await _accountTimelineRepository.getAccountTimelineByEventType(
        event.accountId,
        event.eventType,
      );
      emit(
        AccountTimelineFilteredLoaded(
          accountId: event.accountId,
          timeline: timeline,
          filterType: 'eventType',
          filterParams: {'eventType': event.eventType},
        ),
      );
    } catch (e) {
      _logger.e('Error filtering account timeline by event type: $e');
      emit(
        AccountTimelineFilteredFailure(
          accountId: event.accountId,
          message: 'Failed to filter timeline by event type: $e',
        ),
      );
    }
  }

  Future<void> _onFilterAccountTimelineByDateRange(
    FilterAccountTimelineByDateRange event,
    Emitter<AccountTimelineState> emit,
  ) async {
    _logger.d(
      'FilterAccountTimelineByDateRange called for accountId: ${event.accountId}',
    );
    _currentAccountId = event.accountId;
    emit(AccountTimelineFilteredLoading(event.accountId));
    try {
      final timeline = await _accountTimelineRepository.getAccountTimelineByDateRange(
        event.accountId,
        event.startDate,
        event.endDate,
      );
      emit(
        AccountTimelineFilteredLoaded(
          accountId: event.accountId,
          timeline: timeline,
          filterType: 'dateRange',
          filterParams: {
            'startDate': event.startDate.toIso8601String(),
            'endDate': event.endDate.toIso8601String(),
          },
        ),
      );
    } catch (e) {
      _logger.e('Error filtering account timeline by date range: $e');
      emit(
        AccountTimelineFilteredFailure(
          accountId: event.accountId,
          message: 'Failed to filter timeline by date range: $e',
        ),
      );
    }
  }

  void _onClearAccountTimelineFilters(
    ClearAccountTimelineFilters event,
    Emitter<AccountTimelineState> emit,
  ) {
    _logger.d(
      'ClearAccountTimelineFilters called for accountId: ${event.accountId}',
    );
    _currentAccountId = event.accountId;
    // Reload the basic timeline without filters
    add(LoadAccountTimeline(event.accountId));
  }

  Future<void> _onSyncAccountTimeline(
    SyncAccountTimeline event,
    Emitter<AccountTimelineState> emit,
  ) async {
    _logger.d(
      'SyncAccountTimeline called for accountId: ${event.accountId}',
    );
    _currentAccountId = event.accountId;
    emit(AccountTimelineSyncing(event.accountId));
    try {
      final timeline = await _getAccountTimelineUseCase(event.accountId);
      emit(
        AccountTimelineSynced(
          accountId: event.accountId,
          timeline: timeline,
        ),
      );
    } catch (e) {
      _logger.e('Error syncing account timeline: $e');
      emit(
        AccountTimelineSyncFailure(
          accountId: event.accountId,
          message: 'Failed to sync timeline: $e',
        ),
      );
    }
  }

  void _onClearAccountTimeline(
    ClearAccountTimeline event,
    Emitter<AccountTimelineState> emit,
  ) {
    _logger.d(
      'ClearAccountTimeline called for accountId: ${event.accountId}',
    );
    emit(AccountTimelineInitial(event.accountId));
  }

  @override
  Future<void> close() {
    _accountTimelineSubscription?.cancel();
    return super.close();
  }
}
