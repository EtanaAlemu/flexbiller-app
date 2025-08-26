import 'package:injectable/injectable.dart';
import '../entities/subscription.dart';
import '../repositories/subscriptions_repository.dart';

@injectable
class UpdateSubscriptionUseCase {
  final SubscriptionsRepository _repository;

  UpdateSubscriptionUseCase(this._repository);

  Future<Subscription> call(String subscriptionId, Map<String, dynamic> updateData) async {
    return await _repository.updateSubscription(subscriptionId, updateData);
  }
}
