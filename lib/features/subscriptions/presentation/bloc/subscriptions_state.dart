import 'package:equatable/equatable.dart';
import '../../domain/entities/subscription.dart';
import '../../domain/entities/subscription_custom_field.dart';
import '../../domain/entities/subscription_blocking_state.dart';
import '../../domain/entities/subscription_audit_log.dart';

abstract class SubscriptionsState extends Equatable {
  const SubscriptionsState();

  @override
  List<Object?> get props => [];
}

class SubscriptionsInitial extends SubscriptionsState {}

class SubscriptionsLoading extends SubscriptionsState {}

class SubscriptionsError extends SubscriptionsState {
  final String message;
  const SubscriptionsError(this.message);
  @override
  List<Object?> get props => [message];
}

class RecentSubscriptionsLoaded extends SubscriptionsState {
  final List<Subscription> subscriptions;
  const RecentSubscriptionsLoaded(this.subscriptions);
  @override
  List<Object?> get props => [subscriptions];
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
  final String id;
  const SingleSubscriptionError(this.message, this.id);
  @override
  List<Object?> get props => [message, id];
}

class AccountSubscriptionsLoading extends SubscriptionsState {}

class AccountSubscriptionsLoaded extends SubscriptionsState {
  final List<Subscription> subscriptions;
  final String accountId;
  const AccountSubscriptionsLoaded(this.subscriptions, this.accountId);
  @override
  List<Object?> get props => [subscriptions, accountId];
}

class AccountSubscriptionsError extends SubscriptionsState {
  final String message;
  final String accountId;
  const AccountSubscriptionsError(this.message, this.accountId);
  @override
  List<Object?> get props => [message, accountId];
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
  final String id;
  const UpdateSubscriptionError(this.message, this.id);
  @override
  List<Object?> get props => [message, id];
}

class CancelSubscriptionLoading extends SubscriptionsState {}

class CancelSubscriptionSuccess extends SubscriptionsState {
  final String cancelledId;
  const CancelSubscriptionSuccess(this.cancelledId);
  @override
  List<Object?> get props => [cancelledId];
}

class CancelSubscriptionError extends SubscriptionsState {
  final String message;
  final String id;
  const CancelSubscriptionError(this.message, this.id);
  @override
  List<Object?> get props => [message, id];
}

// Custom Fields states
class SubscriptionCustomFieldsLoading extends SubscriptionsState {}

class SubscriptionCustomFieldsLoaded extends SubscriptionsState {
  final List<SubscriptionCustomField> customFields;
  final String subscriptionId;
  const SubscriptionCustomFieldsLoaded(this.customFields, this.subscriptionId);
  @override
  List<Object?> get props => [customFields, subscriptionId];
}

class SubscriptionCustomFieldsError extends SubscriptionsState {
  final String message;
  final String subscriptionId;
  const SubscriptionCustomFieldsError(this.message, this.subscriptionId);
  @override
  List<Object?> get props => [message, subscriptionId];
}

class AddSubscriptionCustomFieldsLoading extends SubscriptionsState {}

class AddSubscriptionCustomFieldsSuccess extends SubscriptionsState {
  final List<SubscriptionCustomField> customFields;
  final String subscriptionId;
  const AddSubscriptionCustomFieldsSuccess(this.customFields, this.subscriptionId);
  @override
  List<Object?> get props => [customFields, subscriptionId];
}

class AddSubscriptionCustomFieldsError extends SubscriptionsState {
  final String message;
  final String subscriptionId;
  const AddSubscriptionCustomFieldsError(this.message, this.subscriptionId);
  @override
  List<Object?> get props => [message, subscriptionId];
}

class UpdateSubscriptionCustomFieldsLoading extends SubscriptionsState {}

class UpdateSubscriptionCustomFieldsSuccess extends SubscriptionsState {
  final List<SubscriptionCustomField> customFields;
  final String subscriptionId;
  const UpdateSubscriptionCustomFieldsSuccess(this.customFields, this.subscriptionId);
  @override
  List<Object?> get props => [customFields, subscriptionId];
}

class UpdateSubscriptionCustomFieldsError extends SubscriptionsState {
  final String message;
  final String subscriptionId;
  const UpdateSubscriptionCustomFieldsError(this.message, this.subscriptionId);
  @override
  List<Object?> get props => [message, subscriptionId];
}

class RemoveSubscriptionCustomFieldsLoading extends SubscriptionsState {}

class RemoveSubscriptionCustomFieldsSuccess extends SubscriptionsState {
  final Map<String, dynamic> result;
  final String subscriptionId;
  const RemoveSubscriptionCustomFieldsSuccess(this.result, this.subscriptionId);
  @override
  List<Object?> get props => [result, subscriptionId];
}

class RemoveSubscriptionCustomFieldsError extends SubscriptionsState {
  final String message;
  final String subscriptionId;
  const RemoveSubscriptionCustomFieldsError(this.message, this.subscriptionId);
  @override
  List<Object?> get props => [message, subscriptionId];
}

// Block Subscription states
class BlockSubscriptionLoading extends SubscriptionsState {}

class BlockSubscriptionSuccess extends SubscriptionsState {
  final SubscriptionBlockingState blockingState;
  final String subscriptionId;
  const BlockSubscriptionSuccess(this.blockingState, this.subscriptionId);
  @override
  List<Object?> get props => [blockingState, subscriptionId];
}

class BlockSubscriptionError extends SubscriptionsState {
  final String message;
  final String subscriptionId;
  const BlockSubscriptionError(this.message, this.subscriptionId);
  @override
  List<Object?> get props => [message, subscriptionId];
}

// Create Subscription with Add-ons states
class CreateSubscriptionWithAddOnsLoading extends SubscriptionsState {}

class CreateSubscriptionWithAddOnsSuccess extends SubscriptionsState {
  final Map<String, dynamic> result;
  const CreateSubscriptionWithAddOnsSuccess(this.result);
  @override
  List<Object?> get props => [result];
}

class CreateSubscriptionWithAddOnsError extends SubscriptionsState {
  final String message;
  const CreateSubscriptionWithAddOnsError(this.message);
  @override
  List<Object?> get props => [message];
}

// Get Subscription Audit Logs states
class GetSubscriptionAuditLogsWithHistoryLoading extends SubscriptionsState {}

class GetSubscriptionAuditLogsWithHistorySuccess extends SubscriptionsState {
  final List<SubscriptionAuditLog> auditLogs;
  final String subscriptionId;
  const GetSubscriptionAuditLogsWithHistorySuccess(this.auditLogs, this.subscriptionId);
  @override
  List<Object?> get props => [auditLogs, subscriptionId];
}

class GetSubscriptionAuditLogsWithHistoryError extends SubscriptionsState {
  final String message;
  final String subscriptionId;
  const GetSubscriptionAuditLogsWithHistoryError(this.message, this.subscriptionId);
  @override
  List<Object?> get props => [message, subscriptionId];
}

// Update Subscription BCD states
class UpdateSubscriptionBcdLoading extends SubscriptionsState {}

class UpdateSubscriptionBcdSuccess extends SubscriptionsState {
  final Map<String, dynamic> result;
  final String subscriptionId;
  const UpdateSubscriptionBcdSuccess(this.result, this.subscriptionId);
  @override
  List<Object?> get props => [result, subscriptionId];
}

class UpdateSubscriptionBcdError extends SubscriptionsState {
  final String message;
  final String subscriptionId;
  const UpdateSubscriptionBcdError(this.message, this.subscriptionId);
  @override
  List<Object?> get props => [message, subscriptionId];
}
