import '../entities/subscription.dart';

abstract class SubscriptionsRepository {
  Future<List<Subscription>> getRecentSubscriptions();
  Future<Subscription> getSubscriptionById(String subscriptionId);
  Future<List<Subscription>> getSubscriptionsForAccount(String accountId);
  Future<Subscription> createSubscription(String accountId, String planName);
}
