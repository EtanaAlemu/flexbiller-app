import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import "../bloc/accounts_list_bloc.dart";
import '../bloc/accounts_orchestrator_bloc.dart';
import '../bloc/events/accounts_list_events.dart' as list_events;
import '../bloc/states/accounts_list_states.dart' as list_states;
import '../bloc/states/accounts_state.dart' as orchestrator_states;
import '../../domain/entities/account.dart';
import '../../domain/entities/accounts_query_params.dart';
import 'selectable_account_card_widget.dart';
import 'multi_select_action_bar.dart';
import 'create_account_form.dart';

class AccountsListWidget extends StatefulWidget {
  final ScrollController? scrollController;

  const AccountsListWidget({Key? key, this.scrollController}) : super(key: key);

  @override
  State<AccountsListWidget> createState() => _AccountsListWidgetState();
}

class _AccountsListWidgetState extends State<AccountsListWidget> {
  List<Account> _cachedAccounts = [];
  List<Account> _selectedAccounts = [];
  bool _isMultiSelectMode = false;
  final Logger _logger = Logger();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<
      AccountsOrchestratorBloc,
      orchestrator_states.AccountsState
    >(
      builder: (context, orchestratorState) {
        // Handle multi-select states
        if (orchestratorState is orchestrator_states.MultiSelectModeEnabled) {
          _isMultiSelectMode = true;
          _selectedAccounts = orchestratorState.selectedAccounts;
          _logger.d(
            '🔍 Multi-select mode enabled with ${_selectedAccounts.length} selected accounts',
          );
          return _buildMultiSelectMode(context, _selectedAccounts);
        } else if (orchestratorState
            is orchestrator_states.MultiSelectModeDisabled) {
          _isMultiSelectMode = false;
          _selectedAccounts = [];
          _logger.d('🔍 Multi-select mode disabled');
        } else if (orchestratorState is orchestrator_states.AccountSelected) {
          _selectedAccounts = orchestratorState.selectedAccounts;
          _logger.d(
            '🔍 Account selected: ${orchestratorState.account.name}, total selected: ${_selectedAccounts.length}',
          );
          if (_isMultiSelectMode) {
            return _buildMultiSelectMode(context, _selectedAccounts);
          }
        } else if (orchestratorState is orchestrator_states.AccountDeselected) {
          _selectedAccounts = orchestratorState.selectedAccounts;
          _logger.d(
            '🔍 Account deselected: ${orchestratorState.account.name}, total selected: ${_selectedAccounts.length}',
          );
          if (_isMultiSelectMode) {
            return _buildMultiSelectMode(context, _selectedAccounts);
          }
        } else if (orchestratorState
            is orchestrator_states.AllAccountsSelected) {
          _selectedAccounts = orchestratorState.selectedAccounts;
          _logger.d('🔍 All accounts selected: ${_selectedAccounts.length}');
          if (_isMultiSelectMode) {
            return _buildMultiSelectMode(context, _selectedAccounts);
          }
        } else if (orchestratorState
            is orchestrator_states.AllAccountsDeselected) {
          _selectedAccounts = [];
          _logger.d('🔍 All accounts deselected');
          if (_isMultiSelectMode) {
            return _buildMultiSelectMode(context, _selectedAccounts);
          }
        }

        // For all other states, use the accounts list BLoC
        return BlocBuilder<AccountsListBloc, list_states.AccountsListState>(
          builder: (context, state) {
            _logger.d(
              '🔍 DEBUG: AccountsListWidget - Current state: ${state.runtimeType}',
            );

            // Cache accounts when they are loaded - update for any state that has accounts
            if (state is list_states.AccountsListLoaded) {
              _cachedAccounts = state.accounts;
            } else if (state is list_states.AllAccountsLoaded) {
              _cachedAccounts = state.accounts;
            } else if (state is list_states.AccountsFiltered) {
              _cachedAccounts = state.accounts;
            }

            // Handle loading states
            if (state is list_states.AccountsListLoading) {
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

            if (state is list_states.GetAllAccountsLoading) {
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

            if (state is list_states.AllAccountsLoaded) {
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
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No accounts available in the system',
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
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
                              final accountsBloc = context
                                  .read<AccountsListBloc>();
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => BlocProvider.value(
                                    value: accountsBloc,
                                    child: CreateAccountForm(
                                      onAccountCreated: () {
                                        accountsBloc.add(
                                          const list_events.RefreshAccounts(),
                                        );
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
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () {
                            context.read<AccountsListBloc>().add(
                              const list_events.LoadAccounts(
                                AccountsQueryParams(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.arrow_back),
                          label: const Text('Back to Paginated View'),
                          style: TextButton.styleFrom(
                            foregroundColor: Theme.of(
                              context,
                            ).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () {
                            context.read<AccountsListBloc>().add(
                              const list_events.RefreshAllAccounts(),
                            );
                          },
                          icon:
                              BlocBuilder<
                                AccountsListBloc,
                                list_states.AccountsListState
                              >(
                                builder: (context, state) {
                                  if (state
                                      is list_states.AllAccountsRefreshing) {
                                    return const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    );
                                  }
                                  return const Icon(Icons.refresh);
                                },
                              ),
                          tooltip: 'Refresh All Accounts',
                          style: IconButton.styleFrom(
                            foregroundColor: Theme.of(
                              context,
                            ).colorScheme.primary,
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

            if (state is list_states.AllAccountsRefreshing) {
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
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
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

            if (state is list_states.AccountsListFailure) {
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
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
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
                                context.read<AccountsListBloc>().add(
                                  const list_events.LoadAccounts(
                                    AccountsQueryParams(),
                                  ),
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
                                context.read<AccountsListBloc>().add(
                                  const list_events.LoadAccounts(
                                    AccountsQueryParams(),
                                  ),
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

            if (state is list_states.AccountsListLoaded) {
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
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Try adjusting your search or filters',
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
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
                                  context.read<AccountsListBloc>().add(
                                    const list_events.LoadAccounts(
                                      AccountsQueryParams(),
                                    ),
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
                                  final accountsBloc = context
                                      .read<AccountsListBloc>();
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => BlocProvider.value(
                                        value: accountsBloc,
                                        child: CreateAccountForm(
                                          onAccountCreated: () {
                                            accountsBloc.add(
                                              const list_events.RefreshAccounts(),
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

            if (state is list_states.AccountsFiltered) {
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
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Filter: ${state.filterType} = "${state.filterValue}"',
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
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
                                  context.read<AccountsListBloc>().add(
                                    list_events.ClearFilters(),
                                  );
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
                                  context.read<AccountsListBloc>().add(
                                    const list_events.LoadAccounts(
                                      AccountsQueryParams(),
                                    ),
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

            if (state is list_states.AccountsListLoading) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(
                      'Searching for accounts...',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              );
            }

            if (state is list_states.AccountsFiltered) {
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
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No accounts match your search',
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
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
                                  context.read<AccountsListBloc>().add(
                                    const list_events.LoadAccounts(
                                      AccountsQueryParams(),
                                    ),
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
                                  context.read<AccountsListBloc>().add(
                                    const list_events.LoadAccounts(
                                      AccountsQueryParams(),
                                    ),
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
                          '${state.accounts.length} search results',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () {
                            context.read<AccountsListBloc>().add(
                              const list_events.LoadAccounts(
                                AccountsQueryParams(),
                              ),
                            );
                          },
                          child: const Text('View All'),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      controller: widget.scrollController,
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

            if (state is list_states.AllAccountsRefreshing) {
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<AccountsListBloc>().add(
                    const list_events.RefreshAccounts(),
                  );
                },
                child: _cachedAccounts.isNotEmpty
                    ? ListView.builder(
                        controller: widget.scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        itemCount: _cachedAccounts.length,
                        itemBuilder: (context, index) {
                          final account = _cachedAccounts[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: SelectableAccountCardWidget(
                              account: account,
                              isSelected: false,
                              isMultiSelectMode: false,
                            ),
                          );
                        },
                      )
                    : const Center(child: CircularProgressIndicator()),
              );
            }

            if (state is list_states.AccountsListLoading) {
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<AccountsListBloc>().add(
                    const list_events.RefreshAccounts(),
                  );
                },
                child: _cachedAccounts.isNotEmpty
                    ? ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        itemCount: _cachedAccounts.length + 1,
                        itemBuilder: (context, index) {
                          if (index == _cachedAccounts.length) {
                            return const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }

                          final account = _cachedAccounts[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: SelectableAccountCardWidget(
                              account: account,
                              isSelected: false,
                              isMultiSelectMode: false,
                            ),
                          );
                        },
                      )
                    : const Center(child: CircularProgressIndicator()),
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

            // Handle list_states.AccountsListInitial state by triggering a load
            if (state is list_states.AccountsListInitial) {
              _logger.d(
                'State is list_states.AccountsListInitial, triggering load accounts',
              );
              WidgetsBinding.instance.addPostFrameCallback((_) {
                context.read<AccountsListBloc>().add(
                  const list_events.LoadAccounts(AccountsQueryParams()),
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
            if (state is! list_states.AccountsListFailure) {
              _logger.d(
                'Triggering load accounts for unexpected state: ${state.runtimeType}',
              );
              WidgetsBinding.instance.addPostFrameCallback((_) {
                context.read<AccountsListBloc>().add(
                  const list_events.LoadAccounts(AccountsQueryParams()),
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
                    context.read<AccountsListBloc>().add(
                      const list_events.LoadMoreAccounts(),
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
              context.read<AccountsListBloc>().add(
                const list_events.RefreshAccounts(),
              );
            },
            child: ListView.builder(
              controller: widget.scrollController,
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
            controller: widget.scrollController,
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
