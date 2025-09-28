import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/errors/failures.dart';
import '../entities/plan.dart';
import '../repositories/plans_repository.dart';

@injectable
class GetPlanById {
  final PlansRepository repository;

  GetPlanById(this.repository);

  Future<Either<Failure, Plan>> call(String planId) async {
    if (planId.isEmpty) {
      return Left(ValidationFailure('Plan ID cannot be empty'));
    }

    return await repository.getPlanById(planId);
  }
}
