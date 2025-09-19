import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import '../bloc/accounts_bloc.dart';
import '../bloc/accounts_event.dart';
import '../bloc/accounts_state.dart';
import '../../../subscriptions/presentation/pages/subscription_details_page.dart';

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
  bool _hasLoadedSubscriptions = false;

  @override
  Widget build(BuildContext context) {
    widget._logger.d('AccountSubscriptionsWidget - build() called');
    final bloc = context.read<AccountsBloc>();
    widget._logger.d(
      'AccountSubscriptionsWidget - Bloc instance: ${bloc.hashCode}',
    );

    return BlocListener<AccountsBloc, AccountsState>(
      listener: (context, state) {
        widget._logger.d(
          'AccountSubscriptionsWidget - BlocListener called with state: ${state.runtimeType}',
        );
        widget._logger.d(
          'AccountSubscriptionsWidget - BlocListener _hasLoadedSubscriptions: $_hasLoadedSubscriptions',
        );

        if (state is AccountDetailsLoaded && !_hasLoadedSubscriptions) {
          widget._logger.d(
            'AccountSubscriptionsWidget - AccountDetailsLoaded detected in BlocListener, loading subscriptions for account: ${widget.accountId}',
          );
          widget._logger.d(
            'AccountSubscriptionsWidget - Dispatching LoadAccountSubscriptions event from BlocListener',
          );
          setState(() {
            _hasLoadedSubscriptions = true;
          });
          context.read<AccountsBloc>().add(
            LoadAccountSubscriptions(accountId: widget.accountId),
          );
          widget._logger.d(
            'AccountSubscriptionsWidget - LoadAccountSubscriptions event dispatched successfully from BlocListener',
          );
        } else if (state is AccountDetailsLoaded && _hasLoadedSubscriptions) {
          widget._logger.d(
            'AccountSubscriptionsWidget - AccountDetailsLoaded detected but subscriptions already loaded, skipping',
          );
        }
      },
      child: BlocBuilder<AccountsBloc, AccountsState>(
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
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (state is AccountSubscriptionsFailure) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load subscriptions',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        context.read<AccountsBloc>().add(
                          LoadAccountSubscriptions(accountId: widget.accountId),
                        );
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
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
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.subscriptions_outlined,
                        size: 64,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No subscriptions found',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'This account doesn\'t have any active subscriptions.',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<AccountsBloc>().add(
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

          // Handle AccountDetailsLoaded state - just show loading, let BlocListener handle the trigger
          if (state is AccountDetailsLoaded) {
            widget._logger.d(
              'AccountSubscriptionsWidget - AccountDetailsLoaded detected in BlocBuilder, showing loading state',
            );
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading subscriptions...'),
                  ],
                ),
              ),
            );
          }

          // Default state - show loading
          widget._logger.d(
            'AccountSubscriptionsWidget - Showing default loading state for state: ${state.runtimeType}',
          );
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading account details...'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSubscriptionCard(BuildContext context, dynamic subscription) {
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
                      subscription.productName ?? 'Unknown Product',
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
                      subscription.state ?? 'Unknown',
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
              if (subscription.planName != null) ...[
                Text(
                  'Plan: ${subscription.planName}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 4),
              ],
              if (subscription.billingPeriod != null) ...[
                Text(
                  'Billing: ${subscription.billingPeriod}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 4),
              ],
              if (subscription.startDate != null) ...[
                Text(
                  'Started: ${_formatDate(subscription.startDate)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getStateColor(String? state) {
    switch (state?.toLowerCase()) {
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
    dynamic subscription,
  ) {
    final subscriptionId = subscription.subscriptionId ?? subscription.id;
    if (subscriptionId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SubscriptionDetailsPage(
            subscriptionId: subscriptionId.toString(),
          ),
        ),
      );
    }
  }
}
