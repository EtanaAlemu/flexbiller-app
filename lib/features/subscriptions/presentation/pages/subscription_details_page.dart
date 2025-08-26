import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/subscriptions_bloc.dart';
import '../bloc/subscriptions_event.dart';
import '../bloc/subscriptions_state.dart';
import '../../domain/entities/subscription.dart';
import 'update_subscription_page.dart';

class SubscriptionDetailsPage extends StatelessWidget {
  final String subscriptionId;

  const SubscriptionDetailsPage({super.key, required this.subscriptionId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          context.read<SubscriptionsBloc>()
            ..add(LoadSubscriptionById(subscriptionId)),
      child: BlocBuilder<SubscriptionsBloc, SubscriptionsState>(
        builder: (context, state) {
          if (state is SingleSubscriptionLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (state is SingleSubscriptionLoaded) {
            return _buildSubscriptionDetails(context, state.subscription);
          } else if (state is SingleSubscriptionError) {
            return Scaffold(
              appBar: AppBar(title: const Text('Subscription Details')),
              body: Center(
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
                      'Error loading subscription',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<SubscriptionsBloc>().add(
                          LoadSubscriptionById(subscriptionId),
                        );
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }
          return const Scaffold(
            body: Center(child: Text('No subscription loaded')),
          );
        },
      ),
    );
  }

  Widget _buildSubscriptionDetails(
    BuildContext context,
    Subscription subscription,
  ) {
    final dateFormat = DateFormat('MMM dd, yyyy HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: Text('${subscription.productName} Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _editSubscription(context, subscription),
            tooltip: 'Edit Subscription',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusCard(context, subscription),
            const SizedBox(height: 16),
            _buildBasicInfoCard(context, subscription, dateFormat),
            const SizedBox(height: 16),
            _buildBillingInfoCard(context, subscription, dateFormat),
            const SizedBox(height: 16),
            _buildEventsCard(context, subscription, dateFormat),
            if (subscription.prices.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildPricingCard(context, subscription),
            ],
          ],
        ),
      ),
    );
  }

  void _editSubscription(BuildContext context, Subscription subscription) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => UpdateSubscriptionPage(
          subscription: subscription,
        ),
      ),
    );

    // If subscription was updated successfully, refresh the details
    if (result == true) {
      if (context.mounted) {
        context.read<SubscriptionsBloc>().add(
          LoadSubscriptionById(subscriptionId),
        );
      }
    }
  }

  Widget _buildStatusCard(BuildContext context, Subscription subscription) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Status',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color?.withValues(
                        alpha: 0.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subscription.state,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getStateColor(subscription.state),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                subscription.state,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoCard(
    BuildContext context,
    Subscription subscription,
    DateFormat dateFormat,
  ) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Basic Information',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Product Name', subscription.productName),
            _buildInfoRow('Plan Name', subscription.planName),
            _buildInfoRow('Product Category', subscription.productCategory),
            _buildInfoRow('Billing Period', subscription.billingPeriod),
            _buildInfoRow('Phase Type', subscription.phaseType),
            _buildInfoRow('Source Type', subscription.sourceType),
            _buildInfoRow('Quantity', subscription.quantity.toString()),
            _buildInfoRow(
              'Start Date',
              dateFormat.format(subscription.startDate),
            ),
            if (subscription.cancelledDate != null)
              _buildInfoRow(
                'Cancelled Date',
                dateFormat.format(subscription.cancelledDate!),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBillingInfoCard(
    BuildContext context,
    Subscription subscription,
    DateFormat dateFormat,
  ) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Billing Information',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              'Billing Start Date',
              dateFormat.format(subscription.billingStartDate),
            ),
            if (subscription.billingEndDate != null)
              _buildInfoRow(
                'Billing End Date',
                dateFormat.format(subscription.billingEndDate!),
              ),
            _buildInfoRow(
              'Bill Cycle Day',
              subscription.billCycleDayLocal.toString(),
            ),
            _buildInfoRow('Charged Through', subscription.chargedThroughDate),
            _buildInfoRow('Price List', subscription.priceList),
          ],
        ),
      ),
    );
  }

  Widget _buildEventsCard(
    BuildContext context,
    Subscription subscription,
    DateFormat dateFormat,
  ) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Events (${subscription.events.length})',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (subscription.events.isEmpty)
              Text(
                'No events found',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodyMedium?.color?.withValues(
                    alpha: 0.6,
                  ),
                ),
              )
            else
              ...subscription.events.map(
                (event) => _buildEventTile(context, event, dateFormat),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPricingCard(BuildContext context, Subscription subscription) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pricing',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...subscription.prices.map((price) {
              if (price is Map<String, dynamic>) {
                return _buildPriceTile(context, price);
              }
              return const SizedBox.shrink();
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w400),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventTile(
    BuildContext context,
    dynamic event,
    DateFormat dateFormat,
  ) {
    final theme = Theme.of(context);

    if (event is Map<String, dynamic>) {
      return Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          title: Text(
            event['eventType'] ?? 'Unknown Event',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (event['effectiveDate'] != null)
                Text(
                  'Date: ${dateFormat.format(DateTime.parse(event['effectiveDate']))}',
                ),
              if (event['serviceName'] != null)
                Text('Service: ${event['serviceName']}'),
              if (event['phase'] != null) Text('Phase: ${event['phase']}'),
            ],
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color:
                  event['isBlockedBilling'] == true ||
                          event['isBlockedEntitlement'] == true
                      ? Colors.red
                      : Colors.green,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              event['isBlockedBilling'] == true ||
                      event['isBlockedEntitlement'] == true
                  ? 'BLOCKED'
                  : 'ACTIVE',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildPriceTile(BuildContext context, Map<String, dynamic> price) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(
          price['planName'] ?? 'Unknown Plan',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (price['phaseName'] != null)
              Text('Phase: ${price['phaseName']}'),
            if (price['phaseType'] != null) Text('Type: ${price['phaseType']}'),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (price['recurringPrice'] != null)
              Text(
                '\$${price['recurringPrice'].toStringAsFixed(2)}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            if (price['fixedPrice'] != null)
              Text(
                'Fixed: \$${price['fixedPrice'].toStringAsFixed(2)}',
                style: theme.textTheme.bodySmall,
              ),
          ],
        ),
      ),
    );
  }

  Color _getStateColor(String state) {
    switch (state.toUpperCase()) {
      case 'ACTIVE':
        return Colors.green;
      case 'BLOCKED':
        return Colors.red;
      case 'CANCELLED':
        return Colors.orange;
      case 'PAUSED':
        return Colors.yellow.shade700;
      case 'PENDING':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}
