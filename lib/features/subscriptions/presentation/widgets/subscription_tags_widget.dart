import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/subscriptions_bloc.dart';
import '../bloc/subscriptions_event.dart';
import '../bloc/subscriptions_state.dart';

class SubscriptionTagsWidget extends StatelessWidget {
  final String subscriptionId;
  final String subscriptionName;
  final VoidCallback? onRefresh;

  const SubscriptionTagsWidget({
    super.key,
    required this.subscriptionId,
    this.subscriptionName = '',
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => context.read<SubscriptionsBloc>()
        ..add(LoadSubscriptionTags(subscriptionId)),
      child: BlocBuilder<SubscriptionsBloc, SubscriptionsState>(
        builder: (context, state) {
          if (state is SubscriptionTagsLoading) {
            return _buildLoadingState(context);
          } else if (state is SubscriptionTagsLoaded) {
            return _buildTagsContent(context, state.tags);
          } else if (state is SubscriptionTagsError) {
            return _buildErrorState(context, state.message);
          }
          return _buildInitialState(context);
        },
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 16),
            Text(
              'Loading tags...',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagsContent(BuildContext context, List<String> tags) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.label_outline,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Tags (${tags.length})',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh, size: 20),
                  onPressed: () {
                    context.read<SubscriptionsBloc>().add(
                      LoadSubscriptionTags(subscriptionId),
                    );
                    onRefresh?.call();
                  },
                  tooltip: 'Refresh Tags',
                  style: IconButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
                    padding: const EdgeInsets.all(8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (tags.isEmpty)
              _buildEmptyState(context)
            else
              _buildTagsList(context, tags),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.3,
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(
            alpha: 0.3,
          ),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.label_off_outlined,
            size: 48,
            color: Theme.of(context).colorScheme.outline.withValues(
              alpha: 0.6,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No tags found',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.outline.withValues(
                alpha: 0.8,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'This subscription has no tags assigned',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.outline.withValues(
                alpha: 0.6,
              ),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTagsList(BuildContext context, List<String> tags) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: tags.map((tag) => _buildTagChip(context, tag)).toList(),
    );
  }

  Widget _buildTagChip(BuildContext context, String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(
            alpha: 0.3,
          ),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.label,
            size: 16,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 6),
          Text(
            tag,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: Theme.of(context).colorScheme.error,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Failed to load tags',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.error.withValues(
                  alpha: 0.8,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      context.read<SubscriptionsBloc>().add(
                        LoadSubscriptionTags(subscriptionId),
                      );
                    },
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.error,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInitialState(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.label_outline,
              color: Theme.of(context).colorScheme.outline.withValues(
                alpha: 0.6,
              ),
              size: 20,
            ),
            const SizedBox(width: 16),
            Text(
              'Tags',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Text(
              'Loading...',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.outline.withValues(
                  alpha: 0.6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
