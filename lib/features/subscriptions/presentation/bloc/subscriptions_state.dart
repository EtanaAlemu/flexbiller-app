import 'package:equatable/equatable.dart';
import '../../domain/entities/subscription.dart';

abstract class SubscriptionsState extends Equatable {
  const SubscriptionsState();

  @override
  List<Object?> get props => [];
}

class SubscriptionsInitial extends SubscriptionsState {}

class SubscriptionsLoading extends SubscriptionsState {}

class SubscriptionsLoaded extends SubscriptionsState {
  final List<Subscription> subscriptions;

  const SubscriptionsLoaded(this.subscriptions);

  @override
  List<Object?> get props => [subscriptions];
}

class SubscriptionsError extends SubscriptionsState {
  final String message;

  const SubscriptionsError(this.message);

  @override
  List<Object?> get props => [message];
}

class SingleSubscriptionLoading extends SubscriptionsState {}

class SingleSubscriptionLoaded extends SubscriptionsState {
  final Subscription subscription;

  const SingleSubscriptionLoaded(this.subscription);

  @override
  List<Object?> get props => [subscription];
}

class SingleSubscriptionError extends SubscriptionsState {
  final String message;

  const SingleSubscriptionError(this.message);

  @override
  List<Object?> get props => [message];
}

class AccountSubscriptionsLoading extends SubscriptionsState {}

class AccountSubscriptionsLoaded extends SubscriptionsState {
  final String accountId;
  final List<Subscription> subscriptions;

  const AccountSubscriptionsLoaded({
    required this.accountId,
    required this.subscriptions,
  });

  @override
  List<Object?> get props => [accountId, subscriptions];
}

class AccountSubscriptionsError extends SubscriptionsState {
  final String message;

  const AccountSubscriptionsError(this.message);

  @override
  List<Object?> get props => [message];
}

class CreateSubscriptionLoading extends SubscriptionsState {}

class CreateSubscriptionSuccess extends SubscriptionsState {
  final Subscription subscription;

  const CreateSubscriptionSuccess(this.subscription);

  @override
  List<Object?> get props => [subscription];
}

class CreateSubscriptionError extends SubscriptionsState {
  final String message;

  const CreateSubscriptionError(this.message);

  @override
  List<Object?> get props => [message];
}

class UpdateSubscriptionLoading extends SubscriptionsState {}

class UpdateSubscriptionSuccess extends SubscriptionsState {
  final Subscription subscription;

  const UpdateSubscriptionSuccess(this.subscription);

  @override
  List<Object?> get props => [subscription];
}

class UpdateSubscriptionError extends SubscriptionsState {
  final String message;

  const UpdateSubscriptionError(this.message);

  @override
  List<Object?> get props => [message];
}

class CancelSubscriptionLoading extends SubscriptionsState {}

class CancelSubscriptionSuccess extends SubscriptionsState {
  final String subscriptionId;
  final String message;

  const CancelSubscriptionSuccess({
    required this.subscriptionId,
    required this.message,
  });

  @override
  List<Object?> get props => [subscriptionId, message];
}

class CancelSubscriptionError extends SubscriptionsState {
  final String message;

  const CancelSubscriptionError(this.message);

  @override
  List<Object?> get props => [message];
}

class SubscriptionTagsLoading extends SubscriptionsState {}

class SubscriptionTagsLoaded extends SubscriptionsState {
  final String subscriptionId;
  final List<String> tags;

  const SubscriptionTagsLoaded({
    required this.subscriptionId,
    required this.tags,
  });

  @override
  List<Object?> get props => [subscriptionId, tags];
}

class SubscriptionTagsError extends SubscriptionsState {
  final String message;

  const SubscriptionTagsError(this.message);

  @override
  List<Object?> get props => [message];
}
