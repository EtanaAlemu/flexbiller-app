import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/accounts_bloc.dart';
import '../bloc/accounts_event.dart';
import '../bloc/accounts_state.dart';
import '../../domain/entities/account.dart';
import 'account_card_widget.dart';

class AccountsListWidget extends StatelessWidget {
  const AccountsListWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccountsBloc, AccountsState>(
      builder: (context, state) {
        if (state is AccountsLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is AccountsFailure) {
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
                  'Failed to load accounts',
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
                    context.read<AccountsBloc>().add(const LoadAccounts());
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (state is AccountsLoaded) {
          if (state.accounts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.account_circle_outlined,
                    size: 64,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No accounts found',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Try adjusting your search or filters',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Text(
                      '${state.accounts.length} accounts',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const Spacer(),
                    if (state.hasReachedMax == false)
                      TextButton(
                        onPressed: () {
                          context.read<AccountsBloc>().add(
                            LoadMoreAccounts(
                              offset: state.currentOffset,
                              limit: 20,
                            ),
                          );
                        },
                        child: const Text('Load More'),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    context.read<AccountsBloc>().add(const RefreshAccounts());
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount:
                        state.accounts.length +
                        (state.hasReachedMax == false ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == state.accounts.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      final account = state.accounts[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: AccountCardWidget(account: account),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        }

        if (state is AccountsRefreshing) {
          return RefreshIndicator(
            onRefresh: () async {
              context.read<AccountsBloc>().add(const RefreshAccounts());
            },
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: state.accounts.length,
              itemBuilder: (context, index) {
                final account = state.accounts[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: AccountCardWidget(account: account),
                );
              },
            ),
          );
        }

        if (state is AccountsLoadingMore) {
          return RefreshIndicator(
            onRefresh: () async {
              context.read<AccountsBloc>().add(const RefreshAccounts());
            },
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: state.accounts.length + 1,
              itemBuilder: (context, index) {
                if (index == state.accounts.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final account = state.accounts[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: AccountCardWidget(account: account),
                );
              },
            ),
          );
        }

        return const Center(child: Text('No accounts to display'));
      },
    );
  }
}
