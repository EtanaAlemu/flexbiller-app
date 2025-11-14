import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/dashboard_kpi.dart';
import '../entities/subscription_trend.dart';
import '../entities/payment_status_overview.dart';

abstract class DashboardRepository {
  Future<Either<Failure, DashboardKPI>> getDashboardKPIs();
  Future<Either<Failure, SubscriptionTrends>> getSubscriptionTrends(int year);
  Future<Either<Failure, PaymentStatusOverviews>> getPaymentStatusOverview(
    int year,
  );
}
