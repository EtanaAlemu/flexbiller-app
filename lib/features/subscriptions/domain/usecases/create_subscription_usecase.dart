import 'package:injectable/injectable.dart';
import '../entities/subscription.dart';
import '../repositories/subscriptions_repository.dart';

@injectable
class CreateSubscriptionUseCase {
  final SubscriptionsRepository _repository;

  CreateSubscriptionUseCase(this._repository);

  Future<Subscription> call({
    required String accountId,
    required String planName,
  }) async {
    return await _repository.createSubscription(
      accountId: accountId,
      planName: planName,
    );
  }
}
