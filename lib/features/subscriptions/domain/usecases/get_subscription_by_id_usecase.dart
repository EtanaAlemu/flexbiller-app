import 'package:injectable/injectable.dart';
import '../entities/subscription.dart';
import '../repositories/subscriptions_repository.dart';

@injectable
class GetSubscriptionByIdUseCase {
  final SubscriptionsRepository _repository;

  GetSubscriptionByIdUseCase(this._repository);

  Future<Subscription> call(String subscriptionId) async {
    return await _repository.getSubscriptionById(subscriptionId);
  }
}
