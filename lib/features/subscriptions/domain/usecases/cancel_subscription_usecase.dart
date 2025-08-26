import 'package:injectable/injectable.dart';
import '../repositories/subscriptions_repository.dart';

@injectable
class CancelSubscriptionUseCase {
  final SubscriptionsRepository _repository;

  CancelSubscriptionUseCase(this._repository);

  Future<Map<String, dynamic>> call(String subscriptionId) async {
    return await _repository.cancelSubscription(subscriptionId);
  }
}
