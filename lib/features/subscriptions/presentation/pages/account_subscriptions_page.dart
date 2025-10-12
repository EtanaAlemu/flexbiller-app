import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/subscriptions_bloc.dart';
import '../bloc/subscriptions_event.dart';
import '../bloc/subscriptions_state.dart';
import '../widgets/subscription_card_widget.dart';
import '../widgets/subscriptions_loading_widget.dart';
import '../widgets/subscriptions_error_widget.dart';
import '../widgets/subscriptions_empty_state.dart';
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
    final theme = Theme.of(context);

    return BlocProvider(
      create: (context) =>
          context.read<SubscriptionsBloc>()
            ..add(GetSubscriptionsForAccount(accountId)),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            accountName != null
                ? 'Subscriptions - $accountName'
                : 'Account Subscriptions',
          ),
          backgroundColor: theme.colorScheme.surface,
          foregroundColor: theme.colorScheme.onSurface,
          elevation: 0,
          scrolledUnderElevation: 1,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: () {
                context.read<SubscriptionsBloc>().add(
                  GetSubscriptionsForAccount(accountId),
                );
              },
              tooltip: 'Refresh',
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _createNewSubscription(context),
          icon: const Icon(Icons.add_rounded),
          label: const Text('New Subscription'),
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
        ),
        body: BlocBuilder<SubscriptionsBloc, SubscriptionsState>(
          builder: (context, state) {
            if (state is AccountSubscriptionsLoading) {
              return const SubscriptionsLoadingWidget();
            } else if (state is AccountSubscriptionsLoaded) {
              if (state.subscriptions.isEmpty) {
                return SubscriptionsEmptyState(
                  onRefresh: () async {
                    context.read<SubscriptionsBloc>().add(
                      GetSubscriptionsForAccount(accountId),
                    );
                  },
                );
              }
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<SubscriptionsBloc>().add(
                    GetSubscriptionsForAccount(accountId),
                  );
                },
                child: Column(
                  children: [
                    _buildAccountInfoHeader(context, state),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
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
              return SubscriptionsErrorWidget(
                message: state.message,
                onRetry: () {
                  context.read<SubscriptionsBloc>().add(
                    GetSubscriptionsForAccount(accountId),
                  );
                },
              );
            }
            return const SubscriptionsEmptyState();
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
          GetSubscriptionsForAccount(accountId),
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
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primaryContainer,
            theme.colorScheme.primaryContainer.withOpacity(0.7),
          ],
        ),
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.account_circle_rounded,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      accountName ?? 'Account',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      accountId,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer.withOpacity(
                          0.7,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${state.subscriptions.length}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
