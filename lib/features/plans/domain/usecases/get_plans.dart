import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/errors/failures.dart';
import '../entities/plan.dart';
import '../repositories/plans_repository.dart';

@injectable
class GetPlans {
  final PlansRepository repository;

  GetPlans(this.repository);

  Future<Either<Failure, List<Plan>>> call() async {
    return await repository.getPlans();
  }
}
