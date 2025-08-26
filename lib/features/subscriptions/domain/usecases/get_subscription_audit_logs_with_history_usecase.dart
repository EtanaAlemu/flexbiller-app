import 'package:injectable/injectable.dart';
import '../entities/subscription_audit_log.dart';
import '../repositories/subscriptions_repository.dart';

@injectable
class GetSubscriptionAuditLogsWithHistoryUseCase {
  final SubscriptionsRepository _repository;

  GetSubscriptionAuditLogsWithHistoryUseCase(this._repository);

  Future<List<SubscriptionAuditLog>> call(String subscriptionId) async {
    return await _repository.getSubscriptionAuditLogsWithHistory(subscriptionId);
  }
}
