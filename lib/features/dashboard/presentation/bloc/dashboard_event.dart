part of 'dashboard_bloc.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object> get props => [];
}

class LoadDashboardKPIs extends DashboardEvent {
  const LoadDashboardKPIs();
}

class LoadSubscriptionTrends extends DashboardEvent {
  final int year;

  const LoadSubscriptionTrends(this.year);

  @override
  List<Object> get props => [year];
}

class LoadPaymentStatusOverview extends DashboardEvent {
  final int year;

  const LoadPaymentStatusOverview(this.year);

  @override
  List<Object> get props => [year];
}
