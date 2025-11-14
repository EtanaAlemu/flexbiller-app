import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../entities/payment_status_overview.dart';
import '../repositories/dashboard_repository.dart';

@injectable
class GetPaymentStatusOverview {
  final DashboardRepository repository;

  GetPaymentStatusOverview(this.repository);

  Future<Either<Failure, PaymentStatusOverviews>> call(int year) async {
    return await repository.getPaymentStatusOverview(year);
  }
}
