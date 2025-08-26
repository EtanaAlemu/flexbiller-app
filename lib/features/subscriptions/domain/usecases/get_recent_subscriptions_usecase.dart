import 'package:injectable/injectable.dart';
import '../entities/subscription.dart';
import '../repositories/subscriptions_repository.dart';

@injectable
class GetRecentSubscriptionsUseCase {
  final SubscriptionsRepository _repository;

  GetRecentSubscriptionsUseCase(this._repository);

  Future<List<Subscription>> call() async {
    return await _repository.getRecentSubscriptions();
  }
}
