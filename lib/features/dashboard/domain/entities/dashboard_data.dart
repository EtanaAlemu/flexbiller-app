import 'package:equatable/equatable.dart';

class DashboardData extends Equatable {
  final int totalAccounts;
  final int activeAccounts;
  final int totalSubscriptions;
  final int activeSubscriptions;
  final double totalRevenue;
  final double monthlyRevenue;
  final List<AccountChartData> accountChartData;
  final List<SubscriptionChartData> subscriptionChartData;
  final List<RevenueChartData> revenueChartData;
  final List<AccountStatusData> accountStatusData;
  final List<SubscriptionStatusData> subscriptionStatusData;

  const DashboardData({
    required this.totalAccounts,
    required this.activeAccounts,
    required this.totalSubscriptions,
    required this.activeSubscriptions,
    required this.totalRevenue,
    required this.monthlyRevenue,
    required this.accountChartData,
    required this.subscriptionChartData,
    required this.revenueChartData,
    required this.accountStatusData,
    required this.subscriptionStatusData,
  });

  @override
  List<Object?> get props => [
    totalAccounts,
    activeAccounts,
    totalSubscriptions,
    activeSubscriptions,
    totalRevenue,
    monthlyRevenue,
    accountChartData,
    subscriptionChartData,
    revenueChartData,
    accountStatusData,
    subscriptionStatusData,
  ];
}

class AccountChartData extends Equatable {
  final String month;
  final int count;

  const AccountChartData({required this.month, required this.count});

  @override
  List<Object?> get props => [month, count];
}

class SubscriptionChartData extends Equatable {
  final String productName;
  final int count;
  final double revenue;

  const SubscriptionChartData({
    required this.productName,
    required this.count,
    required this.revenue,
  });

  @override
  List<Object?> get props => [productName, count, revenue];
}

class RevenueChartData extends Equatable {
  final String month;
  final double revenue;

  const RevenueChartData({required this.month, required this.revenue});

  @override
  List<Object?> get props => [month, revenue];
}

class AccountStatusData extends Equatable {
  final String status;
  final int count;
  final double percentage;

  const AccountStatusData({
    required this.status,
    required this.count,
    required this.percentage,
  });

  @override
  List<Object?> get props => [status, count, percentage];
}

class SubscriptionStatusData extends Equatable {
  final String status;
  final int count;
  final double percentage;

  const SubscriptionStatusData({
    required this.status,
    required this.count,
    required this.percentage,
  });

  @override
  List<Object?> get props => [status, count, percentage];
}


