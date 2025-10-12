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
import '../../../../core/widgets/custom_snackbar.dart';
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
              appBar: AppBar(
                title: const Text('Subscription Details'),
                backgroundColor: Theme.of(context).colorScheme.surface,
                foregroundColor: Theme.of(context).colorScheme.onSurface,
                elevation: 0,
                scrolledUnderElevation: 1,
              ),
              body: const _LoadingWidget(
                message: 'Loading subscription details...',
              ),
            );
          } else if (state is SingleSubscriptionLoaded) {
            return _buildSubscriptionDetails(context, state.subscription);
          } else if (state is SingleSubscriptionError) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Subscription Details'),
                backgroundColor: Theme.of(context).colorScheme.surface,
                foregroundColor: Theme.of(context).colorScheme.onSurface,
                elevation: 0,
                scrolledUnderElevation: 1,
              ),
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
            appBar: AppBar(
              title: const Text('Subscription Details'),
              backgroundColor: Theme.of(context).colorScheme.surface,
              foregroundColor: Theme.of(context).colorScheme.onSurface,
              elevation: 0,
              scrolledUnderElevation: 1,
            ),
            body: const _LoadingWidget(
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
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM dd, yyyy');
    final isCancelled = subscription.state.toUpperCase() == 'CANCELLED';

    return Scaffold(
      appBar: AppBar(
        title: Text(subscription.productName),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
        actions: [
          if (!isCancelled)
            IconButton(
              icon: const Icon(Icons.cancel_outlined),
              onPressed: () => _showCancelDialog(context, subscription),
              tooltip: 'Cancel Subscription',
            ),
          IconButton(
            icon: const Icon(Icons.edit_rounded),
            onPressed: () => _editSubscription(context, subscription),
            tooltip: 'Edit Subscription',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded),
            onSelected: (value) =>
                _handleMenuAction(context, subscription, value),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'refresh',
                child: Row(
                  children: [
                    Icon(Icons.refresh_rounded),
                    SizedBox(width: 12),
                    Text('Refresh'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.download_rounded),
                    SizedBox(width: 12),
                    Text('Export Details'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Header Section
            _buildHeroSection(context, subscription),

            // Main Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Quick Actions
                  _buildQuickActionsCard(context, subscription),
                  const SizedBox(height: 16),

                  // Status and Progress
                  _buildStatusProgressCard(context, subscription),
                  const SizedBox(height: 16),

                  // Basic Information
                  _buildBasicInfoCard(context, subscription, dateFormat),
                  const SizedBox(height: 16),

                  // Billing Information
                  _buildBillingInfoCard(context, subscription, dateFormat),
                  const SizedBox(height: 16),

                  // Pricing Details
                  if (subscription.prices.isNotEmpty) ...[
                    _buildPricingCard(context, subscription),
                    const SizedBox(height: 16),
                  ],

                  // Events History
                  _buildEventsCard(context, subscription, dateFormat),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context, Subscription subscription) {
    final theme = Theme.of(context);
    final stateColor = _getStateColor(subscription.state, theme);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primaryContainer,
            theme.colorScheme.primaryContainer.withOpacity(0.7),
          ],
        ),
      ),
      child: Column(
        children: [
          // Product Icon
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.shadow.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              Icons.subscriptions_rounded,
              size: 48,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 20),

          // Product Name
          Text(
            subscription.productName,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onPrimaryContainer,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // Plan Name
          Text(
            subscription.planName,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onPrimaryContainer.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.shadow.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
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
                const SizedBox(width: 8),
                Text(
                  subscription.state,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: stateColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsCard(
    BuildContext context,
    Subscription subscription,
  ) {
    final theme = Theme.of(context);
    final isCancelled = subscription.state.toUpperCase() == 'CANCELLED';

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.flash_on_rounded,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Quick Actions',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _editSubscription(context, subscription),
                    icon: const Icon(Icons.edit_rounded),
                    label: const Text('Edit'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _showCancelDialog(context, subscription),
                    icon: const Icon(Icons.cancel_outlined),
                    label: const Text('Cancel'),
                    style: FilledButton.styleFrom(
                      backgroundColor: theme.colorScheme.error,
                      foregroundColor: theme.colorScheme.onError,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
            if (!isCancelled) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          _handleMenuAction(context, subscription, 'export'),
                      icon: const Icon(Icons.download_rounded),
                      label: const Text('Export'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          _handleMenuAction(context, subscription, 'refresh'),
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Refresh'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
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

  Widget _buildStatusProgressCard(
    BuildContext context,
    Subscription subscription,
  ) {
    final theme = Theme.of(context);
    final progress = _calculateSubscriptionProgress(subscription);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.timeline_rounded,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Subscription Progress',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Progress Bar
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: progress / 100,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      theme.colorScheme.primary,
                    ),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${progress.toInt()}%',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Date Range
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('MMM dd').format(subscription.startDate),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  subscription.billingEndDate != null
                      ? DateFormat(
                          'MMM dd',
                        ).format(subscription.billingEndDate!)
                      : 'Ongoing',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
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
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Basic Information',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            _buildInfoRow(
              context,
              'Subscription ID',
              subscription.subscriptionId,
              Icons.fingerprint_rounded,
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              context,
              'Account ID',
              subscription.accountId,
              Icons.account_circle_rounded,
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              context,
              'Quantity',
              subscription.quantity.toString(),
              Icons.numbers_rounded,
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              context,
              'Billing Period',
              subscription.billingPeriod,
              Icons.calendar_today_rounded,
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
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.payment_rounded,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Billing Information',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            _buildInfoRow(
              context,
              'Start Date',
              dateFormat.format(subscription.startDate),
              Icons.event_rounded,
            ),
            const SizedBox(height: 12),

            if (subscription.billingEndDate != null) ...[
              _buildInfoRow(
                context,
                'End Date',
                dateFormat.format(subscription.billingEndDate!),
                Icons.event_available_rounded,
              ),
              const SizedBox(height: 12),
            ],

            if (subscription.cancelledDate != null) ...[
              _buildInfoRow(
                context,
                'Cancelled Date',
                dateFormat.format(subscription.cancelledDate!),
                Icons.cancel_outlined,
                valueColor: theme.colorScheme.error,
              ),
              const SizedBox(height: 12),
            ],

            _buildInfoRow(
              context,
              'Charged Through Date',
              subscription.chargedThroughDate,
              Icons.schedule_rounded,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPricingCard(BuildContext context, Subscription subscription) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.attach_money_rounded,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Pricing Details',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Fixed Price',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'Free',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
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
                        'Recurring Price',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '\$${_getRecurringPrice(subscription)}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
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

  Widget _buildEventsCard(
    BuildContext context,
    Subscription subscription,
    DateFormat dateFormat,
  ) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.history_rounded,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Event History',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (subscription.events.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Icon(
                        Icons.history_rounded,
                        size: 48,
                        color: theme.colorScheme.onSurfaceVariant.withOpacity(
                          0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No events recorded',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: subscription.events.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final event = subscription.events[index];
                  return _buildEventItem(context, event, dateFormat);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value,
    IconData icon, {
    Color? valueColor,
  }) {
    final theme = Theme.of(context);

    return Row(
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
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEventItem(
    BuildContext context,
    SubscriptionEvent event,
    DateFormat dateFormat,
  ) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.event_rounded,
              size: 16,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.eventType,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  dateFormat.format(event.effectiveDate),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
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
            subscriptionsBloc.add(GetSubscriptionById(subscriptionId));
            CustomSnackBar.showSuccess(
              context,
              message: 'Subscription cancelled successfully',
            );
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

    if (result == true && context.mounted) {
      context.read<SubscriptionsBloc>().add(
        GetSubscriptionById(subscriptionId),
      );
      CustomSnackBar.showSuccess(
        context,
        message: 'Subscription updated successfully',
      );
    }
  }

  void _handleMenuAction(
    BuildContext context,
    Subscription subscription,
    String action,
  ) {
    switch (action) {
      case 'refresh':
        context.read<SubscriptionsBloc>().add(
          GetSubscriptionById(subscriptionId),
        );
        CustomSnackBar.showInfo(
          context,
          message: 'Subscription details refreshed',
        );
        break;
      case 'export':
        CustomSnackBar.showComingSoon(
          context,
          feature: 'Export Subscription Details',
        );
        break;
    }
  }

  double _calculateSubscriptionProgress(Subscription subscription) {
    if (subscription.billingEndDate == null) return 0.0;

    final now = DateTime.now();
    final start = subscription.startDate;
    final end = subscription.billingEndDate!;

    if (now.isBefore(start)) return 0.0;
    if (now.isAfter(end)) return 100.0;

    final totalDuration = end.difference(start).inMilliseconds;
    final elapsedDuration = now.difference(start).inMilliseconds;

    return (elapsedDuration / totalDuration) * 100;
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

class _LoadingWidget extends StatelessWidget {
  final String message;

  const _LoadingWidget({required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: theme.colorScheme.primary),
          const SizedBox(height: 16),
          Text(
            message,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
