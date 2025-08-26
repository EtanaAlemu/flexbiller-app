import 'package:injectable/injectable.dart';
import '../repositories/subscriptions_repository.dart';

@injectable
class CancelSubscriptionUseCase {
  final SubscriptionsRepository _repository;

  CancelSubscriptionUseCase(this._repository);

  Future<void> call(String id) async {
    return await _repository.cancelSubscription(id);
  }
}
