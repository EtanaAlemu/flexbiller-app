import 'package:injectable/injectable.dart';
import '../repositories/subscriptions_repository.dart';

@injectable
class RemoveSubscriptionCustomFieldsUseCase {
  final SubscriptionsRepository _repository;

  RemoveSubscriptionCustomFieldsUseCase(this._repository);

  Future<Map<String, dynamic>> call({
    required String subscriptionId,
    required String customFieldIds,
  }) async {
    return await _repository.removeSubscriptionCustomFields(
      subscriptionId: subscriptionId,
      customFieldIds: customFieldIds,
    );
  }
}

