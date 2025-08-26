import 'package:injectable/injectable.dart';
import '../entities/subscription.dart';
import '../repositories/subscriptions_repository.dart';

@injectable
class UpdateSubscriptionUseCase {
  final SubscriptionsRepository _repository;

  UpdateSubscriptionUseCase(this._repository);

  Future<Subscription> call({
    required String id,
    required Map<String, dynamic> payload,
  }) async {
    return await _repository.updateSubscription(
      id: id,
      payload: payload,
    );
  }
}
