import '../../domain/entities/dashboard_data.dart';

class DashboardDataModel extends DashboardData {
  const DashboardDataModel({
    required super.totalAccounts,
    required super.activeAccounts,
    required super.totalSubscriptions,
    required super.activeSubscriptions,
    required super.totalRevenue,
    required super.monthlyRevenue,
    required super.accountChartData,
    required super.subscriptionChartData,
    required super.revenueChartData,
    required super.accountStatusData,
    required super.subscriptionStatusData,
  });

  factory DashboardDataModel.fromMap(Map<String, dynamic> map) {
    return DashboardDataModel(
      totalAccounts: map['totalAccounts'] ?? 0,
      activeAccounts: map['activeAccounts'] ?? 0,
      totalSubscriptions: map['totalSubscriptions'] ?? 0,
      activeSubscriptions: map['activeSubscriptions'] ?? 0,
      totalRevenue: (map['totalRevenue'] ?? 0.0).toDouble(),
      monthlyRevenue: (map['monthlyRevenue'] ?? 0.0).toDouble(),
      accountChartData:
          (map['accountChartData'] as List<dynamic>?)
              ?.map((e) => AccountChartDataModel.fromMap(e))
              .toList() ??
          [],
      subscriptionChartData:
          (map['subscriptionChartData'] as List<dynamic>?)
              ?.map((e) => SubscriptionChartDataModel.fromMap(e))
              .toList() ??
          [],
      revenueChartData:
          (map['revenueChartData'] as List<dynamic>?)
              ?.map((e) => RevenueChartDataModel.fromMap(e))
              .toList() ??
          [],
      accountStatusData:
          (map['accountStatusData'] as List<dynamic>?)
              ?.map((e) => AccountStatusDataModel.fromMap(e))
              .toList() ??
          [],
      subscriptionStatusData:
          (map['subscriptionStatusData'] as List<dynamic>?)
              ?.map((e) => SubscriptionStatusDataModel.fromMap(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'totalAccounts': totalAccounts,
      'activeAccounts': activeAccounts,
      'totalSubscriptions': totalSubscriptions,
      'activeSubscriptions': activeSubscriptions,
      'totalRevenue': totalRevenue,
      'monthlyRevenue': monthlyRevenue,
      'accountChartData': accountChartData
          .map((e) => (e as AccountChartDataModel).toMap())
          .toList(),
      'subscriptionChartData': subscriptionChartData
          .map((e) => (e as SubscriptionChartDataModel).toMap())
          .toList(),
      'revenueChartData': revenueChartData
          .map((e) => (e as RevenueChartDataModel).toMap())
          .toList(),
      'accountStatusData': accountStatusData
          .map((e) => (e as AccountStatusDataModel).toMap())
          .toList(),
      'subscriptionStatusData': subscriptionStatusData
          .map((e) => (e as SubscriptionStatusDataModel).toMap())
          .toList(),
    };
  }
}

class AccountChartDataModel extends AccountChartData {
  const AccountChartDataModel({required super.month, required super.count});

  factory AccountChartDataModel.fromMap(Map<String, dynamic> map) {
    return AccountChartDataModel(
      month: map['month'] ?? '',
      count: map['count'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {'month': month, 'count': count};
  }
}

class SubscriptionChartDataModel extends SubscriptionChartData {
  const SubscriptionChartDataModel({
    required super.productName,
    required super.count,
    required super.revenue,
  });

  factory SubscriptionChartDataModel.fromMap(Map<String, dynamic> map) {
    return SubscriptionChartDataModel(
      productName: map['product_name'] ?? '',
      count: map['count'] ?? 0,
      revenue: (map['revenue'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {'product_name': productName, 'count': count, 'revenue': revenue};
  }
}

class RevenueChartDataModel extends RevenueChartData {
  const RevenueChartDataModel({required super.month, required super.revenue});

  factory RevenueChartDataModel.fromMap(Map<String, dynamic> map) {
    return RevenueChartDataModel(
      month: map['month'] ?? '',
      revenue: (map['revenue'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {'month': month, 'revenue': revenue};
  }
}

class AccountStatusDataModel extends AccountStatusData {
  const AccountStatusDataModel({
    required super.status,
    required super.count,
    required super.percentage,
  });

  factory AccountStatusDataModel.fromMap(Map<String, dynamic> map) {
    return AccountStatusDataModel(
      status: map['status'] ?? '',
      count: map['count'] ?? 0,
      percentage: (map['percentage'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {'status': status, 'count': count, 'percentage': percentage};
  }
}

class SubscriptionStatusDataModel extends SubscriptionStatusData {
  const SubscriptionStatusDataModel({
    required super.status,
    required super.count,
    required super.percentage,
  });

  factory SubscriptionStatusDataModel.fromMap(Map<String, dynamic> map) {
    return SubscriptionStatusDataModel(
      status: map['status'] ?? '',
      count: map['count'] ?? 0,
      percentage: (map['percentage'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {'status': status, 'count': count, 'percentage': percentage};
  }
}


