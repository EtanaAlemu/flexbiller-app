import 'package:equatable/equatable.dart';
import '../../../domain/entities/account_timeline.dart';

abstract class AccountTimelineState extends Equatable {
  final String accountId;
  const AccountTimelineState(this.accountId);

  @override
  List<Object> get props => [accountId];
}

class AccountTimelineInitial extends AccountTimelineState {
  const AccountTimelineInitial(String accountId) : super(accountId);
}

class AccountTimelineLoading extends AccountTimelineState {
  const AccountTimelineLoading(String accountId) : super(accountId);
}

class AccountTimelineLoaded extends AccountTimelineState {
  final AccountTimeline timeline;
  const AccountTimelineLoaded({
    required String accountId,
    required this.timeline,
  }) : super(accountId);

  @override
  List<Object> get props => [accountId, timeline];
}

class AccountTimelineFailure extends AccountTimelineState {
  final String message;
  const AccountTimelineFailure({
    required String accountId,
    required this.message,
  }) : super(accountId);

  @override
  List<Object> get props => [accountId, message];
}

class AccountTimelinePaginatedLoading extends AccountTimelineState {
  const AccountTimelinePaginatedLoading(String accountId) : super(accountId);
}

class AccountTimelinePaginatedLoaded extends AccountTimelineState {
  final AccountTimeline timeline;
  final int offset;
  final int limit;
  final bool hasMore;

  const AccountTimelinePaginatedLoaded({
    required String accountId,
    required this.timeline,
    required this.offset,
    required this.limit,
    required this.hasMore,
  }) : super(accountId);

  @override
  List<Object> get props => [accountId, timeline, offset, limit, hasMore];
}

class AccountTimelinePaginatedFailure extends AccountTimelineState {
  final String message;
  const AccountTimelinePaginatedFailure({
    required String accountId,
    required this.message,
  }) : super(accountId);

  @override
  List<Object> get props => [accountId, message];
}

class AccountTimelineFilteredLoading extends AccountTimelineState {
  const AccountTimelineFilteredLoading(String accountId) : super(accountId);
}

class AccountTimelineFilteredLoaded extends AccountTimelineState {
  final AccountTimeline timeline;
  final String filterType;
  final Map<String, dynamic> filterParams;

  const AccountTimelineFilteredLoaded({
    required String accountId,
    required this.timeline,
    required this.filterType,
    required this.filterParams,
  }) : super(accountId);

  @override
  List<Object> get props => [accountId, timeline, filterType, filterParams];
}

class AccountTimelineFilteredFailure extends AccountTimelineState {
  final String message;
  const AccountTimelineFilteredFailure({
    required String accountId,
    required this.message,
  }) : super(accountId);

  @override
  List<Object> get props => [accountId, message];
}

class AccountTimelineSearching extends AccountTimelineState {
  const AccountTimelineSearching(String accountId) : super(accountId);
}

class AccountTimelineSearchLoaded extends AccountTimelineState {
  final AccountTimeline timeline;
  final String query;

  const AccountTimelineSearchLoaded({
    required String accountId,
    required this.timeline,
    required this.query,
  }) : super(accountId);

  @override
  List<Object> get props => [accountId, timeline, query];
}

class AccountTimelineSearchFailure extends AccountTimelineState {
  final String message;
  const AccountTimelineSearchFailure({
    required String accountId,
    required this.message,
  }) : super(accountId);

  @override
  List<Object> get props => [accountId, message];
}

class AccountTimelineRefreshing extends AccountTimelineState {
  const AccountTimelineRefreshing(String accountId) : super(accountId);
}

class AccountTimelineRefreshed extends AccountTimelineState {
  final AccountTimeline timeline;
  const AccountTimelineRefreshed({
    required String accountId,
    required this.timeline,
  }) : super(accountId);

  @override
  List<Object> get props => [accountId, timeline];
}

class AccountTimelineRefreshFailure extends AccountTimelineState {
  final String message;
  const AccountTimelineRefreshFailure({
    required String accountId,
    required this.message,
  }) : super(accountId);

  @override
  List<Object> get props => [accountId, message];
}

class AccountTimelineSyncing extends AccountTimelineState {
  const AccountTimelineSyncing(String accountId) : super(accountId);
}

class AccountTimelineSynced extends AccountTimelineState {
  final AccountTimeline timeline;
  const AccountTimelineSynced({
    required String accountId,
    required this.timeline,
  }) : super(accountId);

  @override
  List<Object> get props => [accountId, timeline];
}

class AccountTimelineSyncFailure extends AccountTimelineState {
  final String message;
  const AccountTimelineSyncFailure({
    required String accountId,
    required this.message,
  }) : super(accountId);

  @override
  List<Object> get props => [accountId, message];
}
