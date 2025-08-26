import 'package:injectable/injectable.dart';
import '../entities/subscription_addon_product.dart';
import '../repositories/subscriptions_repository.dart';

@injectable
class CreateSubscriptionWithAddOnsUseCase {
  final SubscriptionsRepository _repository;

  CreateSubscriptionWithAddOnsUseCase(this._repository);

  Future<Map<String, dynamic>> call({
    required List<SubscriptionAddonProduct> addonProducts,
  }) async {
    return await _repository.createSubscriptionWithAddOns(
      addonProducts: addonProducts,
    );
  }
}
