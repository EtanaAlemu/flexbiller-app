import 'package:equatable/equatable.dart';

abstract class AccountSubscriptionsEvent extends Equatable {
  const AccountSubscriptionsEvent();

  @override
  List<Object?> get props => [];
}

class LoadAccountSubscriptions extends AccountSubscriptionsEvent {
  final String accountId;

  const LoadAccountSubscriptions({required this.accountId});

  @override
  List<Object?> get props => [accountId];
}

class RefreshAccountSubscriptions extends AccountSubscriptionsEvent {
  final String accountId;

  const RefreshAccountSubscriptions({required this.accountId});

  @override
  List<Object?> get props => [accountId];
}
