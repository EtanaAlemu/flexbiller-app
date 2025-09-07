import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/accounts_bloc.dart';
import '../bloc/accounts_event.dart';
import '../bloc/accounts_state.dart';
import '../../domain/entities/account.dart';
import '../../domain/entities/accounts_query_params.dart';
import 'account_card_widget.dart';
import 'selectable_account_card_widget.dart';
import 'multi_select_action_bar.dart';

class AccountsListWidget extends StatefulWidget {
  const AccountsListWidget({Key? key}) : super(key: key);

  @override
  State<AccountsListWidget> createState() => _AccountsListWidgetState();
}

class _AccountsListWidgetState extends State<AccountsListWidget> {
  List<Account> _cachedAccounts = [];
  bool _isMultiSelectMode = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccountsBloc, AccountsState>(
      builder: (context, state) {
        // Cache accounts when they are loaded
        if (state is AccountsLoaded) {
          _cachedAccounts = state.accounts;
          _isMultiSelectMode = false;
        } else if (state is AllAccountsLoaded) {
          _cachedAccounts = state.accounts;
          _isMultiSelectMode = false;
        } else if (state is AccountsSearchResults) {
          _cachedAccounts = state.accounts;
          _isMultiSelectMode = false;
        }

        // Handle multi-select states
        if (state is MultiSelectModeEnabled) {
          _isMultiSelectMode = true;
          return _buildMultiSelectMode(context, state.selectedAccounts);
        }

        if (state is AccountSelected) {
          _isMultiSelectMode = true;
          return _buildMultiSelectMode(context, state.selectedAccounts);
        }

        if (state is AccountDeselected) {
          _isMultiSelectMode = true;
          return _buildMultiSelectMode(context, state.selectedAccounts);
        }

        if (state is AllAccountsSelected) {
          _isMultiSelectMode = true;
          return _buildMultiSelectMode(context, state.selectedAccounts);
        }

        if (state is AllAccountsDeselected) {
          _isMultiSelectMode = true;
          return _buildMultiSelectMode(context, []);
        }

        if (state is BulkAccountsDeleting) {
          _isMultiSelectMode = true;
          return _buildMultiSelectMode(context, state.accountsToDelete);
        }

        if (state is BulkAccountsExporting) {
          _isMultiSelectMode = true;
          return _buildMultiSelectMode(context, state.accountsToExport);
        }

        if (state is BulkAccountsExportSuccess) {
          _isMultiSelectMode = true;
          return _buildMultiSelectMode(context, _cachedAccounts);
        }

        if (state is BulkAccountsExportFailure) {
          _isMultiSelectMode = true;
          return _buildMultiSelectMode(context, _cachedAccounts);
        }

        if (state is MultiSelectModeDisabled) {
          _isMultiSelectMode = false;
        }

        if (state is AccountsLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is GetAllAccountsLoading) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading all accounts...'),
              ],
            ),
          );
        }

        if (state is AllAccountsLoaded) {
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
                    'No accounts available in the system',
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
                    Icon(
                      Icons.info_outline,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Showing all ${state.totalCount} accounts',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        context.read<AccountsBloc>().add(
                          const LoadAccounts(AccountsQueryParams()),
                        );
                      },
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Back to Paginated View'),
                      style: TextButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () {
                        context.read<AccountsBloc>().add(
                          const RefreshAllAccounts(),
                        );
                      },
                      icon: BlocBuilder<AccountsBloc, AccountsState>(
                        builder: (context, state) {
                          if (state is AllAccountsRefreshing) {
                            return const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            );
                          }
                          return const Icon(Icons.refresh);
                        },
                      ),
                      tooltip: 'Refresh All Accounts',
                      style: IconButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _buildAccountsList(
                  context,
                  state.accounts,
                  true, // hasReachedMax
                  0, // currentOffset
                ),
              ),
            ],
          );
        }

        if (state is AllAccountsRefreshing) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Refreshing all accounts...',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      Text(
                        'Refreshing accounts...',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
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
                    context.read<AccountsBloc>().add(
                      const LoadAccounts(AccountsQueryParams()),
                    );
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

          return _buildAccountsList(
            context,
            state.accounts,
            state.hasReachedMax,
            state.currentOffset,
          );
        }

        if (state is AccountsSearching) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  'Searching for "${state.searchKey}"...',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          );
        }

        if (state is AccountsSearchResults) {
          if (state.accounts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off,
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
                    'No accounts match your search for "${state.searchKey}"',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<AccountsBloc>().add(
                        const LoadAccounts(AccountsQueryParams()),
                      );
                    },
                    child: const Text('View All Accounts'),
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
                      '${state.accounts.length} search results for "${state.searchKey}"',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        context.read<AccountsBloc>().add(
                          const LoadAccounts(AccountsQueryParams()),
                        );
                      },
                      child: const Text('View All'),
                    ),
                  ],
                ),
              ),
              Expanded(
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

  Widget _buildAccountsList(
    BuildContext context,
    List<Account> accounts,
    bool hasReachedMax,
    int currentOffset,
  ) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Text(
                '${accounts.length} accounts',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              if (hasReachedMax == false)
                TextButton(
                  onPressed: () {
                    context.read<AccountsBloc>().add(
                      LoadMoreAccounts(offset: currentOffset, limit: 20),
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
              itemCount: accounts.length + (hasReachedMax == false ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == accounts.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final account = accounts[index];
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

  Widget _buildMultiSelectMode(
    BuildContext context,
    List<Account> selectedAccounts,
  ) {
    // Use cached accounts instead of trying to get them from current state
    List<Account> allAccounts = _cachedAccounts;
    bool isAllSelected =
        selectedAccounts.length == allAccounts.length && allAccounts.isNotEmpty;

    return Column(
      children: [
        // Multi-select action bar
        MultiSelectActionBar(
          selectedAccounts: selectedAccounts,
          isAllSelected: isAllSelected,
          allAccounts: allAccounts,
        ),
        // Accounts list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: allAccounts.length,
            itemBuilder: (context, index) {
              final account = allAccounts[index];
              final isSelected = selectedAccounts.any(
                (a) => a.id == account.id,
              );

              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: SelectableAccountCardWidget(
                  account: account,
                  isSelected: isSelected,
                  isMultiSelectMode: true,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
