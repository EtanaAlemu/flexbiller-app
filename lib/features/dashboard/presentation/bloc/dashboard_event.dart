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

// Stream update events
class KPIsStreamUpdate extends DashboardEvent {
  final DashboardKPI kpis;

  const KPIsStreamUpdate(this.kpis);

  @override
  List<Object> get props => [kpis];
}

class SubscriptionTrendsStreamUpdate extends DashboardEvent {
  final SubscriptionTrends trends;
  final int year;
  final DashboardKPI? preservedKPIs;

  const SubscriptionTrendsStreamUpdate(
    this.trends,
    this.year, {
    this.preservedKPIs,
  });

  @override
  List<Object> get props => [
    trends,
    year,
    if (preservedKPIs != null) preservedKPIs!,
  ];
}

class PaymentStatusOverviewStreamUpdate extends DashboardEvent {
  final PaymentStatusOverviews overview;
  final int year;
  final DashboardKPI? preservedKPIs;

  const PaymentStatusOverviewStreamUpdate(
    this.overview,
    this.year, {
    this.preservedKPIs,
  });

  @override
  List<Object> get props => [
    overview,
    year,
    if (preservedKPIs != null) preservedKPIs!,
  ];
}
