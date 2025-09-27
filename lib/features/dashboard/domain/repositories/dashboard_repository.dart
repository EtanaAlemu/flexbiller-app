import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/dashboard_data.dart';

abstract class DashboardRepository {
  Future<Either<Failure, DashboardData>> getDashboardData();
  Future<Either<Failure, List<AccountChartData>>> getAccountChartData();
  Future<Either<Failure, List<SubscriptionChartData>>>
  getSubscriptionChartData();
  Future<Either<Failure, List<RevenueChartData>>> getRevenueChartData();
}


