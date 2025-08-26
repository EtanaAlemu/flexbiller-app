import 'package:equatable/equatable.dart';

abstract class SubscriptionsEvent extends Equatable {
  const SubscriptionsEvent();

  @override
  List<Object?> get props => [];
}

class LoadRecentSubscriptions extends SubscriptionsEvent {}

class RefreshSubscriptions extends SubscriptionsEvent {}

class LoadSubscriptionById extends SubscriptionsEvent {
  final String subscriptionId;

  const LoadSubscriptionById(this.subscriptionId);

  @override
  List<Object?> get props => [subscriptionId];
}

class LoadSubscriptionsForAccount extends SubscriptionsEvent {
  final String accountId;

  const LoadSubscriptionsForAccount(this.accountId);

  @override
  List<Object?> get props => [accountId];
}

class CreateSubscription extends SubscriptionsEvent {
  final String accountId;
  final String planName;

  const CreateSubscription({required this.accountId, required this.planName});

  @override
  List<Object?> get props => [accountId, planName];
}
