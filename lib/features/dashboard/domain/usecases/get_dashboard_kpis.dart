import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../entities/dashboard_kpi.dart';
import '../repositories/dashboard_repository.dart';

@injectable
class GetDashboardKPIs {
  final DashboardRepository repository;

  GetDashboardKPIs(this.repository);

  Future<Either<Failure, DashboardKPI>> call() async {
    return await repository.getDashboardKPIs();
  }
}
