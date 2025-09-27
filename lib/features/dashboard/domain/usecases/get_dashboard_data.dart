import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../entities/dashboard_data.dart';
import '../repositories/dashboard_repository.dart';

@injectable
class GetDashboardData {
  final DashboardRepository repository;

  GetDashboardData(this.repository);

  Future<Either<Failure, DashboardData>> call() async {
    return await repository.getDashboardData();
  }
}
