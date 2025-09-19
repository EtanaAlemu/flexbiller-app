import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import '../bloc/account_subscriptions_bloc.dart';
import '../bloc/events/account_subscriptions_event.dart';
import '../bloc/states/account_subscriptions_state.dart';
import '../../../subscriptions/presentation/pages/subscription_details_page.dart';
import '../../../subscriptions/domain/entities/subscription.dart';
import '../../../../core/widgets/error_display_widget.dart';

class AccountSubscriptionsWidget extends StatefulWidget {
  final String accountId;
  final Logger _logger = Logger();

  AccountSubscriptionsWidget({Key? key, required this.accountId})
    : super(key: key);

  @override
  State<AccountSubscriptionsWidget> createState() =>
      _AccountSubscriptionsWidgetState();
}

class _AccountSubscriptionsWidgetState
    extends State<AccountSubscriptionsWidget> {
  @override
  void initState() {
    super.initState();
    // Load subscriptions when widget is initialized
    context.read<AccountSubscriptionsBloc>().add(
      LoadAccountSubscriptions(accountId: widget.accountId),
    );
  }

  @override
  Widget build(BuildContext context) {
    widget._logger.d('AccountSubscriptionsWidget - build() called');

    return BlocBuilder<AccountSubscriptionsBloc, AccountSubscriptionsState>(
      builder: (context, state) {
        widget._logger.d(
          'AccountSubscriptionsWidget - BlocBuilder called with state: ${state.runtimeType}',
        );
        widget._logger.d(
          'AccountSubscriptionsWidget - State details: ${state.toString()}',
        );

        // Add more detailed logging for subscription states
        if (state is AccountSubscriptionsLoading) {
          widget._logger.d(
            'AccountSubscriptionsWidget - AccountSubscriptionsLoading state detected',
          );
        } else if (state is AccountSubscriptionsLoaded) {
          widget._logger.d(
            'AccountSubscriptionsWidget - AccountSubscriptionsLoaded state detected with ${state.subscriptions.length} subscriptions',
          );
        } else if (state is AccountSubscriptionsFailure) {
          widget._logger.d(
            'AccountSubscriptionsWidget - AccountSubscriptionsFailure state detected: ${state.message}',
          );
        }

        if (state is AccountSubscriptionsLoading) {
          widget._logger.d(
            'AccountSubscriptionsWidget - Showing loading state',
          );
          return const LoadingWidget(message: 'Loading subscriptions...');
        }

        if (state is AccountSubscriptionsFailure) {
          return ErrorDisplayWidget(
            error: state.message,
            context: 'subscriptions',
            onRetry: () {
              context.read<AccountSubscriptionsBloc>().add(
                LoadAccountSubscriptions(accountId: widget.accountId),
              );
            },
          );
        }

        if (state is AccountSubscriptionsLoaded) {
          widget._logger.d(
            'AccountSubscriptionsWidget - Showing loaded state with ${state.subscriptions.length} subscriptions',
          );

          if (state.subscriptions.isEmpty) {
            widget._logger.d(
              'AccountSubscriptionsWidget - Showing empty subscriptions message',
            );
            return EmptyStateWidget(
              message: 'No subscriptions found',
              subtitle: 'This account doesn\'t have any active subscriptions.',
              icon: Icons.subscriptions_outlined,
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<AccountSubscriptionsBloc>().add(
                RefreshAccountSubscriptions(accountId: widget.accountId),
              );
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: state.subscriptions.length,
              itemBuilder: (context, index) {
                final subscription = state.subscriptions[index];
                return _buildSubscriptionCard(context, subscription);
              },
            ),
          );
        }

        // Default state - show loading
        widget._logger.d(
          'AccountSubscriptionsWidget - Showing default loading state for state: ${state.runtimeType}',
        );
        return const LoadingWidget(message: 'Loading subscriptions...');
      },
    );
  }

  Widget _buildSubscriptionCard(
    BuildContext context,
    Subscription subscription,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: () => _navigateToSubscriptionDetails(context, subscription),
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      subscription.productName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStateColor(subscription.state),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      subscription.state,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Plan: ${subscription.planName}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Billing: ${subscription.billingPeriod}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Started: ${_formatDate(subscription.startDate)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStateColor(String state) {
    switch (state.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'paused':
        return Colors.orange;
      case 'trial':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'Unknown';
    try {
      if (date is String) {
        final parsedDate = DateTime.parse(date);
        return '${parsedDate.day}/${parsedDate.month}/${parsedDate.year}';
      } else if (date is DateTime) {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return 'Invalid date';
    }
    return 'Unknown';
  }

  void _navigateToSubscriptionDetails(
    BuildContext context,
    Subscription subscription,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SubscriptionDetailsPage(
          subscriptionId: subscription.subscriptionId,
        ),
      ),
    );
  }
}
