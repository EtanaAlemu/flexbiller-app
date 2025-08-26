import 'package:equatable/equatable.dart';

abstract class SubscriptionsEvent extends Equatable {
  const SubscriptionsEvent();

  @override
  List<Object?> get props => [];
}

class LoadRecentSubscriptions extends SubscriptionsEvent {}

class RefreshRecentSubscriptions extends SubscriptionsEvent {}

class GetSubscriptionById extends SubscriptionsEvent {
  final String id;

  const GetSubscriptionById(this.id);

  @override
  List<Object?> get props => [id];
}

class GetSubscriptionsForAccount extends SubscriptionsEvent {
  final String accountId;

  const GetSubscriptionsForAccount(this.accountId);

  @override
  List<Object?> get props => [accountId];
}

class CreateSubscription extends SubscriptionsEvent {
  final String accountId;
  final String planName;

  const CreateSubscription({
    required this.accountId,
    required this.planName,
  });

  @override
  List<Object?> get props => [accountId, planName];
}

class UpdateSubscription extends SubscriptionsEvent {
  final String id;
  final Map<String, dynamic> payload;

  const UpdateSubscription({
    required this.id,
    required this.payload,
  });

  @override
  List<Object?> get props => [id, payload];
}

class CancelSubscription extends SubscriptionsEvent {
  final String id;

  const CancelSubscription(this.id);

  @override
  List<Object?> get props => [id];
}

// Custom Fields events
class AddSubscriptionCustomFields extends SubscriptionsEvent {
  final String subscriptionId;
  final List<Map<String, String>> customFields;

  const AddSubscriptionCustomFields({
    required this.subscriptionId,
    required this.customFields,
  });

  @override
  List<Object?> get props => [subscriptionId, customFields];
}

class GetSubscriptionCustomFields extends SubscriptionsEvent {
  final String subscriptionId;

  const GetSubscriptionCustomFields(this.subscriptionId);

  @override
  List<Object?> get props => [subscriptionId];
}

class UpdateSubscriptionCustomFields extends SubscriptionsEvent {
  final String subscriptionId;
  final List<Map<String, String>> customFields;

  const UpdateSubscriptionCustomFields({
    required this.subscriptionId,
    required this.customFields,
  });

  @override
  List<Object?> get props => [subscriptionId, customFields];
}

class RemoveSubscriptionCustomFields extends SubscriptionsEvent {
  final String subscriptionId;
  final String customFieldIds;

  const RemoveSubscriptionCustomFields({
    required this.subscriptionId,
    required this.customFieldIds,
  });

  @override
  List<Object?> get props => [subscriptionId, customFieldIds];
}

// Block Subscription event
class BlockSubscription extends SubscriptionsEvent {
  final String subscriptionId;
  final Map<String, dynamic> blockingData;

  const BlockSubscription({
    required this.subscriptionId,
    required this.blockingData,
  });

  @override
  List<Object?> get props => [subscriptionId, blockingData];
}

// Create Subscription with Add-ons event
class CreateSubscriptionWithAddOns extends SubscriptionsEvent {
  final List<Map<String, String>> addonProducts;

  const CreateSubscriptionWithAddOns({
    required this.addonProducts,
  });

  @override
  List<Object?> get props => [addonProducts];
}
