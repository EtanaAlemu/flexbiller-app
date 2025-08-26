import 'package:injectable/injectable.dart';
import '../entities/subscription_blocking_state.dart';
import '../repositories/subscriptions_repository.dart';

@injectable
class BlockSubscriptionUseCase {
  final SubscriptionsRepository _repository;

  BlockSubscriptionUseCase(this._repository);

  Future<SubscriptionBlockingState> call({
    required String subscriptionId,
    required Map<String, dynamic> blockingData,
  }) async {
    return await _repository.blockSubscription(
      subscriptionId: subscriptionId,
      blockingData: blockingData,
    );
  }
}
