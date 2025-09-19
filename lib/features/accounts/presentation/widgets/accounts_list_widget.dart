import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import '../bloc/accounts_bloc.dart';
import '../bloc/events/accounts_event.dart';
import '../bloc/states/accounts_state.dart';
import '../../domain/entities/account.dart';
import '../../domain/entities/accounts_query_params.dart';
import 'selectable_account_card_widget.dart';
import 'multi_select_action_bar.dart';
import 'create_account_form.dart';

class AccountsListWidget extends StatefulWidget {
  const AccountsListWidget({Key? key}) : super(key: key);

  @override
  State<AccountsListWidget> createState() => _AccountsListWidgetState();
}

class _AccountsListWidgetState extends State<AccountsListWidget> {
  List<Account> _cachedAccounts = [];
  final Logger _logger = Logger();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccountsBloc, AccountsState>(
      builder: (context, state) {
        _logger.d(
          '🔍 DEBUG: AccountsListWidget - Current state: ${state.runtimeType}',
        );

        // Cache accounts when they are loaded - update for any state that has accounts
        if (state is AccountsLoaded) {
          _cachedAccounts = state.accounts;
        } else if (state is AllAccountsLoaded) {
          _cachedAccounts = state.accounts;
        } else if (state is AccountsSearchResults) {
          _cachedAccounts = state.accounts;
        } else if (state is AccountsFiltered) {
          _cachedAccounts = state.accounts;
        } else if (state is BulkAccountsDeleting) {
          // Update cached accounts when deleting to reflect current state
          _cachedAccounts = state.accountsToDelete;
        } else if (state is BulkAccountsExporting) {
          // Update cached accounts when exporting to reflect current state
          _cachedAccounts = state.accountsToExport;
        }

        // Handle multi-select states
        if (state is MultiSelectModeEnabled) {
          return _buildMultiSelectMode(context, state.selectedAccounts);
        }

        if (state is AccountSelected) {
          return _buildMultiSelectMode(context, state.selectedAccounts);
        }

        if (state is AccountDeselected) {
          return _buildMultiSelectMode(context, state.selectedAccounts);
        }

        if (state is AllAccountsSelected) {
          return _buildMultiSelectMode(context, state.selectedAccounts);
        }

        if (state is AllAccountsDeselected) {
          return _buildMultiSelectMode(context, []);
        }

        if (state is BulkAccountsDeleting) {
          return _buildMultiSelectMode(context, state.accountsToDelete);
        }

        if (state is AccountDeleted) {
          // After successful single account deletion, refresh the accounts list
          _logger.d('Account deleted successfully, refreshing accounts list');
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.read<AccountsBloc>().add(
              const LoadAccounts(AccountsQueryParams()),
            );
          });
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Refreshing accounts...'),
              ],
            ),
          );
        }

        if (state is BulkAccountsDeleted) {
          // After successful bulk deletion, refresh the accounts list
          _logger.d('Accounts deleted successfully, refreshing accounts list');
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.read<AccountsBloc>().add(
              const LoadAccounts(AccountsQueryParams()),
            );
          });
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Refreshing accounts...'),
              ],
            ),
          );
        }

        if (state is AccountDeletionFailure) {
          // Handle single account deletion failure
          _logger.d('Account deletion failed: ${state.message}');
          // Refresh accounts list to show current state
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.read<AccountsBloc>().add(
              const LoadAccounts(AccountsQueryParams()),
            );
          });
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Refreshing accounts...'),
              ],
            ),
          );
        }

        if (state is BulkAccountsDeletionFailure) {
          // Handle bulk deletion failure
          _logger.d('Account deletion failed: ${state.message}');
          // Refresh accounts list to show current state
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.read<AccountsBloc>().add(
              const LoadAccounts(AccountsQueryParams()),
            );
          });
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Refreshing accounts...'),
              ],
            ),
          );
        }

        if (state is BulkAccountsExporting) {
          return _buildMultiSelectMode(context, state.accountsToExport);
        }

        if (state is BulkAccountsExportSuccess) {
          return _buildMultiSelectMode(context, _cachedAccounts);
        }

        if (state is BulkAccountsExportFailure) {
          return _buildMultiSelectMode(context, _cachedAccounts);
        }

        if (state is AccountsLoading) {
          // If we have cached accounts, show them during loading
          if (_cachedAccounts.isNotEmpty) {
            _logger.d(
              'Showing cached accounts during loading: ${_cachedAccounts.length}',
            );
            return _buildAccountsList(
              context,
              _cachedAccounts,
              true, // hasReachedMax
              0, // currentOffset
            );
          }
          return const Center(child: CircularProgressIndicator());
        }

        if (state is GetAllAccountsLoading) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primaryContainer.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Loading all accounts...',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Please wait while we fetch your accounts',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          );
        }

        if (state is AllAccountsLoaded) {
          if (state.accounts.isEmpty) {
            return Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.primaryContainer.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.account_circle_outlined,
                          size: 64,
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'No accounts found',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No accounts available in the system',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          // Navigate to create account
                          final accountsBloc = context.read<AccountsBloc>();
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => BlocProvider.value(
                                value: accountsBloc,
                                child: CreateAccountForm(
                                  onAccountCreated: () {
                                    accountsBloc.add(const RefreshAccounts());
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('Create First Account'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          foregroundColor: Theme.of(
                            context,
                          ).colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
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
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.errorContainer.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.error_outline_rounded,
                        size: 64,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Failed to load accounts',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      state.message,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () {
                            context.read<AccountsBloc>().add(
                              const LoadAccounts(AccountsQueryParams()),
                            );
                          },
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Retry'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: () {
                            context.read<AccountsBloc>().add(
                              const LoadAccounts(AccountsQueryParams()),
                            );
                          },
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Refresh'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.error,
                            foregroundColor: Theme.of(
                              context,
                            ).colorScheme.onError,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
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

        if (state is AccountsLoaded) {
          if (state.accounts.isEmpty) {
            return Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceVariant.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.search_off_rounded,
                          size: 64,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurfaceVariant.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'No accounts found',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Try adjusting your search or filters',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          OutlinedButton.icon(
                            onPressed: () {
                              context.read<AccountsBloc>().add(
                                const LoadAccounts(AccountsQueryParams()),
                              );
                            },
                            icon: const Icon(Icons.refresh_rounded),
                            label: const Text('Refresh'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            onPressed: () {
                              final accountsBloc = context.read<AccountsBloc>();
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => BlocProvider.value(
                                    value: accountsBloc,
                                    child: CreateAccountForm(
                                      onAccountCreated: () {
                                        accountsBloc.add(
                                          const RefreshAccounts(),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.add_rounded),
                            label: const Text('Add Account'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.primary,
                              foregroundColor: Theme.of(
                                context,
                              ).colorScheme.onPrimary,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
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

          return _buildAccountsList(
            context,
            state.accounts,
            state.hasReachedMax,
            state.currentOffset,
          );
        }

        if (state is AccountsFiltered) {
          if (state.accounts.isEmpty) {
            return Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceVariant.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.filter_list_off_rounded,
                          size: 64,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurfaceVariant.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'No accounts match your filter',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Filter: ${state.filterType} = "${state.filterValue}"',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          OutlinedButton.icon(
                            onPressed: () {
                              context.read<AccountsBloc>().add(ClearFilters());
                            },
                            icon: const Icon(Icons.clear_rounded),
                            label: const Text('Clear Filter'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            onPressed: () {
                              context.read<AccountsBloc>().add(
                                const LoadAccounts(AccountsQueryParams()),
                              );
                            },
                            icon: const Icon(Icons.refresh_rounded),
                            label: const Text('Refresh'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.primary,
                              foregroundColor: Theme.of(
                                context,
                              ).colorScheme.onPrimary,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
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

          return _buildAccountsList(
            context,
            state.accounts,
            true, // Filtered results are not paginated
            0, // Reset offset for filtered results
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
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.tertiaryContainer.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.search_off_rounded,
                          size: 64,
                          color: Theme.of(
                            context,
                          ).colorScheme.tertiary.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'No search results',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No accounts match your search for "${state.searchKey}"',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          OutlinedButton.icon(
                            onPressed: () {
                              context.read<AccountsBloc>().add(
                                const LoadAccounts(AccountsQueryParams()),
                              );
                            },
                            icon: const Icon(Icons.clear_rounded),
                            label: const Text('Clear Search'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            onPressed: () {
                              context.read<AccountsBloc>().add(
                                const LoadAccounts(AccountsQueryParams()),
                              );
                            },
                            icon: const Icon(Icons.list_rounded),
                            label: const Text('View All'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.primary,
                              foregroundColor: Theme.of(
                                context,
                              ).colorScheme.onPrimary,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
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
                      child: SelectableAccountCardWidget(
                        account: account,
                        isSelected: false,
                        isMultiSelectMode: false,
                      ),
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
                  child: SelectableAccountCardWidget(
                    account: account,
                    isSelected: false,
                    isMultiSelectMode: false,
                  ),
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
                  child: SelectableAccountCardWidget(
                    account: account,
                    isSelected: false,
                    isMultiSelectMode: false,
                  ),
                );
              },
            ),
          );
        }

        // Handle case where we have cached accounts but state is not one of the expected states
        if (_cachedAccounts.isNotEmpty) {
          _logger.d(
            'Using cached accounts (${_cachedAccounts.length}) for state: ${state.runtimeType}',
          );
          return _buildAccountsList(
            context,
            _cachedAccounts,
            true, // hasReachedMax
            0, // currentOffset
          );
        }

        // Handle AccountsInitial state by triggering a load
        if (state is AccountsInitial) {
          _logger.d('State is AccountsInitial, triggering load accounts');
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.read<AccountsBloc>().add(
              const LoadAccounts(AccountsQueryParams()),
            );
          });
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading accounts...'),
              ],
            ),
          );
        }

        // Handle other states that might not have accounts
        _logger.d('No cached accounts and state is: ${state.runtimeType}');

        // If we have any state that might indicate we should show accounts, try to load them
        if (state is! AccountsFailure && state is! AccountDetailsFailure) {
          _logger.d(
            'Triggering load accounts for unexpected state: ${state.runtimeType}',
          );
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.read<AccountsBloc>().add(
              const LoadAccounts(AccountsQueryParams()),
            );
          });
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading accounts...'),
              ],
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
                  child: SelectableAccountCardWidget(
                    account: account,
                    isSelected: false,
                    isMultiSelectMode: false,
                  ),
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
