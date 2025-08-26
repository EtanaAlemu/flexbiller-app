import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/subscriptions_bloc.dart';
import '../bloc/subscriptions_event.dart';
import '../bloc/subscriptions_state.dart';
import '../widgets/subscription_card_widget.dart';

class SubscriptionsPage extends StatelessWidget {
  const SubscriptionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recent Subscriptions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<SubscriptionsBloc>().add(RefreshSubscriptions());
            },
          ),
        ],
      ),
      body: BlocBuilder<SubscriptionsBloc, SubscriptionsState>(
        builder: (context, state) {
          if (state is SubscriptionsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is SubscriptionsLoaded) {
            if (state.subscriptions.isEmpty) {
              return const Center(child: Text('No subscriptions found'));
            }
            return RefreshIndicator(
              onRefresh: () async {
                context.read<SubscriptionsBloc>().add(RefreshSubscriptions());
              },
              child: ListView.builder(
                itemCount: state.subscriptions.length,
                itemBuilder: (context, index) {
                  final subscription = state.subscriptions[index];
                  return SubscriptionCardWidget(subscription: subscription);
                },
              ),
            );
          } else if (state is SubscriptionsError) {
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
                        LoadRecentSubscriptions(),
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
    );
  }
}
