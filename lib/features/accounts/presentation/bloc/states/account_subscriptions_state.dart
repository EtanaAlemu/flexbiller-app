import 'package:equatable/equatable.dart';
import '../../../../subscriptions/domain/entities/subscription.dart';

abstract class AccountSubscriptionsState extends Equatable {
  const AccountSubscriptionsState();

  @override
  List<Object?> get props => [];
}

class AccountSubscriptionsInitial extends AccountSubscriptionsState {}

class AccountSubscriptionsLoading extends AccountSubscriptionsState {
  final String accountId;

  const AccountSubscriptionsLoading({required this.accountId});

  @override
  List<Object?> get props => [accountId];
}

class AccountSubscriptionsLoaded extends AccountSubscriptionsState {
  final String accountId;
  final List<Subscription> subscriptions;

  const AccountSubscriptionsLoaded({
    required this.accountId,
    required this.subscriptions,
  });

  @override
  List<Object?> get props => [accountId, subscriptions];
}

class AccountSubscriptionsFailure extends AccountSubscriptionsState {
  final String message;
  final String accountId;

  const AccountSubscriptionsFailure({
    required this.message,
    required this.accountId,
  });

  @override
  List<Object?> get props => [message, accountId];
}

class AccountSubscriptionsRefreshing extends AccountSubscriptionsState {
  final String accountId;
  final List<Subscription> subscriptions;

  const AccountSubscriptionsRefreshing({
    required this.accountId,
    required this.subscriptions,
  });

  @override
  List<Object?> get props => [accountId, subscriptions];
}
