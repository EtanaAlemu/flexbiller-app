import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:get_it/get_it.dart';
import '../bloc/subscriptions_bloc.dart';
import '../bloc/subscriptions_event.dart';
import '../bloc/subscriptions_state.dart';
import '../../domain/entities/subscription.dart';
import '../../domain/entities/subscription_event.dart';
import '../widgets/cancel_subscription_dialog.dart';
import '../../../../core/widgets/error_display_widget.dart';

import 'update_subscription_page.dart';

class SubscriptionDetailsPage extends StatelessWidget {
  final String subscriptionId;

  const SubscriptionDetailsPage({super.key, required this.subscriptionId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          GetIt.instance<SubscriptionsBloc>()
            ..add(GetSubscriptionById(subscriptionId)),
      child: BlocBuilder<SubscriptionsBloc, SubscriptionsState>(
        builder: (context, state) {
          if (state is SingleSubscriptionLoading) {
            return Scaffold(
              appBar: AppBar(title: const Text('Subscription Details')),
              body: const LoadingWidget(
                message: 'Loading subscription details...',
              ),
            );
          } else if (state is SingleSubscriptionLoaded) {
            return _buildSubscriptionDetails(context, state.subscription);
          } else if (state is SingleSubscriptionError) {
            return Scaffold(
              appBar: AppBar(title: const Text('Subscription Details')),
              body: ErrorDisplayWidget(
                error: state.message,
                context: 'subscription_details',
                onRetry: () {
                  context.read<SubscriptionsBloc>().add(
                    GetSubscriptionById(subscriptionId),
                  );
                },
              ),
            );
          }
          return Scaffold(
            appBar: AppBar(title: const Text('Subscription Details')),
            body: const LoadingWidget(
              message: 'Loading subscription details...',
            ),
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
          // Cancel button for non-cancelled subscriptions
          if (subscription.state.toUpperCase() != 'CANCELLED')
            IconButton(
              icon: const Icon(Icons.cancel_outlined),
              onPressed: () => _showCancelDialog(context, subscription),
              tooltip: 'Cancel Subscription',
              color: Theme.of(context).colorScheme.error,
            ),
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
            // Enhanced Status Card with Progress
            _buildEnhancedStatusCard(context, subscription),
            const SizedBox(height: 16),

            // Subscription Progress Bar
            _buildSubscriptionProgressCard(context, subscription),
            const SizedBox(height: 16),

            // Basic Information
            _buildBasicInfoCard(context, subscription, dateFormat),
            const SizedBox(height: 16),

            // Billing Information
            _buildBillingInfoCard(context, subscription, dateFormat),
            const SizedBox(height: 16),

            // Enhanced Events History Table
            _buildEnhancedEventsCard(context, subscription, dateFormat),
            const SizedBox(height: 16),

            // Enhanced Pricing Details Table
            if (subscription.prices.isNotEmpty) ...[
              _buildEnhancedPricingCard(context, subscription),
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }

  void _showCancelDialog(BuildContext context, Subscription subscription) {
    final subscriptionsBloc = context.read<SubscriptionsBloc>();
    showDialog(
      context: context,
      builder: (context) => BlocProvider.value(
        value: subscriptionsBloc,
        child: CancelSubscriptionDialog(
          subscriptionId: subscription.subscriptionId,
          subscriptionName: subscription.productName,
          onSuccess: () {
            // Refresh the subscription details after cancellation
            subscriptionsBloc.add(GetSubscriptionById(subscriptionId));
          },
        ),
      ),
    );
  }

  void _editSubscription(
    BuildContext context,
    Subscription subscription,
  ) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            UpdateSubscriptionPage(subscription: subscription),
      ),
    );

    // If subscription was updated successfully, refresh the details
    if (result == true) {
      if (context.mounted) {
        context.read<SubscriptionsBloc>().add(
          GetSubscriptionById(subscriptionId),
        );
      }
    }
  }

  Widget _buildEnhancedStatusCard(
    BuildContext context,
    Subscription subscription,
  ) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Subscriptions',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSubscriptionTable(context, subscription),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionTable(
    BuildContext context,
    Subscription subscription,
  ) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with product name and status
            Row(
              children: [
                Expanded(
                  child: Text(
                    subscription.productName,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildStatusChip(subscription.state),
              ],
            ),
            const SizedBox(height: 8),

            // Plan information
            Row(
              children: [
                Icon(
                  Icons.description,
                  size: 16,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    subscription.planName,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.8),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Date information
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                const SizedBox(width: 8),
                Text(
                  'Started: ${dateFormat.format(subscription.startDate)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                if (subscription.billingEndDate != null) ...[
                  const SizedBox(width: 16),
                  Text(
                    'Ends: ${dateFormat.format(subscription.billingEndDate!)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),

            // Billing and quantity information
            Row(
              children: [
                Icon(
                  Icons.payment,
                  size: 16,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                const SizedBox(width: 8),
                Text(
                  '${subscription.billingPeriod} • Qty: ${subscription.quantity}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Pricing information
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Fixed Price:',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'Free',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recurring Price:',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '\$${_getRecurringPrice(subscription)}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () =>
                      _showSubscriptionActions(context, subscription),
                  tooltip: 'More Actions',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStateColor(status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getStateColor(status)),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: _getStateColor(status),
          fontWeight: FontWeight.w500,
          fontSize: 11,
        ),
      ),
    );
  }

  String _getRecurringPrice(Subscription subscription) {
    if (subscription.prices.isNotEmpty) {
      final price = subscription.prices.first;
      if (price is Map<String, dynamic> && price['recurringPrice'] != null) {
        return price['recurringPrice'].toStringAsFixed(2);
      }
    }
    return '0.00';
  }

  void _showSubscriptionActions(
    BuildContext context,
    Subscription subscription,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Subscription'),
              onTap: () {
                Navigator.pop(context);
                _editSubscription(context, subscription);
              },
            ),
            if (subscription.state.toUpperCase() != 'CANCELLED')
              ListTile(
                leading: const Icon(Icons.cancel, color: Colors.red),
                title: const Text('Cancel Subscription'),
                onTap: () {
                  Navigator.pop(context);
                  _showCancelDialog(context, subscription);
                },
              ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('View Details'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionProgressCard(
    BuildContext context,
    Subscription subscription,
  ) {
    final theme = Theme.of(context);

    // Calculate progress percentage (simplified calculation)
    final progress = _calculateSubscriptionProgress(subscription);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Subscription Progress',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: progress / 100,
                    backgroundColor: theme.colorScheme.surfaceVariant,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      theme.colorScheme.primary,
                    ),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${progress.toInt()}%',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('MMM dd').format(subscription.startDate),
                  style: theme.textTheme.bodySmall,
                ),
                Text(
                  subscription.billingEndDate != null
                      ? DateFormat(
                          'MMM dd',
                        ).format(subscription.billingEndDate!)
                      : 'Ongoing',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  double _calculateSubscriptionProgress(Subscription subscription) {
    // Simplified progress calculation
    // In a real app, this would be more sophisticated
    if (subscription.billingEndDate == null) return 0.0;

    final now = DateTime.now();
    final start = subscription.startDate;
    final end = subscription.billingEndDate!;

    if (now.isBefore(start)) return 0.0;
    if (now.isAfter(end)) return 100.0;

    final totalDuration = end.difference(start).inDays;
    final elapsedDuration = now.difference(start).inDays;

    return (elapsedDuration / totalDuration) * 100;
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

  Widget _buildEnhancedEventsCard(
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
              'Events History',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (subscription.events.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    'No events found',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.textTheme.bodyMedium?.color?.withValues(
                        alpha: 0.6,
                      ),
                    ),
                  ),
                ),
              )
            else
              _buildEventsTable(context, subscription, dateFormat),
          ],
        ),
      ),
    );
  }

  Widget _buildEventsTable(
    BuildContext context,
    Subscription subscription,
    DateFormat dateFormat,
  ) {
    final theme = Theme.of(context);

    return Column(
      children: subscription.events.map((event) {
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          elevation: 2,
          child: InkWell(
            onTap: () => _showEventDetailsDialog(context, event, dateFormat),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row with event type and status
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          event.eventType,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      _buildEventStatusChip(event.eventType),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.chevron_right,
                        color: theme.colorScheme.primary.withOpacity(0.6),
                        size: 20,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Service information
                  Row(
                    children: [
                      Icon(
                        Icons.business,
                        size: 16,
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          event.serviceName,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.8),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Date information
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 16,
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        dateFormat.format(event.effectiveDate),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Status indicators
                  Row(
                    children: [
                      if (event.isBlockedBilling ||
                          event.isBlockedEntitlement) ...[
                        _buildBlockedStatusChip(
                          event.isBlockedBilling || event.isBlockedEntitlement,
                        ),
                        const SizedBox(width: 8),
                      ],
                      if (event.phase.isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: theme.colorScheme.primary.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            event.phase,
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEventStatusChip(String eventType) {
    Color color;
    String status;

    switch (eventType.toUpperCase()) {
      case 'START_ENTITLEMENT':
        color = Colors.purple;
        status = 'ENT_STARTED';
        break;
      case 'START_BILLING':
        color = Colors.blue;
        status = 'START_BILLING';
        break;
      default:
        color = Colors.grey;
        status = eventType;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w500,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _buildBlockedStatusChip(bool isBlocked) {
    final color = isBlocked ? Colors.red : Colors.green;
    final status = isBlocked ? 'Blocked' : 'Active';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w500,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _buildEnhancedPricingCard(
    BuildContext context,
    Subscription subscription,
  ) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pricing Details',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (subscription.prices.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    'No pricing information available',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.textTheme.bodyMedium?.color?.withValues(
                        alpha: 0.6,
                      ),
                    ),
                  ),
                ),
              )
            else
              _buildPricingTable(context, subscription),
          ],
        ),
      ),
    );
  }

  Widget _buildPricingTable(BuildContext context, Subscription subscription) {
    final theme = Theme.of(context);

    return Column(
      children: subscription.prices.map((price) {
        if (price is Map<String, dynamic>) {
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with phase name and type
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          price['phaseName'] ?? 'Unknown Phase',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      _buildPhaseTypeChip(price['phaseType'] ?? ''),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Pricing information
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Fixed Price:',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              price['fixedPrice'] != null
                                  ? '\$${price['fixedPrice'].toStringAsFixed(2)}'
                                  : 'Free',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Recurring Price:',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              price['recurringPrice'] != null
                                  ? '\$${price['recurringPrice'].toStringAsFixed(2)}/mo'
                                  : 'N/A',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      }).toList(),
    );
  }

  Widget _buildPhaseTypeChip(String phaseType) {
    Color color;

    switch (phaseType.toUpperCase()) {
      case 'EVERGREEN':
        color = Colors.green;
        break;
      case 'TRIAL':
        color = Colors.blue;
        break;
      case 'DISCOUNT':
        color = Colors.orange;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        phaseType,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w500,
          fontSize: 11,
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

  void _showEventDetailsDialog(
    BuildContext context,
    SubscriptionEvent event,
    DateFormat dateFormat,
  ) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.event_note,
                color: theme.colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Event Details',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildEventDetailSection('Event Information', [
                  _buildEventDetailRow('Event Type', event.eventType),
                  _buildEventDetailRow('Service Name', event.serviceName),
                  _buildEventDetailRow('Service State', event.serviceStateName),
                  _buildEventDetailRow('Phase', event.phase),
                  _buildEventDetailRow('Plan', event.plan),
                  _buildEventDetailRow('Product', event.product),
                ]),
                const SizedBox(height: 16),
                _buildEventDetailSection('Timing', [
                  _buildEventDetailRow(
                    'Effective Date',
                    dateFormat.format(event.effectiveDate),
                  ),
                  _buildEventDetailRow(
                    'Catalog Effective Date',
                    dateFormat.format(event.catalogEffectiveDate),
                  ),
                ]),
                const SizedBox(height: 16),
                _buildEventDetailSection('Billing Information', [
                  _buildEventDetailRow('Billing Period', event.billingPeriod),
                  _buildEventDetailRow('Price List', event.priceList),
                ]),
                const SizedBox(height: 16),
                _buildEventDetailSection('Status', [
                  _buildEventDetailRow(
                    'Blocked Billing',
                    event.isBlockedBilling ? 'Yes' : 'No',
                    valueColor: event.isBlockedBilling
                        ? Colors.red
                        : Colors.green,
                  ),
                  _buildEventDetailRow(
                    'Blocked Entitlement',
                    event.isBlockedEntitlement ? 'Yes' : 'No',
                    valueColor: event.isBlockedEntitlement
                        ? Colors.red
                        : Colors.green,
                  ),
                ]),
                if (event.auditLogs != null && event.auditLogs!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildEventDetailSection(
                    'Audit Logs',
                    event.auditLogs!.map((log) {
                      return _buildEventDetailRow(
                        'Log Entry',
                        '${log['action'] ?? 'Unknown'} - ${log['comment'] ?? 'No comment'}',
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEventDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildEventDetailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: valueColor ?? Colors.black87,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
