import 'package:injectable/injectable.dart';
import '../entities/subscription_custom_field.dart';
import '../repositories/subscriptions_repository.dart';

@injectable
class GetSubscriptionCustomFieldsUseCase {
  final SubscriptionsRepository _repository;

  GetSubscriptionCustomFieldsUseCase(this._repository);

  Future<List<SubscriptionCustomField>> call(String subscriptionId) async {
    return await _repository.getSubscriptionCustomFields(subscriptionId);
  }
}

