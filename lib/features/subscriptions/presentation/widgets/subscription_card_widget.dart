import 'package:flutter/material.dart';
import '../../domain/entities/subscription.dart';
import 'package:intl/intl.dart';
import '../pages/subscription_details_page.dart';

class SubscriptionCardWidget extends StatelessWidget {
  final Subscription subscription;
  final VoidCallback? onTap;

  const SubscriptionCardWidget({
    super.key,
    required this.subscription,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap:
            onTap ??
            () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => SubscriptionDetailsPage(
                    subscriptionId: subscription.subscriptionId,
                  ),
                ),
              );
            },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      subscription.productName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                subscription.planName,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodyMedium?.color?.withValues(
                    alpha: 0.7,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildInfoItem(
                    context,
                    'Billing Period',
                    subscription.billingPeriod,
                  ),
                  const SizedBox(width: 16),
                  _buildInfoItem(
                    context,
                    'Quantity',
                    subscription.quantity.toString(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildInfoItem(
                    context,
                    'Start Date',
                    dateFormat.format(subscription.startDate),
                  ),
                  const SizedBox(width: 16),
                  _buildInfoItem(
                    context,
                    'Cycle Day',
                    subscription.billCycleDayLocal.toString(),
                  ),
                ],
              ),
              if (subscription.chargedThroughDate.isNotEmpty) ...[
                const SizedBox(height: 8),
                _buildInfoItem(
                  context,
                  'Charged Through',
                  subscription.chargedThroughDate,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
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
      default:
        return Colors.grey;
    }
  }
}
