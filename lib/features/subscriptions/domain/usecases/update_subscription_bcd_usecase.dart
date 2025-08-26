import 'package:injectable/injectable.dart';
import '../entities/subscription_bcd_update.dart';
import '../repositories/subscriptions_repository.dart';

@injectable
class UpdateSubscriptionBcdUseCase {
  final SubscriptionsRepository _repository;

  UpdateSubscriptionBcdUseCase(this._repository);

  Future<Map<String, dynamic>> call({
    required String subscriptionId,
    required SubscriptionBcdUpdate bcdUpdate,
  }) async {
    return await _repository.updateSubscriptionBcd(
      subscriptionId: subscriptionId,
      bcdUpdate: bcdUpdate,
    );
  }
}
