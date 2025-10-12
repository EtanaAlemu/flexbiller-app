import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/bundle.dart';

class BundleDetailsWidget extends StatelessWidget {
  final Bundle bundle;

  const BundleDetailsWidget({super.key, required this.bundle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM dd, yyyy HH:mm');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bundle Header Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        color: theme.colorScheme.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Bundle Details',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow('Bundle ID', bundle.bundleId),
                  _buildDetailRow('Account ID', bundle.accountId),
                  _buildDetailRow('External Key', bundle.externalKey),
                  _buildDetailRow(
                    'Subscriptions Count',
                    '${bundle.subscriptions.length}',
                  ),
                  _buildDetailRow(
                    'Timeline Events',
                    '${bundle.timeline.events.length}',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Subscriptions Section
          Text(
            'Subscriptions',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          ...bundle.subscriptions.map(
            (subscription) => _buildSubscriptionCard(
              context,
              subscription,
              theme,
              dateFormat,
            ),
          ),

          const SizedBox(height: 16),

          // Timeline Section
          Text(
            'Timeline Events',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          ...bundle.timeline.events.map(
            (event) => _buildEventCard(context, event, theme, dateFormat),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionCard(
    BuildContext context,
    dynamic subscription,
    ThemeData theme,
    DateFormat dateFormat,
  ) {
    final stateColor = _getSubscriptionStateColor(subscription.state, theme);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: stateColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    subscription.productName,
                    style: theme.textTheme.titleSmall?.copyWith(
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
                    color: stateColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    subscription.state,
                    style: TextStyle(
                      color: stateColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Plan: ${subscription.planName}'),
            Text('Billing Period: ${subscription.billingPeriod}'),
            Text('Start Date: ${dateFormat.format(subscription.startDate)}'),
            if (subscription.cancelledDate != null)
              Text(
                'Cancelled: ${dateFormat.format(subscription.cancelledDate!)}',
              ),
            Text('Quantity: ${subscription.quantity}'),
            Text('Bill Cycle Day: ${subscription.billCycleDayLocal}'),
          ],
        ),
      ),
    );
  }

  Widget _buildEventCard(
    BuildContext context,
    dynamic event,
    ThemeData theme,
    DateFormat dateFormat,
  ) {
    final eventColor = _getEventTypeColor(event.eventType, theme);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: eventColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    event.eventType,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  dateFormat.format(event.effectiveDate),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Service: ${event.serviceName}'),
            Text('State: ${event.serviceStateName}'),
            Text('Phase: ${event.phase}'),
            Text('Product: ${event.product}'),
            Text('Plan: ${event.plan}'),
            if (event.isBlockedBilling || event.isBlockedEntitlement) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  if (event.isBlockedBilling)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Billing Blocked',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  if (event.isBlockedBilling && event.isBlockedEntitlement)
                    const SizedBox(width: 4),
                  if (event.isBlockedEntitlement)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Entitlement Blocked',
                        style: TextStyle(
                          color: Colors.orange,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getSubscriptionStateColor(String state, ThemeData theme) {
    switch (state.toUpperCase()) {
      case 'ACTIVE':
        return Colors.green;
      case 'BLOCKED':
        return Colors.red;
      case 'CANCELLED':
        return Colors.grey;
      case 'PAUSED':
        return Colors.orange;
      default:
        return theme.colorScheme.onSurfaceVariant;
    }
  }

  Color _getEventTypeColor(String eventType, ThemeData theme) {
    switch (eventType.toUpperCase()) {
      case 'START_ENTITLEMENT':
      case 'START_BILLING':
        return Colors.green;
      case 'PAUSE_ENTITLEMENT':
      case 'PAUSE_BILLING':
        return Colors.orange;
      case 'SERVICE_STATE_CHANGE':
        return Colors.blue;
      default:
        return theme.colorScheme.primary;
    }
  }
}
