part of 'dashboard_bloc.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {}

// KPI States
class DashboardKPILoading extends DashboardState {}

class DashboardKPILoaded extends DashboardState {
  final DashboardKPI kpis;

  const DashboardKPILoaded(this.kpis);

  @override
  List<Object> get props => [kpis];
}

class DashboardKPIError extends DashboardState {
  final String message;

  const DashboardKPIError(this.message);

  @override
  List<Object> get props => [message];
}

// Subscription Trends States
class SubscriptionTrendsLoading extends DashboardState {
  final DashboardKPI? kpis; // Preserve KPIs if available

  const SubscriptionTrendsLoading({this.kpis});

  @override
  List<Object?> get props => [kpis];
}

class SubscriptionTrendsLoaded extends DashboardState {
  final SubscriptionTrends trends;
  final DashboardKPI? kpis; // Preserve KPIs if available

  const SubscriptionTrendsLoaded(this.trends, {this.kpis});

  @override
  List<Object?> get props => [trends, kpis];
}

class SubscriptionTrendsError extends DashboardState {
  final String message;
  final DashboardKPI? kpis; // Preserve KPIs if available

  const SubscriptionTrendsError(this.message, {this.kpis});

  @override
  List<Object?> get props => [message, kpis];
}

// Payment Status Overview States
class PaymentStatusOverviewLoading extends DashboardState {
  final DashboardKPI? kpis; // Preserve KPIs if available

  const PaymentStatusOverviewLoading({this.kpis});

  @override
  List<Object?> get props => [kpis];
}

class PaymentStatusOverviewLoaded extends DashboardState {
  final PaymentStatusOverviews overview;
  final DashboardKPI? kpis; // Preserve KPIs if available

  const PaymentStatusOverviewLoaded(this.overview, {this.kpis});

  @override
  List<Object?> get props => [overview, kpis];
}

class PaymentStatusOverviewError extends DashboardState {
  final String message;
  final DashboardKPI? kpis; // Preserve KPIs if available

  const PaymentStatusOverviewError(this.message, {this.kpis});

  @override
  List<Object?> get props => [message, kpis];
}
