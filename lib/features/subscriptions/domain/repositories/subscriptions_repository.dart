import '../entities/subscription.dart';
import '../entities/subscription_custom_field.dart';
import '../entities/subscription_blocking_state.dart';

abstract class SubscriptionsRepository {
  Future<List<Subscription>> getRecentSubscriptions();
  Future<Subscription> getSubscriptionById(String id);
  Future<List<Subscription>> getSubscriptionsForAccount(String accountId);
  Future<Subscription> createSubscription({
    required String accountId,
    required String planName,
  });
  Future<Subscription> updateSubscription({
    required String id,
    required Map<String, dynamic> payload,
  });
  Future<void> cancelSubscription(String id);
  
  // Custom Fields methods
  Future<List<SubscriptionCustomField>> addSubscriptionCustomFields({
    required String subscriptionId,
    required List<Map<String, String>> customFields,
  });
  Future<List<SubscriptionCustomField>> getSubscriptionCustomFields(String subscriptionId);
  Future<List<SubscriptionCustomField>> updateSubscriptionCustomFields({
    required String subscriptionId,
    required List<Map<String, String>> customFields,
  });
  Future<Map<String, dynamic>> removeSubscriptionCustomFields({
    required String subscriptionId,
    required String customFieldIds,
  });

  // Block Subscription method
  Future<SubscriptionBlockingState> blockSubscription({
    required String subscriptionId,
    required Map<String, dynamic> blockingData,
  });
}
