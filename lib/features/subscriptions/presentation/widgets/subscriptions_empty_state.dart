import 'package:flutter/material.dart';
import '../pages/create_subscription_page.dart';

class SubscriptionsEmptyState extends StatelessWidget {
  final bool isSearching;
  final Future<void> Function()? onRefresh;

  const SubscriptionsEmptyState({
    super.key,
    this.isSearching = false,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isSearching
                    ? Icons.search_off_rounded
                    : Icons.subscriptions_rounded,
                size: 48,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isSearching ? 'No subscriptions found' : 'No subscriptions yet',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              isSearching
                  ? 'Try adjusting your search terms or filters'
                  : 'Create your first subscription to get started',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (!isSearching)
              FilledButton.icon(
                onPressed: () {
                  // Navigate to create subscription page using MaterialPageRoute
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const CreateSubscriptionPage(),
                    ),
                  );
                },
                icon: const Icon(Icons.add_rounded),
                label: const Text('Create Subscription'),
              ),
            if (onRefresh != null) ...[
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Refresh'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
