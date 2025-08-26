import 'package:injectable/injectable.dart';
import '../entities/subscription.dart';
import '../repositories/subscriptions_repository.dart';

@injectable
class GetSubscriptionsForAccountUseCase {
  final SubscriptionsRepository _repository;

  GetSubscriptionsForAccountUseCase(this._repository);

  Future<List<Subscription>> call(String accountId) async {
    return await _repository.getSubscriptionsForAccount(accountId);
  }
}
