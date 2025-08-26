import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/subscriptions_bloc.dart';
import '../bloc/subscriptions_event.dart';
import '../bloc/subscriptions_state.dart';
import '../widgets/subscription_card_widget.dart';
import 'create_subscription_page.dart';

class AccountSubscriptionsPage extends StatelessWidget {
  final String accountId;
  final String? accountName;

  const AccountSubscriptionsPage({
    super.key,
    required this.accountId,
    this.accountName,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          context.read<SubscriptionsBloc>()
            ..add(LoadSubscriptionsForAccount(accountId)),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            accountName != null
                ? 'Subscriptions - $accountName'
                : 'Account Subscriptions',
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                context.read<SubscriptionsBloc>().add(
                  LoadSubscriptionsForAccount(accountId),
                );
              },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _createNewSubscription(context),
          icon: const Icon(Icons.add),
          label: const Text('New Subscription'),
        ),
        body: BlocBuilder<SubscriptionsBloc, SubscriptionsState>(
          builder: (context, state) {
            if (state is AccountSubscriptionsLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is AccountSubscriptionsLoaded) {
              if (state.subscriptions.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.subscriptions_outlined,
                        size: 64,
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No subscriptions found',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'This account doesn\'t have any active subscriptions',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => _createNewSubscription(context),
                        icon: const Icon(Icons.add),
                        label: const Text('Create First Subscription'),
                      ),
                    ],
                  ),
                );
              }
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<SubscriptionsBloc>().add(
                    LoadSubscriptionsForAccount(accountId),
                  );
                },
                child: Column(
                  children: [
                    _buildAccountInfoHeader(context, state),
                    Expanded(
                      child: ListView.builder(
                        itemCount: state.subscriptions.length,
                        itemBuilder: (context, index) {
                          final subscription = state.subscriptions[index];
                          return SubscriptionCardWidget(
                            subscription: subscription,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            } else if (state is AccountSubscriptionsError) {
              return Center(
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
                      'Error loading subscriptions',
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
                          LoadSubscriptionsForAccount(accountId),
                        );
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }
            return const Center(child: Text('No subscriptions loaded'));
          },
        ),
      ),
    );
  }

  void _createNewSubscription(BuildContext context) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            CreateSubscriptionPage(initialAccountId: accountId),
      ),
    );

    // If subscription was created successfully, refresh the list
    if (result == true) {
      if (context.mounted) {
        context.read<SubscriptionsBloc>().add(
          LoadSubscriptionsForAccount(accountId),
        );
      }
    }
  }

  Widget _buildAccountInfoHeader(
    BuildContext context,
    AccountSubscriptionsLoaded state,
  ) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.1),
        border: Border(bottom: BorderSide(color: theme.dividerColor, width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.account_circle,
                color: theme.colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Account ID: $accountId',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${state.subscriptions.length} subscription${state.subscriptions.length == 1 ? '' : 's'} found',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
