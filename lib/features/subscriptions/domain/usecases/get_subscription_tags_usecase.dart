import 'package:injectable/injectable.dart';
import '../repositories/subscriptions_repository.dart';

@injectable
class GetSubscriptionTagsUseCase {
  final SubscriptionsRepository _repository;

  GetSubscriptionTagsUseCase(this._repository);

  Future<List<String>> call(String subscriptionId) async {
    return await _repository.getSubscriptionTags(subscriptionId);
  }
}
