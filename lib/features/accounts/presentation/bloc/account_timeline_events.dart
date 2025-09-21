import 'package:equatable/equatable.dart';

abstract class AccountTimelineEvent extends Equatable {
  final String accountId;
  const AccountTimelineEvent(this.accountId);

  @override
  List<Object> get props => [accountId];
}

class LoadAccountTimeline extends AccountTimelineEvent {
  const LoadAccountTimeline(String accountId) : super(accountId);
}

class RefreshAccountTimeline extends AccountTimelineEvent {
  const RefreshAccountTimeline(String accountId) : super(accountId);
}

class LoadAccountTimelinePaginated extends AccountTimelineEvent {
  final int offset;
  final int limit;
  
  const LoadAccountTimelinePaginated({
    required String accountId,
    this.offset = 0,
    this.limit = 50,
  }) : super(accountId);

  @override
  List<Object> get props => [accountId, offset, limit];
}

class LoadAccountTimelineByEventType extends AccountTimelineEvent {
  final String eventType;
  
  const LoadAccountTimelineByEventType({
    required String accountId,
    required this.eventType,
  }) : super(accountId);

  @override
  List<Object> get props => [accountId, eventType];
}

class LoadAccountTimelineByDateRange extends AccountTimelineEvent {
  final DateTime startDate;
  final DateTime endDate;
  
  const LoadAccountTimelineByDateRange({
    required String accountId,
    required this.startDate,
    required this.endDate,
  }) : super(accountId);

  @override
  List<Object> get props => [accountId, startDate, endDate];
}

class SearchAccountTimeline extends AccountTimelineEvent {
  final String query;
  
  const SearchAccountTimeline({
    required String accountId,
    required this.query,
  }) : super(accountId);

  @override
  List<Object> get props => [accountId, query];
}

class FilterAccountTimelineByEventType extends AccountTimelineEvent {
  final String eventType;
  
  const FilterAccountTimelineByEventType({
    required String accountId,
    required this.eventType,
  }) : super(accountId);

  @override
  List<Object> get props => [accountId, eventType];
}

class FilterAccountTimelineByDateRange extends AccountTimelineEvent {
  final DateTime startDate;
  final DateTime endDate;
  
  const FilterAccountTimelineByDateRange({
    required String accountId,
    required this.startDate,
    required this.endDate,
  }) : super(accountId);

  @override
  List<Object> get props => [accountId, startDate, endDate];
}

class ClearAccountTimelineFilters extends AccountTimelineEvent {
  const ClearAccountTimelineFilters(String accountId) : super(accountId);
}

class SyncAccountTimeline extends AccountTimelineEvent {
  const SyncAccountTimeline(String accountId) : super(accountId);
}

class ClearAccountTimeline extends AccountTimelineEvent {
  const ClearAccountTimeline(String accountId) : super(accountId);
}
