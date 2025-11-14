import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../entities/subscription_trend.dart';
import '../repositories/dashboard_repository.dart';

@injectable
class GetSubscriptionTrends {
  final DashboardRepository repository;

  GetSubscriptionTrends(this.repository);

  Future<Either<Failure, SubscriptionTrends>> call(int year) async {
    return await repository.getSubscriptionTrends(year);
  }
}
