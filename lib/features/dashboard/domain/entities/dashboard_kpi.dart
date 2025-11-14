import 'package:equatable/equatable.dart';

class DashboardKPI extends Equatable {
  final KPIMetric activeSubscriptions;
  final KPIMetric pendingInvoices;
  final KPIMetric failedPayments;
  final RevenueKPIMetric monthlyRevenue;

  const DashboardKPI({
    required this.activeSubscriptions,
    required this.pendingInvoices,
    required this.failedPayments,
    required this.monthlyRevenue,
  });

  @override
  List<Object?> get props => [
    activeSubscriptions,
    pendingInvoices,
    failedPayments,
    monthlyRevenue,
  ];
}

class KPIMetric extends Equatable {
  final int value;
  final String change;
  final String changePercent;

  const KPIMetric({
    required this.value,
    required this.change,
    required this.changePercent,
  });

  @override
  List<Object?> get props => [value, change, changePercent];
}

class RevenueKPIMetric extends Equatable {
  final String value;
  final String change;
  final String changePercent;
  final String currency;

  const RevenueKPIMetric({
    required this.value,
    required this.change,
    required this.changePercent,
    required this.currency,
  });

  @override
  List<Object?> get props => [value, change, changePercent, currency];
}
