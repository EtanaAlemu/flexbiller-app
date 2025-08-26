import 'package:injectable/injectable.dart';
import '../entities/subscription_custom_field.dart';
import '../repositories/subscriptions_repository.dart';

@injectable
class UpdateSubscriptionCustomFieldsUseCase {
  final SubscriptionsRepository _repository;

  UpdateSubscriptionCustomFieldsUseCase(this._repository);

  Future<List<SubscriptionCustomField>> call({
    required String subscriptionId,
    required List<Map<String, String>> customFields,
  }) async {
    return await _repository.updateSubscriptionCustomFields(
      subscriptionId: subscriptionId,
      customFields: customFields,
    );
  }
}

