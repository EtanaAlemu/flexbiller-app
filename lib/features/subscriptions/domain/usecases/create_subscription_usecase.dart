import 'package:injectable/injectable.dart';
import '../entities/subscription.dart';
import '../repositories/subscriptions_repository.dart';

@injectable
class CreateSubscriptionUseCase {
  final SubscriptionsRepository _repository;

  CreateSubscriptionUseCase(this._repository);

  Future<Subscription> call(String accountId, String planName) async {
    return await _repository.createSubscription(accountId, planName);
  }
}
