import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/subscription.dart';
import '../pages/subscription_details_page.dart';
import '../pages/update_subscription_page.dart';
import '../bloc/subscriptions_bloc.dart';
import 'cancel_subscription_dialog.dart';

class SubscriptionCardWidget extends StatelessWidget {
  final Subscription subscription;
  final VoidCallback? onTap;
  final VoidCallback? onCancel;

  const SubscriptionCardWidget({
    super.key,
    required this.subscription,
    this.onTap,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM dd, yyyy');
    final isCancelled = subscription.state.toUpperCase() == 'CANCELLED';
    final stateColor = _getStateColor(subscription.state, theme);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap ?? () => _navigateToDetails(context),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  // Product Icon
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.subscriptions_rounded,
                      color: theme.colorScheme.onPrimaryContainer,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Product Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          subscription.productName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subscription.planName,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: stateColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: stateColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: stateColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          subscription.state,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: stateColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Info Grid
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      context,
                      'Billing Period',
                      subscription.billingPeriod,
                      Icons.calendar_today_rounded,
                    ),
                  ),
                  Expanded(
                    child: _buildInfoItem(
                      context,
                      'Quantity',
                      subscription.quantity.toString(),
                      Icons.numbers_rounded,
                    ),
                  ),
                  Expanded(
                    child: _buildInfoItem(
                      context,
                      'Start Date',
                      dateFormat.format(subscription.startDate),
                      Icons.event_rounded,
                    ),
                  ),
                ],
              ),

              // Cancelled Date (if applicable)
              if (subscription.cancelledDate != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.errorContainer.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.cancel_outlined,
                        size: 20,
                        color: theme.colorScheme.error,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Cancelled on ${dateFormat.format(subscription.cancelledDate!)}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.error,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 16),

              // Action Buttons
              if (!isCancelled)
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _editSubscription(context),
                        icon: const Icon(Icons.edit_rounded, size: 18),
                        label: const Text('Edit'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => _navigateToDetails(context),
                        icon: const Icon(Icons.visibility_rounded, size: 18),
                        label: const Text('View Details'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      onPressed: () => _showCancelDialog(context),
                      icon: const Icon(Icons.cancel_outlined),
                      tooltip: 'Cancel Subscription',
                      style: IconButton.styleFrom(
                        backgroundColor: theme.colorScheme.errorContainer,
                        foregroundColor: theme.colorScheme.onErrorContainer,
                        padding: const EdgeInsets.all(12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _navigateToDetails(context),
                        icon: const Icon(Icons.visibility_rounded, size: 18),
                        label: const Text('View Details'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 16,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => BlocProvider(
        create: (context) => context.read<SubscriptionsBloc>(),
        child: CancelSubscriptionDialog(
          subscriptionId: subscription.subscriptionId,
          subscriptionName: subscription.productName,
          onSuccess: () {
            onCancel?.call();
          },
        ),
      ),
    );
  }

  void _editSubscription(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            UpdateSubscriptionPage(subscription: subscription),
      ),
    );
  }

  void _navigateToDetails(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SubscriptionDetailsPage(
          subscriptionId: subscription.subscriptionId,
        ),
      ),
    );
  }

  Color _getStateColor(String state, ThemeData theme) {
    switch (state.toUpperCase()) {
      case 'ACTIVE':
        return theme.colorScheme.primary;
      case 'BLOCKED':
        return theme.colorScheme.error;
      case 'CANCELLED':
        return theme.colorScheme.outline;
      case 'PAUSED':
        return theme.colorScheme.tertiary;
      case 'PENDING':
        return theme.colorScheme.secondary;
      default:
        return theme.colorScheme.outline;
    }
  }
}
