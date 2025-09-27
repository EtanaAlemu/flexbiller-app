import 'package:injectable/injectable.dart';
import '../models/dashboard_data_model.dart';
import 'dashboard_local_data_source.dart';

@LazySingleton(as: DashboardLocalDataSource)
class DashboardMockDataSource implements DashboardLocalDataSource {
  @override
  Future<DashboardDataModel> getDashboardData() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    return DashboardDataModel(
      totalAccounts: 150,
      activeAccounts: 120,
      totalSubscriptions: 300,
      activeSubscriptions: 250,
      totalRevenue: 125000.0,
      monthlyRevenue: 15000.0,
      accountChartData: [
        const AccountChartDataModel(month: '2024-01', count: 10),
        const AccountChartDataModel(month: '2024-02', count: 15),
        const AccountChartDataModel(month: '2024-03', count: 20),
        const AccountChartDataModel(month: '2024-04', count: 25),
        const AccountChartDataModel(month: '2024-05', count: 30),
        const AccountChartDataModel(month: '2024-06', count: 35),
      ],
      subscriptionChartData: [
        const SubscriptionChartDataModel(
          productName: 'Basic Plan',
          count: 100,
          revenue: 50000.0,
        ),
        const SubscriptionChartDataModel(
          productName: 'Pro Plan',
          count: 80,
          revenue: 40000.0,
        ),
        const SubscriptionChartDataModel(
          productName: 'Enterprise',
          count: 20,
          revenue: 35000.0,
        ),
      ],
      revenueChartData: [
        const RevenueChartDataModel(month: '2024-01', revenue: 10000.0),
        const RevenueChartDataModel(month: '2024-02', revenue: 12000.0),
        const RevenueChartDataModel(month: '2024-03', revenue: 15000.0),
        const RevenueChartDataModel(month: '2024-04', revenue: 18000.0),
        const RevenueChartDataModel(month: '2024-05', revenue: 20000.0),
        const RevenueChartDataModel(month: '2024-06', revenue: 22000.0),
      ],
      accountStatusData: [
        const AccountStatusDataModel(
          status: 'Active',
          count: 120,
          percentage: 80.0,
        ),
        const AccountStatusDataModel(
          status: 'Inactive',
          count: 30,
          percentage: 20.0,
        ),
      ],
      subscriptionStatusData: [
        const SubscriptionStatusDataModel(
          status: 'Active',
          count: 250,
          percentage: 83.3,
        ),
        const SubscriptionStatusDataModel(
          status: 'Cancelled',
          count: 30,
          percentage: 10.0,
        ),
        const SubscriptionStatusDataModel(
          status: 'Paused',
          count: 20,
          percentage: 6.7,
        ),
      ],
    );
  }

  @override
  Future<List<AccountChartDataModel>> getAccountChartData() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return [
      const AccountChartDataModel(month: '2024-01', count: 10),
      const AccountChartDataModel(month: '2024-02', count: 15),
      const AccountChartDataModel(month: '2024-03', count: 20),
      const AccountChartDataModel(month: '2024-04', count: 25),
      const AccountChartDataModel(month: '2024-05', count: 30),
      const AccountChartDataModel(month: '2024-06', count: 35),
    ];
  }

  @override
  Future<List<SubscriptionChartDataModel>> getSubscriptionChartData() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return [
      const SubscriptionChartDataModel(
        productName: 'Basic Plan',
        count: 100,
        revenue: 50000.0,
      ),
      const SubscriptionChartDataModel(
        productName: 'Pro Plan',
        count: 80,
        revenue: 40000.0,
      ),
      const SubscriptionChartDataModel(
        productName: 'Enterprise',
        count: 20,
        revenue: 35000.0,
      ),
    ];
  }

  @override
  Future<List<RevenueChartDataModel>> getRevenueChartData() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return [
      const RevenueChartDataModel(month: '2024-01', revenue: 10000.0),
      const RevenueChartDataModel(month: '2024-02', revenue: 12000.0),
      const RevenueChartDataModel(month: '2024-03', revenue: 15000.0),
      const RevenueChartDataModel(month: '2024-04', revenue: 18000.0),
      const RevenueChartDataModel(month: '2024-05', revenue: 20000.0),
      const RevenueChartDataModel(month: '2024-06', revenue: 22000.0),
    ];
  }
}
